#!/bin/bash

usage(){
    printf "Add/update/remove entries from /etc/hosts file.\n\n"
    printf "Single update:\n"
    printf "\tadd HOST_NAME IP_ADDRESS\n"
    printf "\tremove HOST_NAME IP_ADDRESS\n"
    printf "\tupdate HOST_NAME IP_ADDRESS\n\n"
    printf "Bulk update:\n"
    printf "\tbulk add FILE_NAME\n"
    printf "\tbulk remove FILE_NAME\n"
    printf "\tbulk update FILE_NAME\n\n"
    printf "\tThe file should be comma delimented to show hostname,ip\n\n"
    printf "${RED}Exiting...${WHITE}\n";
}


BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'

main(){
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$2" ]; then
        usage
        exit 1;
    fi

    if [ "$1" = "bulk" ]; then
        while IFS=',' read -r hostname ip_address || [ -n "$hostname" ]; do 
            printf "${BLUE}Working $hostname\n${WHITE}"
            # Echo a 1 so if the hosts is found it will be updated. 
            echo 1 | edit_host $2 $hostname $ip_address
            echo
        done <$3
    else
        edit_host $1 $2 $3
    fi

}

edit_host(){

    # insert/update hosts entry
    host_name="$2"
    ip_address="$3"


    # find existing instances in the host file and save the line numbers
    matches_in_hosts="$(grep -n $host_name /etc/hosts | cut -f1 -d:)"
    host_entry="${ip_address} ${host_name}"

    $1

}

remove() {
    if [ ! -z "$matches_in_hosts" ]; then
        echo "$host_name found in /etc/hosts. Removing now...";
        # iterate over the line numbers on which matches were found
        while read -r line_number; do
            # remove the text of each line that matches the host name.
            sudo sed -i "${line_number}d" /etc/hosts

        done <<< "$matches_in_hosts"
    else
       printf "${RED}$host_name was not found in /etc/hosts${WHITE}\n";
    fi
}

add() {
    if [ ! -z "$matches_in_hosts" ]; then
        printf "${GREEN}$host_name exists.\n${WHITE}"
        echo "Would you like to update it?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) update; break;;
                No ) printf "${RED}Exiting${WHITE}\n"; exit;;
            esac
        done
    else
        echo "Adding new hosts entry."
        echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
    fi
}

update() {
    if [ ! -z "$matches_in_hosts" ]
    then
        echo "Updating existing hosts entry."
        # iterate over the line numbers on which matches were found
        while read -r line_number; do
            # replace the text of each line with the desired host entry
            sudo sed -i "${line_number}s/.*/${host_entry} /" /etc/hosts
        done <<< "$matches_in_hosts"
    else
        printf "${RED}$host_name was not found in /etc/hosts${WHITE}\n";
    fi
}

main "$@"
