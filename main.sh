#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/manager.conf

source $DIR/functions/workers_to_array.func
source $DIR/functions/get_rig_stats.func
source $DIR/functions/print_stats.func #includes print_full_stats() print_short_stats() print_problem_stats()
source $DIR/functions/sendtext.func #includes sendtext() send_message_from_file()
source $DIR/functions/notify.func
source $DIR/functions/check_existence.func
source $DIR/functions/commands.func #includes sonoff_stop() sonoff_start() softres() softstop() rigres() rigstop()
source $DIR/functions/setzero.func


workers_file="$DIR/workers.txt"

declare -A rigs=()
# This array is used for all rigs names from workers.txt
declare -a allRigsNames=()
# This array is used only for selection of rigs
declare -a chosenNames=()

workers_to_array $workers_file > /dev/null
#chosenNames=("${allRigsNames[@]}")

#printf "RIGs: ${#chosenNames[@]}"

chosenNames=("${@:2}")

format_and_check() {

if [ "${chosenNames[0]}" = 'all' ]; then
chosenNames=("${allRigsNames[@]}")
else
check_existence
fi

}

case "$1" in
	("") ;;
        ("help") result="Help" ;;
        ("pinger") format_and_check ; get_rig_stats > /dev/null ; print_short_stats ;;
        ("rigres") format_and_check ; printf "RIG Restart command is running in background.\nAffected: ${chosenNames[*]}\n" ; rigres > /dev/null & ;;
        ("softres")  format_and_check ; softres ;;
        ("rigstop") format_and_check ; printf "RIG STOP command is running in background.\nAffected: ${chosenNames[*]}\n" ; rigstop > /dev/null & ;;
        ("rigstart") format_and_check ; sonoff_start ;;
        ("full") chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; print_full_stats ;;
	("recheck") chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; notify ; print_problem_stats > $hash_checker_results_file; printf "Recheck done! New result: /cache" ;;
        ("cron") chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; notify ; print_problem_stats > $hash_checker_results_file ;;
        ("cache") cat $hash_checker_results_file;;
        ("setzero") format_and_check ; setzero | jq ;;
        ("custom1") $DIR/custom_scripts/custom1.sh ;;
	(*) printf "Unknown command!\n" ;;
esac

#printf "RESULT:\n"
#printf '%s\n' "$result"
#printf "\n"
