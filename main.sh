#!/bin/bash

DIR="$(dirname "$(readlink -f "$0")")"

source $DIR/functions/workers_to_array.func
source $DIR/functions/get_real_stats.func
source $DIR/functions/get_all_stats.func
source $DIR/functions/print_all_stats.func

declare -A rigs=()
declare -a rigNames=()

workers_file="$DIR/workers.txt"

workers_to_array $workers_file

get_all_stats
results_table=`print_all_stats`

printf "$results_table\n"
