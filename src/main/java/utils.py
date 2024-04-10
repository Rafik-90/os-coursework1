from os import listdir, path
import pandas as pd
from glob import glob

# ------------------------------------ UTILITY FUNCTIONS ----------------------------------------
# Returns a dataframe of all parameters from a file `key=value` pair
def get_params(fname):
    df = pd.read_table(fname, sep='=', on_bad_lines='skip', header=None)
    df.columns = ['param', 'value']
    df.index = df['param']
    df.drop(['param'], axis=1, inplace=True)
    return df


# Returns an array of tuples of all the input params in form of (seed, df), df is a dataframe of the input params
def get_all_input_params(directory):

    input_files = [f for f in listdir(directory) if f.startswith('input_parameters_seed')]

    dfs = []

    for f in input_files:
        seed = f.split('_')[-1].split('.')[0]
        dfs.append((seed, get_params(path.join(directory, f))))
    return dfs


#  Returns an array of tuples of all the simulator params in form of (seed, df), df is a dataframe of the simulator
# params
def get_all_sim_params(directory):
    input_files = [f for f in listdir(directory) if 'simulator_parameters' in f]

    dfs = []

    for f in input_files:
        df = get_params(path.join(directory, f))

        dfs.append(df)
    return dfs


#  Gets output data from a directory in form described in `./run.sh`
def get_output_data(directory):
    # Using a dictionary comprehension to streamline the process
    res = {folder: [] for folder in listdir(directory) if path.isdir(path.join(directory, folder))}

    for scheduler_folder in res:
        scheduler_path = path.join(directory, scheduler_folder)
        # Using glob to find all 'output_seed_*.out' files within the folder
        for file_path in glob(path.join(scheduler_path, 'output_seed_*.out')):
            # Extracting the seed from the filename
            seed = path.basename(file_path).split('output_seed_')[-1].split('.')[0]
            # Reading the data file
            df = pd.read_csv(file_path, sep=r'\s+')
            # Adjusting the DataFrame index
            df['process_id'] = ['process_' + str(i) if i > 0 else 'idle_process' for i in df['id']]
            df.set_index('process_id', inplace=True)
            # Appending the DataFrame to the appropriate scheduler list
            res[scheduler_folder].append((seed, df))

    return res