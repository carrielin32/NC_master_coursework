import sys
from pandas import Series, DataFrame
import pandas as pd
import numpy as np
from scipy import stats

df = pd.read_csv('',index_col=['task','set_size','subject'])

df = df.swaplevel('task','set_size','subject').sortlevel(0) #ignore warning 



#calculate acc 
df['target_present']= df['target_present'].astype(str)  #check data type 

df['presence']=df['target_present'].replace('1','p')
df['presence']=df['presence'].replace('0','a')

df['acc']= np.where((df['response'] == df['presence']), '1' , '0')


df=DataFrame(df)

df.to_csv('')

#remove outliers 
means_s=df.groupby('task', as_index=False)['RT'].mean()

#check means_s 

df_new=df[np.abs(df.RT-df.RT.mean()) <= (3*df.RT.std())]

#drop NULL value 
df_new.isnull().sum()  #count the number of null data

df_new= df_new.dropna()
df_new= df_new.fillna(0)

#save means of RT
means=df.groupby(['task','set_size','subject'])[['RT']].mean()

means=means.unstack()

means.to_csv('')

#save means of acc
means2=df.groupby(['task','set_size','subject'])[['acc']].mean()

means2=means2.unstack()

means2.to_csv('')

