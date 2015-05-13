#!/bin/bash

{
    opt_force_downloads=false
    opt_show_help=false

    while getopts :d:fh flag; do
        case $flag in
            f) opt_force_downloads=true ;;
            h) opt_show_help=true ;;
        esac
    done

    if $opt_show_help; then
        echo "\
A script to download NASA's \"Image of the Day\" and
set it as the desktop background.

http://www.nasa.gov/multimedia/imagegallery/iotd.html

Options:
    -f      Ignore cache and force downloads anew.
"
        exit
    fi

    rss_feed_url='http://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss'
    cache_feed_filename="$PWD/cache/$(date "+%y%m%d").rss"

    mkdir -p $PWD/cache
    mkdir -p $PWD/images

    function download_rss() {
        if [ ! -f $cache_feed_filename ] || $opt_force_downloads; then
            echo "Downloading RSS: $rss_feed_url"
            curl -# -L $rss_feed_url > $cache_feed_filename
            echo
        fi
    }

    function get_absolute_image_url() {
        image_pathname=$(
            cat $cache_feed_filename |
                grep -oE "[^'\"]*.(jpg|png)" |
                head -n 1
        )
        [[ -z "$image_pathname" ]] || echo $image_pathname
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
        if [ ! -f $image_filename ] || $opt_force_downloads; then
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

    pushd $(dirname $0) > /dev/null

    download_rss
    download_image
    set_desktop

    popd > /dev/null
}
