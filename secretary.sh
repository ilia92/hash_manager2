#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/main.sh

if [ -z "$STY" ]; then
printf "Bot started in background\n"
screen -S secretary_bot -X quit > /dev/null
exec screen -dm -S secretary_bot /bin/bash $0
fi

refresh_rate=1

curl --silent https://api.telegram.org/bot$telegram_api_key/getMe | jq
username=`curl --silent https://api.telegram.org/bot$telegram_api_key/getMe | jq -M -r .result.username`
date

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

#printf "Command: $command\tArgument: $arg\n"

case "$command" in
	("") ;;
	("/test") result="Telegram API Test PASS!" ;;
        ("/help") result="$help_section" ;;
        ("/pinger") result=`$DIR/main.sh pinger $arg`;;
        ("/rigres") result=`$DIR/main.sh rigres $arg` ;;
        ("/softres") result=`$DIR/main.sh softres $arg` ;;
        ("/rigstop") result=`$DIR/main.sh rigstop $arg` ;;
        ("/rigstart") result=`$DIR/main.sh rigstart $arg` ;;
        ("/schedule") result=`$DIR/main.sh schedule $arg` ;;
        ("/full") result=`$DIR/main.sh full` ;;
	("/recheck") result=`$DIR/main.sh recheck` ;;
        ("/cache") result=`$DIR/main.sh cache` ;;
        ("/custom1") result=`$DIR/main.sh custom1` ;;
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
