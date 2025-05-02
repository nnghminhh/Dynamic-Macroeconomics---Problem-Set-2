import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

df = pd.read_csv('muc123a.csv')
print(df['hoso'][0])

df['householdsex'] = None
df['household_id'] = None
df['num_members'] = None

df.loc[0, 'householdsex'] = 2

for i in range(1, len(df)):
    if df['hoso'][i] != df['hoso'][i - 1]:
        df.loc[i, 'householdsex'] = df.loc[i, 'm1ac2']
    else:
        df.loc[i, 'householdsex'] = df.loc[i - 1, 'householdsex']

df = df[df['householdsex'] != 2]

for i in range(len(df)):
    df.loc[df.index[i], 'household_id'] = ', '.join([str(df.iloc[i][col]) for col in ['tinh', 'huyen', 'xa', 'diaban', 'hoso']])

muc123a['HSIZE'] = muc123a.groupby(['tinh','huyen','xa','diaban','hoso'])['matv'].transform('max')
muc123a['HSIZE'].head(10)

print(df)
#df2 = pd.read_csv('')

#df.to_csv('output_file.csv', index=False)

print(df)


