#!/usr/bin/env bash
#
# Public domain script by amaurea/amaur on IRC (freenode for example).
# Modified by trapanator to support download/upload rate setting and to
# suspend/resume KTorrent network activity. Refactored by devourerOfBits80.
#
# gary example
#   qdbus org.kde.ktorrent /core startAll


case $1 in
    help)
        echo "kt: A simple console interface for KTorrent.
Usage: In the following [id] indicates either a torrent hash or index.

    kt start [id]:
        If KTorrent is not running, start it. Otherwise, if [id] is given,
        start that torrent, otherwise start all torrents.

    kt load [url]:
        Load the torrent given by [url]. Note that the torrent must be
        manually startet afterwards.

    kt ls:
        Print a list of all torrents, of the format: index hash name.

    kt info [id]:
        Print more detailed info about the selected (or all) torrent(s).

    kt stop [id]:
        Stop the torrent given by [id], or all if [id] is missing.

    kt name [id]:
        Like \"ls\", but the torrent (given by [id]) name only.

    kt remove [id]:
        Remove the torrent given by [id] (but not the actual files).

    kt files [id]:
        List information about the files of the selected torrent.

    kt pri [id] [priority]:
        Give the selected torrent the given [priority].

    kt pri [id] [file_index] [priority]:
        Set the [priority] of the given file.

    kt pri [id] equal:
        Give all files of the torrent the same priority.

    kt pri [id] inc:
        Increase priority all files of the torrent according to their index.

    kt pri [id] dec:
        Decrease priority all files of the torrent according to their index.

    kt pri [id] first:
        Download the first files in the torrent first.

    kt mur [n]:
        Set max upload rate to [n].

    kt mdr [n]:
        Set max download rate to [n].

    kt suspend:
        Suspend all torrents.

    kt resume:
        Resume all torrents.

    kt clear:
        Remove all torrents.

    kt quit:
        Quit KTorrent."
        exit ;;
esac

pid=$(pidof ktorrent)

if [ ! $pid ]; then
    case "$1" in
        start)
            ktorrent --display :0.0 ;;
        *)
            echo "KTorrent is not running!" ;;
    esac
    exit
fi

eval "export $(perl -pne 's/\0/\n/g' /proc/$pid/environ | fgrep -a DBUS_SESSION_BUS_ADDRESS)"
loc="org.kde.ktorrent"
cmd="qdbus $loc"

