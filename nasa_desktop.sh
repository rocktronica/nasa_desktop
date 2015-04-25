#!/bin/bash

{
    path='http://apod.nasa.gov/apod'
    date_slug=$(
        [[ -z "$1" ]] && date "+%y%m%d" || echo $1
    )
    cache_page_filename="$PWD/cache/ap$date_slug.html"

    mkdir -p $PWD/cache
    mkdir -p $PWD/images

    function download_page() {
        if [ ! -f $cache_page_filename ]; then
            echo "Downloading page: $path/ap$date_slug.html"
            curl -# -L $path/ap$date_slug.html \
                > $cache_page_filename
        fi
    }

    function get_absolute_image_url() {
        echo $path/$(
            cat $cache_page_filename |
                grep -oE "href=[^>]*" | \
                grep -oE "[^'\"]*.(jpg|png)"
        )
    }

    function get_image_basename() {
        get_absolute_image_url | grep -oE "[^/]*\.[^/]*$"
    }

    function download_image() {
        image_filename="$PWD/images/$(get_image_basename)"

        if [ ! -f $image_filename ]; then
            image_url=$(get_absolute_image_url)
            echo "Downloading image: $image_url"
            curl -# $image_url > $image_filename
        fi
    }

    function set_desktop() {
        image_filename="$PWD/images/$(get_image_basename)"

        sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db \
            "update data set value = '$image_filename'" \
            && killall Dock
    }

    download_page
    download_image
    set_desktop
}
