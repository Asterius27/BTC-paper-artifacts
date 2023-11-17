import pandas as pd
from pathlib import Path

path1 = Path(__file__).parent / '../flask_login_list.csv'
path2 = Path(__file__).parent / '../flask_login_list_2.csv'
output = Path(__file__).parent / '../flask_login_merged_list.csv'

df1=pd.read_csv(path1)
df2=pd.read_csv(path2)

full_df = pd.concat([df1,df2])
unique_df = full_df.drop_duplicates(keep='last')
unique_df.to_csv(output, index=False)