case "$1" in
    load)
        if [ "$2" ]; then res=$($cmd /core loadSilently "$2" 1)
        else echo "torrent [url] missing!"; fi ;;
    ls|list)
        torrents=$($cmd /core torrents)
        i=0
        for torrent in $torrents; do
            name=$($cmd /torrent/$torrent name)
            printf "%d %s %s\n" $i "$torrent" "$name"
            i=$(($i+1))
        done ;;
    info)
        torrents=($($cmd /core torrents))

        if [ "$2" ]; then
            if (( ${#2} < 4 )); then torrents=${torrents[$2]}
            else torrents=$2; fi
        fi

        i=0
        for torrent in $torrents; do
            prog=$($cmd /torrent/$torrent bytesDownloaded)
            dsize=$($cmd /torrent/$torrent bytesToDownload)
            speed=$($cmd /torrent/$torrent downloadSpeed)
            seed=$($cmd /torrent/$torrent seedersConnected)
            leech=$($cmd /torrent/$torrent leechersConnected)
            sl=$(printf "[%d|%d]" $seed $leech)
            priority=$($cmd /torrent/$torrent priority)
            pri=$(printf "(%d)" $priority)
            name=$($cmd /torrent/$torrent name)
            #size=$($cmd /torrent/$torrent totalSize)
            printf "%3.0lf%% of %11d %4.0lf kb/s %8s %4s %s\n" $((100*$prog/$dsize)) $dsize $(($speed/1000)) "$sl" "$pri" "$name"
            i=$(($i+1))
        done ;;
    start|stop|name|remove|files)
        if (( ${#2} < 4 )); then
            torrents=($($cmd /core torrents))
            torrent=${torrents[$2]}
        else torrent=$2; fi

        case "$1" in
            start)
                if [ ! $torrent ]; then res=$($cmd /core startAll)
                else res=$($cmd /core start $torrent); fi ;;
            stop)
                if [ ! $torrent ]; then res=$($cmd /core stopAll)
                else res=$($cmd /core stop $torrent); fi ;;
            name)
                if [ ! $torrent ]; then echo "torrent [id] missing or torrent does not exist!"
                else $cmd /torrent/$torrent name; fi ;;
            remove)
                # qdbus boolean bug workaround: use dbus-send instead
                if [ ! $torrent ]; then echo "torrent [id] missing!"
                else res=$(dbus-send --type=method_call --dest=$loc /core org.ktorrent.core.remove string:"$torrent" boolean:false); fi ;;
            files)
                if [ ! $torrent ]; then n=0
                else n=$($cmd /torrent/$torrent numFiles); fi

                for (( i=0; i < $n; i++ )); do
                    pct=$($cmd /torrent/$torrent filePercentage $i)
                    size=$($cmd /torrent/$torrent fileSize $i)
                    priority=$($cmd /torrent/$torrent filePriority $i)
                    path=$($cmd /torrent/$torrent filePath $i)
                    printf "%d %3.0lf%% of %11d [%d] %s\n" $i $pct $size $priority "$path"
                done ;;
        esac ;;
    pri|priority|prioritize)
        if [ "$3" ]; then
            if (( ${#2} < 4 )); then
                torrents=($($cmd /core torrents))
                torrent=${torrents[$2]}
            else torrent=$2; fi

            if [ ! $torrent ]; then
                echo "torrent does not exist!"
                exit
            fi

            if [ "$4" ]; then res=$($cmd /torrent/$torrent setFilePriority $3 $4)
            else
                n=$($cmd /torrent/$torrent numFiles)

                case "$3" in
                    equal|equalize)
                        for (( i=0; i < $n; i++ )); do
                            res=$($cmd /torrent/$torrent setFilePriority $i 40)
                        done ;;
                    inc|increasing)
                        for (( i=0; i < $n; i++ )); do
                            pri=$(printf "%2.0lf" $(((4*$i/$n+3)*10)))
                            res=$($cmd /torrent/$torrent setFilePriority $i $pri)
                        done ;;
                    dec|decreasing)
                        for (( i=0; i < $n; i++ )); do
                            pri=$(printf "%2.0lf" $(((4*($n-$i-1)/$n+3)*10)))
                            res=$($cmd /torrent/$torrent setFilePriority $i $pri)
                        done ;;
                    first)
                        m=$(($n < 3 ? $n : 3))
                        for (( i=0; i < $m; i++ )); do
                            res=$($cmd /torrent/$torrent setFilePriority $i $(((6-$i)*10)))
                        done
                        for (( i=3; i < $n; i++ )) do
                            res=$($cmd /torrent/$torrent setFilePriority $i 30)
                        done ;;
                    *)
                        res=$($cmd /torrent/$torrent setPriority $3) ;;
                esac
            fi
        else echo "too few arguments!"; fi ;;
    mur)
        if [ "$2" ]; then
            $cmd /settings setMaxUploadRate $2
            res=$($cmd /settings apply)
        else echo "upload rate [mur] missing!"; fi ;;
    mdr)
        if [ "$2" ]; then
            $cmd /settings setMaxDownloadRate $2
            res=$($cmd /settings apply)
        else echo "download rate [mdr] missing!"; fi ;;
    suspend)
        res=$($cmd /core org.ktorrent.core.setSuspended true) ;;
    resume)
        res=$($cmd /core org.ktorrent.core.setSuspended false) ;;
    clear)
        torrents=$($cmd /core torrents)
        for torrent in $torrents; do
            res=$(dbus-send --type=method_call --dest=$loc /core org.ktorrent.core.remove string:"$torrent" boolean:false)
        done ;;
    quit)
        res=$($cmd /MainApplication quit) ;;
    *)
        echo "unrecognized command: '$1'" ;;
esac
