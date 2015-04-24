#!/bin/bash

{
    path='http://apod.nasa.gov/apod'
    date_slug=$(date "+%y%m%d")
    image_filename="$PWD/images/$date_slug.jpg"
    cache_page_filename="$PWD/cache/ap$date_slug.html"

    function download_page() {
        if [ ! -f $cache_page_filename ]; then
            curl -# -L $path/ap$date_slug.html \
                > $cache_page_filename
        fi
    }

    function get_absolute_jpg_url() {
        echo $path/$(
            cat $cache_page_filename |
                grep -oE "href=[^>]*" | \
                grep -oE "[^'\"]*.jpg"
        )
    }

    function download_image() {
        if [ ! -f $image_filename ]; then
            image_url=$(get_absolute_jpg_url)
            echo "$image_url\n"
            curl -# $image_url > $image_filename
        fi
    }

    function set_desktop() {
        sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db \
            "update data set value = '$image_filename'" \
            && killall Dock
    }

    download_page
    download_image
    set_desktop
}
