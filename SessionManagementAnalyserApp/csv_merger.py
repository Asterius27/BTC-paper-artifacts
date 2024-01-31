import pandas as pd
from pathlib import Path

path1 = Path(__file__).parent / '../from_flask_login-400d0b19-bb27-4475-a2fd-a061aab75320.csv'
path2 = Path(__file__).parent / '../import_flask_login-030b70fd-015a-46af-b12a-f86fa2fc27c2.csv'
output = Path(__file__).parent / '../flask_login_final_v2_merged_list.csv'

df1=pd.read_csv(path1)
df2=pd.read_csv(path2)

# if the same repo has a different number of stars (because the two csv lists where generated at different points in time) then it won't be seen as a duplicate
full_df = pd.concat([df1,df2])
unique_df = full_df.drop_duplicates(keep='last')
unique_df.to_csv(output, index=False)
