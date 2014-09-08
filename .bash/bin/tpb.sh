#!/bin/bash

# Search torrents from thepiratebay 
# Change your torrent command TORRENT_PROG=
#
# tpb.sh <search term>
# Then select a Number

search() {
    TORRENT_PROG=aria2c
    RESULT_COUNT=20
    q="$*"
    q=`echo $q | tr ' ' '+'`
    results=`wget -U Mozilla -qO - "http://thepiratebay.org/search/$q/0/7/0" | zcat |  grep '<a href=\"magnet\:?xt=urn:btih:'` 
    I=0
    LINK_LIST=""
for line in $results
do
     TITLE=`echo $line |  sed 's/&tr=.*//' | sed -e 's/.*&dn=\(.*\)/\1/'`
     MAGNET_URL=`echo $line | sed 's/\" title.*//' | sed -e 's/<a href=\"\(.*\)/\1/'`
     LINK_LIST="$LINK_LIST$IFS$MAGNET_URL"
     I=`echo "$I + 1" | bc -l`
     echo "$I) `urldecode "$TITLE"`"
     if [ $I -eq $RESULT_COUNT ]
     then
        break
     fi

done
}
download() {
    echo -n "Download Nr.: "
    I=0
    read num
    for line in $LINK_LIST
    do
        I=`echo "$I + 1" | bc -l`
        if [ $I -eq $num ]
        then
            link=`echo "$line" | awk '{print $1}'`
            echo "Downloading torrent file."
            $TORRENT_PROG $link
            echo "Torrent added."
            exit 0
        fi
    done
}
urlencode() {
# urlencode <string>

    local length="${#1}"
        for (( i = 0; i < length; i++ )); do
            local c="${1:i:1}"
                case $c in
                [a-zA-Z0-9.~_-]) printf "$c" ;;
    *) printf '%%%02X' "'$c"
        esac
        done
}

urldecode() {
# urldecode <string>

    local url_encoded="${1//+/ }"
        printf '%b' "${url_encoded//%/\x}"
}

OLD_IFS=$IFS
IFS=$'\n'
search $*
download
IFS=$OLD_IFS

