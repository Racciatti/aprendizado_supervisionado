# import os
import pandas as pd
import numpy as np
# from datetime import datetime, timedelta
# from random import shuffle
# import psutil
# from PIL import Image

# LOADING AND SAVING DATA
def load_data(source_data_path:str, columns:list[str] = []):
    data_path = os.path.abspath(source_data_path)
    data = pd.read_csv(data_path)
    if columns == []:
        return data
    
    return data[columns]

def set_first_row_as_header(df):
    """Sets the first row as the column headers and removes that row."""
    df.columns = df.iloc[0]
    df = df.drop(df.index[0])
    return df

def safe_save(data, target_path):
    """
    Checks if the target path exists. If it doesn't exist, creates the directories and then saves the data
    """
    if os.path.isdir(os.path.dirname(target_path)):
        data.to_csv(target_path, index=False)
    else:
        os.mkdir(os.path.dirname(target_path))
        data.to_csv(target_path, index=False)


# AUXILIARY FUNCTIONS BUILT FOR FEATURE ENGINNERING

def get_target_variable(trade_entry:dict, expected_hf_cost_per_notional_usd_traded:float):

    notional_traded = trade_entry['volume'] * trade_entry['open_price'] * trade_entry['contract_size'] * trade_entry['conv_rate1']

    expected_hf_costs = expected_hf_cost_per_notional_usd_traded * notional_traded

    net_reverse_profit = (trade_entry['gross_profit'] * (-1)) - expected_hf_costs

    target_var = net_reverse_profit / trade_entry['initial_balance']

    return target_var
    
def create_dense_date_index(group, start_date:datetime, end_date:datetime, features_interpolation_mode:dict, date_column_name:str = 'date', identifier_column:str='login', frequency:str = 'D'):
    """
    This function returns a dataframe with all identifier X date pairs for a given date range [start_date, end_date].
    It must be used within a dataframe.groupby.apply(create_dense_data_index) call, as it is applied for each id in the dataset.
    
    The features_interpolation_mode parameter is expected to be a dictionary with feature names (columns) as keys and the 
    interpolation mode for those features as values, e.g. {'gross_profit':'zero'}

    The values that can be used for interpolation are 'forward', 'backward', 'zero'.  

    """
    all_dates = pd.date_range(start=start_date, end=end_date, freq=frequency)

    # Reindex the group to include all dates in the range
    group = group.set_index(date_column_name).reindex(all_dates)
    
    for feature_name in features_interpolation_mode:

        if features_interpolation_mode[feature_name] == 'forward':
            group[feature_name] = group[feature_name].ffill()


        elif features_interpolation_mode[feature_name] == 'zero':
            group[feature_name] = group[feature_name].fillna(0)
        
        elif features_interpolation_mode[feature_name] == 'backward':
            group[feature_name] = group[feature_name].bfill()
        
    # Fill categorical/identifier columns that became NaN during reindexing
    group[identifier_column] = group[identifier_column].ffill().bfill()
    
    return group

def fill_missing_dates(group, start_date:datetime, end_date:datetime, dataframe:pd.DataFrame, target_feature_name:str, daily_feature_name:str = None, date_column_name:str = 'date', identifier_column:str='login', target_fill_method:str = 'cumulative'):
    """
    Fills a dataframe with all dates. 
    For the column 'target feature name', applies a forward fill and then a zero fill.
    For the identifier column (usually 'login') applies a forward and backwards fill (not a problem due to groupby's disjoint subsets)
    The optional daily feature is mainly for auditing the results in the target feature. 
    """
    all_dates = pd.date_range(start=start_date, end=end_date, freq='D')
    
    # Reindex the group to include all dates in the range
    group = group.set_index(date_column_name).reindex(all_dates)
    
    if target_fill_method == 'cumulative':
        # Forward fill the cumulative sum and constant identifiers
        group[target_feature_name] = group[target_feature_name].ffill()

        # Fill leading NaNs with 0
        group[target_feature_name] = group[target_feature_name].fillna(0)
    
    elif target_fill_method == 'zero':
        group[target_feature_name] = group[target_feature_name].fillna(0)

        
    # Fill categorical/identifier columns that became NaN during reindexing
    group[identifier_column] = group[identifier_column].ffill().bfill()
    
    # If there is a 'daily(base) feature'
    if daily_feature_name is not None:
        # Fill the 'daily' feature with 0, as no activity occurred on filled days
        group[daily_feature_name] = group[daily_feature_name].fillna(0)
    
    return group

# AUXILIARY FUNCTIONS BUILT FOR THE EDA

