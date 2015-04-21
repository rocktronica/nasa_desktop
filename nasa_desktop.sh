#!/bin/bash

{
    function set_desktop() {
        sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db \
            "update data set value = '$1'" \
            && killall Dock
    }

    function download_image() {
        if [ -f $1 ]; then
            echo "Today's image has already been downloaded"
        else
            image_url=$(phantomjs get_url.js)
            echo "$image_url\n"
            curl $image_url > $1
        fi
    }

    filename="images/ap$(date "+%y%m%d").jpg"

    download_image $filename
    set_desktop $PWD/$filename
}
