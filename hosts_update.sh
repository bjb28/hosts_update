#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'


if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
   printf "Example Usage: \n"
   printf "\tadd HOST_NAME IP_ADDRESS\n"
   printf "\tremove HOST_NAME IP_ADDRESS\n"
   printf "\tupdate HOST_NAME IP_ADDRESS\n\n"
   printf "${RED}Exiting...${WHITE}\n";
   exit 1;
fi


# insert/update hosts entry
host_name="$2"
ip_address="$3"


# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $host_name /etc/hosts | cut -f1 -d:)"
host_entry="${ip_address} ${host_name}"

echo "Please enter your password if requested."

remove() {
    if [ ! -z "$matches_in_hosts" ]
    then
        echo "$host_name found in /etc/hosts. Removing now...";
        # iterate over the line numbers on which matches were found
        while read -r line_number; do
            # remove the text of each line that matches the host name.
            sudo sed -i "${line_number}d" /etc/hosts

        done <<< "$matches_in_hosts"
    else
       printf "${RED}$host_name was not found in /etc/hosts${WHITE}";
    fi
}

add() {
    if [ ! -z "$matches_in_hosts" ]
    then
        printf "${GREEN}$host_name exists.\n${WHITE}"
        echo "Would you like to update it?"
        select yn in "Yes" "No"; do
            case $yn in
                Yes ) update; break;;
                No ) printf "${RED}Exiting${WHITE}"; exit;;
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
        printf "${RED}$host_name was not found in /etc/hosts${WHITE}";
    fi
}

$@
