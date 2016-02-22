#!/bin/bash
set -e
set -x

LONGVERSION=$(sed -n 's|\s*version\s*"\(.*\)"|\1|p' recipe.rb)
RESOURCES=(
AppServerAgent.zip
MachineAgent.zip
appdynamics-machine.sh
appdynamics-params.sh
custom-activity-correlation.xml
transactions.xml
monitor.xml
)

# build basic directory structure
[ -d cache/rootfs/server ] || mkdir -p cache/rootfs/server
[ -d cache/rootfs/usr/local/bin ] || mkdir -p cache/rootfs/usr/local/bin

# download resources
for RESOURCE in "${RESOURCES[@]}"
do
    [ -f cache/"${RESOURCE}" ] || curl -kL --progress-bar -o cache/"${RESOURCE}" https://repo.zalando/static/appdynamics/"${RESOURCE}"
done

# put everything in place
[ -d cache/rootfs/server/appdynamics/appdynamics-jvm ] \
    || mkdir -p cache/rootfs/server/appdynamics/appdynamics-jvm
unzip -o cache/AppServerAgent.zip -d cache/rootfs/server/appdynamics/appdynamics-jvm

[ -d cache/rootfs/server/appdynamics/appdynamics-machine ] \
    || mkdir -p cache/rootfs/server/appdynamics/appdynamics-machine
unzip -o cache/MachineAgent.zip -d cache/rootfs/server/appdynamics/appdynamics-machine

cp cache/*.xml cache/rootfs/server/appdynamics/appdynamics-machine/conf/
cp cache/*.xml cache/rootfs/server/appdynamics/appdynamics-machine/monitors/analytics-agent/conf
cp cache/*.xml cache/rootfs/server/appdynamics/appdynamics-jvm/conf
cp cache/*.xml cache/rootfs/server/appdynamics/appdynamics-jvm/ver"${LONGVERSION}"/conf/
cp cache/monitor.xml cache/rootfs/server/appdynamics/appdynamics-machine/monitors/analytics-agent/

cp cache/*sh cache/rootfs/usr/local/bin
find cache/rootfs -type f -name '*sh' -exec chmod +x {} \;

# The tar will have ./cache/rootfs as top-most structure,
# but fpm-cookert will skip `cache/` so `root("/").install Dir["rootfs/*"]`
# creates the .deb content correctly.
tar caf cache/appdynamics.tgz cache/rootfs/
