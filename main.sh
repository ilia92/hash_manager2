#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/functions/workers_to_array.func
source $DIR/functions/get_real_stats.func

declare -A rigs=()
declare -a rigNames=()

workers_file="$DIR/workers.txt"

workers_to_array $workers_file

for rig in "${rigNames[@]}"; do
    get_real_stats $rig
done

    printf "NAME\t\ttaget\tminer\tIP\t\ttasmota_IP\treal\th_diff\tperc\tis_issue\n"
for rig in "${rigNames[@]}"; do
    printf "$rig\t${rigs[${rig}_name]}\t${rigs[${rig}_target_hash]}\t${rigs[${rig}_miner]}\t${rigs[${rig}_ip]}\t${rigs[${rig}_tasmotaip]}\t${rigs[${rig}_real_hash]}\t${rigs[${rig}_hash_diff]}\t${rigs[${rig}_hash_diff_perc]}\t${rigs[${rig}_is_issue]}\n"
done
