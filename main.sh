#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/manager.conf

source $DIR/functions/workers_to_array.func
source $DIR/functions/get_rig_stats.func
source $DIR/functions/print_stats.func #includes print_full_stats() print_short_stats() print_problem_stats()
source $DIR/functions/sendtext.func
source $DIR/functions/notify.func
source $DIR/functions/check_existence.func

workers_file="$DIR/workers.txt"

declare -A rigs=()
# This array is used for all rigs names from workers.txt
declare -a allRigsNames=()
# This array is used only for selection of rigs
declare -a chosenNames=()

workers_to_array $workers_file > /dev/null
#chosenNames=("${allRigsNames[@]}")

#printf "RIGNAMES: ${chosenNames[2]}"

case "$1" in
	("") ;;
        ("help") result="Help" ;;
        ("pinger") result=`chosenNames=("${@:2}") ; check_existence ; get_rig_stats > /dev/null ; print_short_stats` ;;
        ("rigres")  ;;
        ("rigstop") ;;
        ("rigstart") ;;
        ("softres")  ;;
        ("full") result=`chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; print_full_stats` ;;
	("recheck") result=`chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; notify ; print_full_stats > $hash_checker_results_file; cat $hash_checker_results_file` ;;
        ("cache") result=`cat $hash_checker_results_file`;;
        ("cron") result=`chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; notify ; print_full_stats > $hash_checker_results_file; cat $hash_checker_results_file` ;;
        ("custom1") result=`$DIR/custom_scripts/custom1.sh` ;;
	(*) result="Unknown command!" ;;
esac

#printf "RESULT:\n"
printf "%s\n" "$result"
