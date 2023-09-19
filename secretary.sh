#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/main.sh
#source $DIR/manager.conf
#source $DIR/functions/sendtext.func

#if [ -z "$STY" ]; then
#printf "Bot started in background\n"
#screen -S secretary_bot -X quit > /dev/null
#exec screen -dm -S secretary_bot /bin/bash $0
#fi

refresh_rate=1

curl --silent https://api.telegram.org/bot$telegram_api_key/getMe | jq
username=`curl --silent https://api.telegram.org/bot$telegram_api_key/getMe | jq -M -r .result.username`
date

help_section="
/help - Prints this text
/pinger name - Check if rig is UP
/rigres name - Restarts rig
/softres name - Soft restart for a rig
/full - Check all rigs
/recheck - Rechecks rig hashrate
/cache - Shows cached results
"

while [ 1 ]
do

curr_message=`curl --silent -s "https://api.telegram.org/bot$telegram_api_key/getUpdates?timeout=600&offset=$update_id"`
last_upd_id=`printf "$curr_message" |  jq '.result | .[] | .update_id' | tail -1`

if [[ $update_id -le $last_upd_id ]]; then
update_id=$((last_upd_id+1))

curr_message_text=`printf "$curr_message" | jq -r '.result | .[].message.text' | tail -1`

if [[ "$curr_message_text" ]]; then
printf "Message received: $curr_message_text\n"
# clear last message
curl -s "https://api.telegram.org/bot$telegram_api_key/getUpdates?offset=$update_id"  >/dev/null 2>&1
fi

command=`echo $curr_message_text | grep -o '\/.*' | awk {'print $1'} | sed "s|@$username||g"`
# Get everything after the 1st
arg=`echo $curr_message_text | awk '{$1=""}1'`

printf "$command and $arg"

case "$command" in
	("") ;;
	("/test") result="Telegram API Test PASS!" ;;
        ("/help") result="$help_section" ;;
        ("/pinger") result=`chosenNames=($arg) ; check_existence ; get_rig_stats > /dev/null ; print_short_stats`;;
        ("/rigres") result=`` ;;
        ("/softres") result=`` ;;
        ("/full") result=`chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; print_short_stats` ;;
	("/recheck") chosenNames=("${allRigsNames[@]}") ; get_rig_stats > /dev/null ; notify ; print_short_stats > $hash_checker_results_file ; result="Recheck done! New result: /cache" ;;
        ("/cache") result=`cat $hash_checker_results_file` ;;
        ("/custom1") result=`$DIR/custom_scripts/custom1.sh` ;;
	(*) result="Unknown command!" ;;
esac

if [[ "$result" ]]; then
printf "\nResult:\n$result"
sendtext "$result"
fi

printf "\n\n"
fi

sleep $refresh_rate
done
