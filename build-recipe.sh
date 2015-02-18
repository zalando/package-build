#!/bin/bash

if [ -r /vagrant/build-recipe ]
then
    source /vagrant/build-recipe
    [ "$BUILD_RECIPE" == "" ] && exit 0

    cd /vagrant/recipes/${BUILD_RECIPE}/ && (
        [ -x ./pre-configure.sh ] && ./pre-configure.sh
        fpm-cook
        rm /vagrant/build-recipe
    )
fi
