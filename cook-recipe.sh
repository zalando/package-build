#!/bin/bash

[ -f /opt/rh/ruby193/enable ] && source /opt/rh/ruby193/enable

if [ $# -eq 0 ]
then
    recipes=( $( ls -1 /data/recipes/ ) )
    echo "No folders given, so running all recipes: ${recipes[*]}"
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
                git checkout .
                sed -i "s/\(^[[:space:]]*revision[[:space:]]*\)\([[:digit:]]\{12\}\)$/\1$(date +%Y%m%d%H%M)/" ./recipe.rb
                [ -d "$DIST" ] || mkdir "$DIST"
                fpm-cook package --no-deps --pkg-dir="$DIST" \
                    | tee /dev/stderr \
                    | grep '===> Created package:' \
                    | awk -F '/' '{print $NF}' > "$DIST"/lastbuild
           fi
        )
    fi
done
