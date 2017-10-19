#!/bin/bash

# vagrant multi box handler
#
# Copyright (C) 2017 Marcus Hoffren <marcus@harikazen.com>.
# License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>.
# This is free software: you are free to change and redistribute it.
# There is NO WARRANTY, to the extent permitted by law.
#

### settings

provider="virtualbox"

case ${provider} in
    virtualbox);;
    your-provider-here);;
    *)
	error "Box type ${provider} not supported"
esac

### minimal error handler
error() {
    { echo -e "\n\e[91m*\e[0m ${@}\n" 1>&2; exit 1; }
}

### return first element > 0 from array, and exit
except() {
    local pstatus=("${PIPESTATUS[@]}") i
    for (( i = 0; i < ${#pstatus[@]}; i++ )); do
	[[ ${pstatus[${i}]} -gt 0 ]] && { echo -e "\n\e[91m*\e[0m ${1} - Return Code: ${pstatus[${i}]}\n"; exit; }
    done
}

### sanity check
type -p "which"  1>/dev/null || error "You need which to run this script"
type -p "$(which grep)" 1>/dev/null || error "You should probably reinstall your Linux"
type -p "$(which awk)" 1>/dev/null || error "You need awk to run this script"
type -p "$(which vagrant)" 1>/dev/null || error "You need vagrant to run this script"


### script arguments. as this script only accepts one argument it doesn't need to be that complicated
case ${1} in
    list)
	vagrant global-status; exit 0;;
    up)
	action="up";;
    suspend)
	action="suspend";;
    resume)
	action="resume";;
    halt)
	action="halt";;
    *)
	echo "Valid arguments are 'list', 'up', 'suspend', 'resume', or 'halt'"; exit 1;;
esac

### trying to keep external command calls to a minimum. my solution: fill them arrays with them datas
box_ids=( $( vagrant global-status | grep "${provider}" | awk '{ print $1 }'; except "array box_ids failed" ) ) # save box id's to array
box_states=( $( vagrant global-status | grep "${provider}" | awk '{ print $4 }'; except "array box_states failed" ) ) # save box states to array
box_names=( $( vagrant global-status | grep "${provider}" | grep -o '[^/]*$'; except "array box_names failed" ) ) # save box names to array

### since all arrays are (and should be!) equally large, arbitrarily loop through box_states array and take appropriate action
for (( i = 0; i < ${#box_states[@]}; i++ )); do
    case ${box_states[${i}]} in
	running)
	    if [[ ${action} == "up" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) is already in the state \033[1m${box_states[${i}]}\033[m, skipping"
	    elif [[ ${action} == "resume" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) is in the state \033[1m${box_states[${i}]}\033[m and can not be resumed, skipping"
	    else
		echo -e "${box_names[$i]} (${box_ids[$i]}) - Changing state from \033[1m${box_states[${i}]}\033[m to \033[1m${action}\033[m"
		{ vagrant "${action}" "${box_ids[$i]}"; except "vagrant ${action} ${box_ids[$i]} failed"; }
	    fi;;
	saved)
	    if [[ ${action} == "suspend" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) is already in the state \033[1m${box_states[${i}]}\033[m, skipping"
	    elif [[ ${action} == "resume" || ${action} == "halt" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) - Changing state from \033[1m${box_states[${i}]}\033[m to \033[1m${action}\033[m"
		{ vagrant "${action}" "${box_ids[$i]}"; except "vagrant ${action} ${box_ids[$i]} failed"; }
	    else
		echo -e "${box_names[$i]} (${box_ids[$i]}) is in the state \033[1m${box_states[$i]}\033[m. Use \033[1m${0##*/} resume\033[m"
	    fi;;
	poweroff)
	    if [[ ${action} == "halt" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) is already in the state \033[1m${box_states[${i}]}\033[m, skipping"
	    elif [[ ${action} == "suspend" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) is in the state \033[1m${box_states[${i}]}\033[m and can not be suspended, skipping"
	    else
		echo -e "${box_names[$i]} (${box_ids[$i]}) - Changing state from \033[1m${box_states[${i}]}\033[m to \033[1m${action}\033[m"
		{ vagrant "${action}" "${box_ids[$i]}"; except "vagrant ${action} ${box_ids[$i]} failed"; }
	    fi;;
	aborted)
	    if [[ ${action} == "up" ]]; then
		echo -e "${box_names[$i]} (${box_ids[$i]}) - Changing state from \033[1m${box_states[${i}]}\033[m to \033[1m${action}\033[m"
		{ vagrant "${action}" "${box_ids[$i]}"; except "vagrant ${action} ${box_ids[$i]} failed"; }
	    else
		echo -e "${box_names[$i]} (${box_ids[$i]}) is in the state \033[1m${box_states[$i]}\033[m, skipping"
	    fi;;
	*)
	    echo -e "${box_names[$i]} (${box_ids[$i]}) \033[1m${box_states[${i}]}\033[m not implemented";;
    esac

done; unset action box_ids box_states box_names i

exit 0
