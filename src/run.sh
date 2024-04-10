#!/bin/bash

## constants
readonly local run="java -cp ../target/os-coursework1-1.0-SNAPSHOT.jar"
##readonly local run="java -cp target/classes"  ## (works either way, can use either classed or snapshot.jar)
readonly local schedulers=(RRScheduler SJFScheduler FcfsScheduler FeedbackRRScheduler IdealSJFScheduler)


## input parameters
# shellcheck disable=SC2034
readonly local seeds_for_each_exp=5
readonly local exp_1_seed=(50 100 150 200 565)
readonly local exp_2_seed=(1222 5669 94111 123422 156555)
readonly local exp_3_seed=(1244 5122 6297 898320 9999999)


## input parameters
## (number_of_processes, static_priority, mean_inter_arrival, mean_cpu_burst, mean_io_burst, mean_number_bursts)
readonly local exp_1_input_param=(50 0 12 10 10 6)
readonly local exp_2_input_param=(25 0 12 4 24 10)
readonly local exp_3_input_param=(30 0 20 5 35 4)

## simulator parameters (excluding scheduling algorithm)
# (time_limit, interrupt_time, time_quantum, initial_burst_estimate, alpha_burst_estimate, periodic)
readonly local exp_1_sim_param=(100000 1 5 5 0.5 false)
readonly local exp_2_sim_param=(5000 10 4 14 0.5 false)
readonly local exp_3_sim_param=(5000 10 20 30 0.7 false)

# only for experiment 4 which is exp3 improved by manipulating its parameters

readonly local exp_3_sim_param_improved=(5000 10 20 15 0.4 false)



### receives input parameters in form of: (file_to_write_to, number_of_processes, static_priority, mean_inter_arrival, mean_cpu_burst, mean_io_burst, mean_number_bursts, seed)
write_input_parameters() {
local file_name=$1
local number_of_processes=$2
local static_priority=$3
local mean_inter_arrival=$4
local mean_cpu_burst=$5
local mean_io_burst=$6
local mean_number_bursts=$7
local seed=$8

local serialized="numberOfProcesses=$number_of_processes\nstaticPriority=$static_priority\nmeanInterArrival=$mean_inter_arrival\nmeanCpuBurst=$mean_cpu_burst\nmeanIoBurst=$mean_io_burst\nmeanNumberBursts=$mean_number_bursts\nseed=$seed"

printf $serialized >$file_name

echo "written input params to $file_name"

}

## generate input data using the parameters file. expects the params in form of: (input_parameters_file, output_file)
gen_input_data() {
local parameters_file=$1
local data_file_to_write=$2

$run InputGenerator $parameters_file $data_file_to_write >/dev/null 2>&1

echo "generated the input data in $data_file_to_write"
}

# writes simulator parameters to a file. receives (file_to_write_to, scheduler_to_use, time_limit, interrupt_time, time_quantum, initial_burst_estimate, alpha_burst_estimate, periodic)
write_sim_params() {
local simulator_parameters_file=$1
local scheduler_to_use=$2
local time_limit=$3
local interrupt_time=$4
local time_quantum=$5
local initial_burst_estimate=$6
local alpha_burst_estimate=$7
local periodic=$8

local serialized="scheduler=$scheduler_to_use\ntimeLimit=$time_limit\ninterruptTime=$interrupt_time\ntimeQuantum=$time_quantum\ninitialBurstEstimate=$initial_burst_estimate\nalphaBurstEstimate=$alpha_burst_estimate\nperiodic=$periodic"

printf $serialized >$simulator_parameters_file

echo "written sim params to $simulator_parameters_file"

}

## runs the simulator with parameters: (simulator_file, input_data_file, output_path)
run_sim() {
local simulator_parameters_file=$1
local input_data_file=$2
local output_file=$3

$run Simulator $simulator_parameters_file $output_file $input_data_file >/dev/null 2>&1
}

## runs a whole experiment, expects a number from 1 to 3 as a parameter
run_exp()  {

local folder="../experiment$1"
echo "running Experiment $1"

mkdir -p $folder

local input_params
local sim_params
local seeds

if [ $1 -eq 1 ]; then
input_params="${exp_1_input_param[@]}"
sim_params="${exp_1_sim_param[@]}"
seeds="${exp_1_seed[@]}"
elif [ $1 -eq 2 ]; then
input_params="${exp_2_input_param[@]}"
sim_params="${exp_2_sim_param[@]}"
seeds="${exp_2_seed[@]}"
elif [ $1 -eq 3 ]; then
input_params="${exp_3_input_param[@]}"
sim_params="${exp_3_sim_param[@]}"
seeds="${exp_3_seed[@]}"

elif [ $1 -eq 4 ]; then
input_params="${exp_3_input_param[@]}"
sim_params="${exp_3_sim_param_improved[@]}"
seeds="${exp_3_seed[@]}"

else

echo "Invalid experiment number!"
exit 1
fi

mkdir -p $folder/input_files

# shellcheck disable=SC2068
for seed in ${seeds[@]}; do
local data_file="$folder/input_files/input_data_$seed.in"
local input_params_file="$folder/input_files/input_parameters_seed_$seed.prp"
write_input_parameters $input_params_file $input_params $seed
gen_input_data  $input_params_file $data_file
done

for scheduler in "${schedulers[@]}"; do
echo "----------- running $scheduler -----------"
mkdir -p $folder/scheduler_outputs/$scheduler $folder/simulator_parameters
local sim_params_file="$folder/simulator_parameters/${scheduler}_simulator_parameters.prp"
write_sim_params $sim_params_file $scheduler $sim_params

# shellcheck disable=SC2068
for seed in ${seeds[@]}; do
local input_data_file="$folder/input_files/input_data_$seed.in"
echo "----------- running with seed: $seed... -----------"
run_sim $sim_params_file $input_data_file "$folder/scheduler_outputs/$scheduler/output_seed_$seed.out"
echo "------- Finished running $scheduler --------"
done
done

}

main() {
    for i in 1 2 3 4
    do
        run_exp $i
    done
}

main