def get_relative_amount_of_top_k(data:list, top_k_count:int, print_return:bool = True):
    
    # For each value in the data, get its count
    count = {}
    for element_value in data:
        if str(element_value) in list(count.keys()):
            count[str(element_value)] +=1
        else:
            count[str(element_value)] = 1

    # Then get its relative count (%)
    total_element_count = len(data)
    element_and_relative_count  = [(element,count[element]/total_element_count) for element in count]

    element_and_relative_count.sort(key=lambda x:x[1], reverse=True)

    # Selecting top-k most frequent
    selected_items = [item for item in element_and_relative_count[:top_k_count]]

    if print_return == True:
        for element in selected_items:
            print(element)
        return
    return selected_items
    
def get_values_inside_ranges(data:pd.DataFrame, column_name:str, ranges:list[int], side='both', interval_center:int=0):
    """
    Prints out the percentage of rows that have column value in a given range 
    """
    if side == 'both':
        for range_interval in ranges:
            element_count = len(data[column_name])
            inside_interval = len(data[(interval_center-range_interval<data[column_name]) & (data[column_name]<interval_center+range_interval)])
            print(f'[-{interval_center+range_interval}, +{interval_center+range_interval}]: {inside_interval/element_count}')

    elif side == 'right':
        for range_interval in ranges:
            element_count = len(data[column_name])
            inside_interval = len(data[(interval_center<data[column_name]) & (data[column_name]<interval_center+range_interval)])
            print(f'[{interval_center}, +{interval_center+range_interval}]: {inside_interval/element_count}')

    return

def get_stats(data:list, return_values:bool = False):
    max_val = max(data)
    min_val = min(data)
    std = np.std(data)
    mean = np.mean(data)
    median = np.median(data)
    z = std/mean
    
    if return_values:
    
        return {
            'max':max_val,
            'min':min_val,
            'mean':mean,
            'median':median,
            'std':std
        }
    
    print(f"""
            max: {max_val}
            min: {min_val}
            mean: {mean}
            median: {median}
            std: {std}
            z-score: {z}
        """)


def identity_split(dataframe:pd.DataFrame, train_percent:float, test_percent:float, unique_col_name:str = 'login'):
    """
    Performs an identity split on the data and returns train, validation and test dataframes.
    > Identity split: There is no entity intersectionality between the created subsets. 
    
    :param dataframe: The dataframe to be split
    :type dataframe: pd.DataFrame

    :param train_percent: The percentage of rows to be included in the train dataframe
    :type train_percent: float
    
    :param test_percent: The percentage of rows to be included in the test dataframe
    :type test_percent: float
    
    :param unique_col_name: The column to be used as an **unique** identifier of each row 
    :type unique_col_name: str
    """


    # Get all unique identifiers and shuffle them
    all_logins = list(dataframe[unique_col_name])
    shuffle(all_logins)

    # Set separators
    login_count = len(all_logins)
    train_end_split = round(train_percent * login_count)
    test_end_split = round((train_percent+test_percent) * login_count)

    # Split logins
    train_logins = all_logins[0:train_end_split]
    val_logins = all_logins[test_end_split:-1]
    test_logins = all_logins[train_end_split:test_end_split]

    # Create dataframes based on split logins
    train_users = dataframe[dataframe[unique_col_name].isin(train_logins)]
    val_users = dataframe[dataframe[unique_col_name].isin(val_logins)]
    test_users = dataframe[dataframe[unique_col_name].isin(test_logins)]

    return train_users, val_users, test_users

def temporal_split(trades:pd.DataFrame, train_users:pd.DataFrame, val_users:pd.DataFrame, test_users:pd.DataFrame, train_start_date:str, train_end_date:str, buffer_period:str, data_end_date:str, columns_to_drop:list = ['min_equity', 'timestamp_utc', 'server_id_x', 'server_id_y', 'reg_date', 'status_timestamp_utc', 'stage', 'id_x', 'group_x', 'group_y', 'position_id', 'trade_id', 'end_date', 'start_date']):
    """
    Performs a temporal split on the data.
    Needs to be documented. 
    """


    # Set constants
    train_start_date = datetime.fromisoformat(train_start_date)
    train_end_date = datetime.fromisoformat(train_end_date)
    buffer_period = timedelta(buffer_period)
    data_end_date = datetime.fromisoformat(data_end_date)

    # Get the period of val/test partitions
    test_val_period = ((data_end_date - train_end_date) - 2 * buffer_period)/2

    val_start_date = train_end_date + buffer_period
    val_end_date = val_start_date + test_val_period

    test_start_date = val_end_date + buffer_period
    test_end_date = test_start_date + test_val_period

    # For each identity split, join users and trades and apply the temporal split
    # Get train users and their trades
    train_df = pd.merge(train_users, trades, 'left', 'login')
    train_df['end_date'] = (pd.to_datetime(train_df['close_time'])).dt.floor('D')
    train_df['start_date'] = (pd.to_datetime(train_df['open_time'])).dt.floor('D')

    # Filter their trades based on a temporal split
    train_df = train_df[(train_df['end_date'] < train_end_date)&(train_df['start_date']>train_start_date)]

    # Get validation users and their trades
    val_df = pd.merge(val_users, trades, 'left', 'login')
    val_df['end_date'] = (pd.to_datetime(val_df['close_time'])).dt.floor('D')
    val_df['start_date'] = (pd.to_datetime(val_df['open_time'])).dt.floor('D')

    # Filter their trades based on a temporal split
    val_df = val_df[(val_df['end_date'] < val_end_date)&(val_df['start_date']>val_start_date)]

    # Get test users and their trades
    test_df = pd.merge(test_users, trades, 'left', 'login')
    test_df['end_date'] = (pd.to_datetime(test_df['close_time'])).dt.floor('D')
    test_df['start_date'] = (pd.to_datetime(test_df['open_time'])).dt.floor('D')

    # Filter their trades based on a temporal split
    test_df = test_df[(test_df['end_date'] < test_end_date)&(test_df['start_date']>test_start_date)]

    for df in [train_df, val_df, test_df]:
        
        # Drop useless columns
        df.drop(columns=columns_to_drop, inplace=True)
        
        # Rename id_y to id (trade_id)
        df.rename(columns={'id_y':'id'}, inplace=True)
    
    
    return train_df, val_df, test_df

