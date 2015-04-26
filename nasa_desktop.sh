#!/bin/bash

{
    opt_date_slug=$(date "+%y%m%d")

    while getopts :d: flag; do
        case $flag in
            d) opt_date_slug=$OPTARG ;;
        esac
    done

    host_path='http://apod.nasa.gov/apod'
    cache_page_filename="$PWD/cache/ap$opt_date_slug.html"

    mkdir -p $PWD/cache
    mkdir -p $PWD/images

    function download_page() {
        if [ ! -f $cache_page_filename ]; then
            echo "Downloading page: $host_path/ap$opt_date_slug.html"
            curl -# -L $host_path/ap$opt_date_slug.html \
                > $cache_page_filename
            echo
        fi
    }

    function get_absolute_image_url() {
        image_pathname=$(
            cat $cache_page_filename |
                grep -oE "href=[^>]*" | \
                grep -oE "[^'\"]*.(jpg|png)" |
                head -n 1
        )
        [[ -z "$image_pathname" ]] || echo $host_path/$image_pathname
    }

    function get_image_basename() {
        get_absolute_image_url | grep -oE "[^/]*\.[^/]*$"
    }

    function download_image() {
        image_url=$(get_absolute_image_url)
        if [ ! "$image_url" ]; then
            echo "Couldn't find image"
            exit 1
        fi

        image_filename="$PWD/images/$(get_image_basename)"
        if [ ! -f $image_filename ]; then
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
