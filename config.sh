#!/bin/bash

#cosmetic stuff
hline=$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)

#check if docker is online
aw=$(docker stats --no-stream)
if [ -z "${aw}" ]; then
    echo "Your docker daemon is offline. Please start your docker daemon first!"
    echo "Call On MacOS: 'open /Applications/Docker.app'"
    exit 1
fi

#load settings
source config.conf

#get and goto current directory (required to keep relative links working)
folder="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd "${folder}"

#abort if no subcommands given
if [ $# -lt 1 ]; then
    echo "no subcommands supplied."
    echo "Usage: ./$0 {run|start|uninstall|check|tabularasa|check}"
    exit 1
fi


#loop over all arguments
for inarg in "$@"; do 
#for each $inarg do case-switch
case "${inarg}" in
build)
    echo $hline
    echo "Nothing to build"
    ;;
run)
    echo $hline
    echo "Create data container '${datacontainer}' if not exist"
    docker volume create --name "${datacontainer}"

    echo "Instantiate container '${containername}' from the '${pg_image}:${pg_version}' image now"
    docker run -it \
        --name "${containername}" \
        -v "${datacontainer}:/var/lib/postgresql/data" \
        -p "${containerport}:5432" \
        -d "${pg_image}:${pg_version}" 
    echo "*** Container Instantiation Completed ***"

    echo "Install SQL in the container"
    until pg_isready -h localhost -p ${containerport} -U postgres; do sleep 1; done
    psql -h localhost -p ${containerport} -U postgres -w -f install.sql
    echo "*** install.sql injected ***"
    ;;
start)
    #no fancy echo/print messages
    docker start ${containername} #use -a to see logs
    ;;
uninstall)
    echo $line
    echo "Delete '${containername}' now"
    docker stop ${containername}
    docker rm ${containername}
    echo "*** Container deleted ***"
    echo "    Type 'docker rmi ${pg_image}:${pg_version}' to delete the base image."
    echo "    Type 'docker volume rm ${datacontainer}' to delete the data volume."
    ;;
tabularasa)
    echo $line
    echo "Delete container '${containername}' now"
    docker stop "${containername}"
    docker rm "${containername}"
    echo "Delete data volume '${datacontainer}' now"
    docker volume rm "${datacontainer}"
    echo "Delete image '${pg_image}:${pg_version}' now"
    docker rmi "${pg_image}:${pg_version}"
    ;;
check)
    echo $line
    echo "Base Image exits at ... "
    docker images | grep "${pg_image}" | grep "${pg_version}"
    echo $line
    echo "Container runs at ... "
    docker ps -a | grep ${containername}
    echo $line
    echo "Data Volume exits at ... "
    docker volume ls | grep ${datacontainer}
    ;;
*)
    echo "Usage: ./$0 {run|start|uninstall|tabularasa|check}"
    exit 1
esac #end case-switch
done #end for-loop

#successfully done
exit 0
