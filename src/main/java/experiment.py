import matplotlib.pyplot as plt
# import numpy as np
import pandas as pd

from utils import get_all_input_params, get_all_sim_params, get_output_data


class Experiment:

    def __init__(self, directory):

        self.directory = directory
        self.input_parameters_seed = get_all_input_params(directory + '/input_files')
        self.simulator_parameters = get_all_sim_params(directory + '/simulator_parameters')
        self.output_data = get_output_data(directory + '/scheduler_outputs')

    ####################
    def all_seeds(self):
        return [s for (s, _) in self.input_parameters_seed]

    ####################

    def get_output(self, scheduler):
        return self.output_data[scheduler][:]

    #####################

    def get_output_for_seed(self, scheduler, seed):
        if scheduler in self.output_data:
            for (s, df) in self.output_data[scheduler]:
                if s == seed:
                    return df
        # If no data is found, the following print statements will help diagnose why
        print(f"Scheduler '{scheduler}' not found in output data.")  # Additional debugging print
        if scheduler in self.output_data:
            print(
                f"Available seeds for '{scheduler}': {[s for (s, _) in self.output_data[scheduler]]}")  # Additional
            # debugging print
        return None

    ######################

    def get_input_params(self, seed: str):
        return self.input_parameters_seed[seed]

    ######################

    #  Returns a dataframe of a column for all combinations of schedulers and all seeds
    def get_output_col(self, col: str):
        res = pd.DataFrame()
        for scheduler in self.output_data:

            for (seed, df) in self.output_data[scheduler]:
                res[scheduler + '_' + seed] = df[col]
        return res

    #####################

    def calculate_cpu_utilization_for_output(self, scheduler: str, seed: str):
        df = self.get_output_for_seed(scheduler, seed)

        idle_process = df.loc['idle_process']

        total_processes = df.cpuTime.sum()

        return 100 - ((total_processes - idle_process.cpuTime) / total_processes)

    #####################

    def plot_gantt(self, scheduler: str, seed: str, sort_by: str = 'startedTime'):
        fig, ax = plt.subplots(1, 1, figsize=(16, 8))

        df = self.get_output_for_seed(scheduler, seed)

        df = df.sort_values(by=sort_by)

        ax.set_xlabel('Time')
        ax.set_ylabel('Process')

        ax.set_title(f"{self.directory}: Gantt chart for {scheduler} with seed {seed} processes sorted by {sort_by}")

        # Plotting the gantt chart
        ax.barh(df.index, df.terminatedTime - df.startedTime,
                left=df.startedTime,
                color='blue',
                label='Started -> Terminated',
                alpha=0.5,
                )

        # Mark arrival time
        ax.barh(df.index, df.startedTime - df.createdTime, left=df.createdTime, color='red', alpha=1,
                label="WaitingTime")

        ax.set_yticks(list(range(df.id.max() + 1)))

        ax.legend()

    ########################

    def plot_gantt_all(self, scheduler: str):
        for i, (seed, _) in enumerate(self.input_parameters):
            self.plot_gantt(scheduler, seed)

    #########################

    def __str__(self):
        return 'Experiment: ' + self.directory

    def plot_cols_for_output(self, scheduler: str, seed: str, cols=None, sort_by: str = 'startedTime'):
        if cols is None:
            cols = ['cpuTime', 'startedTime', 'turnaroundTime']
        fig, ax = plt.subplots(1, 1, figsize=(16, 6))

        df = self.get_output_for_seed(scheduler, seed)[cols]

        df = df.sort_values(by=sort_by)

        df.plot.bar(ax=ax, title=f"{self.directory}: {scheduler} {seed} processes sorted by {sort_by}")
        ax.set_xlabel('Process')

        ax.legend()

#########################