def split_and_save_data(users_source_path:str='../data/users_step2.csv',
                        trades_source_path:str='../data/trades_step2.csv',
                        target_dir_name:str='../data/data_splits/',
                        identity_split:bool=True,
                        train_percent:float=0.6,
                        val_percent:float=0.2,
                        unique_col_name:str='login',
                        train_start_date:str = '2024-06-01',
                        train_end_date:str = '2024-09-01', 
                        buffer_period:int = 30,
                        data_end_date:str = '2024-12-31'
                        ):
    
    """
    Applies both a temporal split and an identity split to the data, dividing it into train, 
    validation and test subsets (identity and temporal disjoint dataframes) and saving them 
    in the target directory.
    """
    
    if identity_split:
        users = load_data(users_source_path)
        train_users, val_users, test_users = identity_split(users, train_percent, val_percent, unique_col_name)
        trades = load_data(trades_source_path)
        train_df, val_df, test_df = temporal_split(trades,train_users,val_users,test_users,train_start_date,train_end_date, buffer_period,data_end_date)        
        safe_save(train_df, target_dir_name+'train.csv')
        safe_save(val_df, target_dir_name+'val.csv')
        safe_save(test_df, target_dir_name+'test.csv')
    else:
        users = load_data(users_source_path)
        trades = load_data(trades_source_path)
        train_df, val_df, test_df = temporal_split(trades,users,users,users,train_start_date,train_end_date, buffer_period,data_end_date)        
        safe_save(train_df, target_dir_name+'train.csv')
        safe_save(val_df, target_dir_name+'val.csv')
        safe_save(test_df, target_dir_name+'test.csv')

def split_and_save(data_source_path:str, data_target_folder:str, train_split:float, test_split:float, validation_split:float):
    """
    Simple split and save function (terrible, deprecated)
    """
    
    if train_split + test_split + validation_split != 1:
        raise ValueError('The splits sum must add to 100')
    
    data = load_data(data_source_path)

    row_count = len(data)

    train_data = data.iloc[0:round(train_split*row_count)]
    test_data = data.iloc[round(train_split*row_count):round((train_split+test_split)*row_count)]
    validation_data = data.iloc[round((train_split+test_split)*row_count):row_count]

    safe_save(train_data,data_target_folder + '/train_split.csv')
    safe_save(test_data,data_target_folder + '/test_split.csv')
    safe_save(validation_data,data_target_folder + '/validation_split.csv')

def print_current_ram_and_swap_usage():

    # 1. RAM Statistics
    ram = psutil.virtual_memory()
    print(f"RAM Usage: {ram.percent}%")

    # 2. Swap Statistics
    swap = psutil.swap_memory()
    print(f"Swap Usage: {swap.percent}%")

def merge_four_plots(file_list, output_path):
    
    if len(file_list) != 4:
        raise ValueError(f"Expected 4 files, received {len(file_list)}")

    images = [Image.open(x) for x in file_list]
    
    # Extract dimensions
    widths, heights = zip(*(i.size for i in images))
    
    # Take dimensions from the first image
    base_w, base_h = widths[0], heights[0]

    # Check if all dimensions match
    for i, (w, h) in enumerate(zip(widths, heights)):
        if w != base_w or h != base_h:
            raise ValueError('dimension mismatch')

    # Create an image with double the size of each plot
    grid_img = Image.new('RGB', (base_w * 2, base_h * 2))
    print(grid_img.size)

    offsets = [(0, 0), (base_w, 0), (0, base_h), (base_w, base_h)]

    for img, offset in zip(images, offsets):
        grid_img.paste(img, offset)
        
        # Free memory
        img.close()

    grid_img.save(output_path)

 