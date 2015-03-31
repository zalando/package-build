#!/bin/bash

if [ $# -eq 0 ]
then
    recipes=( $( ls -1 /vagrant/recipes/ ) )
    echo "No folders given, so running all recipes: ${recipes[*]}"
else
    recipes=( "$@" )
    echo "running recipes: ${recipes[*]}"
fi

for recipe in "${recipes[@]}"
do
    if [ -d "/vagrant/recipes/${recipe}" ]
    then
        cd "/vagrant/recipes/${recipe}" && (
            [ -x ./prepare.sh ] && ./prepare.sh
            [ -r ./recipe.rb ] && fpm-cook package --pkg-dir="$RELEASE"
        )
    fi
done
exit 0
