#!/bin/bash

[ -f /opt/rh/ruby193/enable ] && source /opt/rh/ruby193/enable

if [ $# -eq 0 ]
then
    echo >&2 "no recipes given, aborting here"
    exit 1
else
    recipes=( "$@" )
    echo "running recipes: ${recipes[*]}"
fi

for recipe in "${recipes[@]}"
do
    if [ -d "/data/recipes/${recipe}" ]
    then
        cd "/data/recipes/${recipe}" && (
            [ -x ./prepare.sh ] && ./prepare.sh
            if [ -r ./recipe.rb ]
            then
                [ -d "$DIST" ] || mkdir "$DIST"
                fpm-cook package --no-deps --pkg-dir="$DIST" \
                    | tee /dev/stderr \
                    | grep '===> Created package:' \
                    | awk -F '/' '{print $NF}' > "$DIST"/lastbuild
           fi
        )
    fi
done
