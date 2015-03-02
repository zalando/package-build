#!/bin/bash

if [ -r /vagrant/recipes.list ]
then
    cat /vagrant/recipes.list | while read recipe
    do
        [ "$recipe" == "" ] && continue

        cd /vagrant/recipes/${recipe}/ && (
            [ -x ./prepare.sh ] && ./prepare.sh
            fpm-cook
        )
    done
fi
