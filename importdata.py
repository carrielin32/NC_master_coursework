import sys
from pandas import Series, DataFrame
import pandas as pd
import numpy as np

df = pd.read_csv('',index_col=['task','set_size','subject'])

df = df.swaplevel('task','set_size','subject').sortlevel(0) #ignore warning 


#calculate acc 
df['presence']=df['target_present'].replace('1','p')
df['presence']=df['target_present'].replace('0','a')

df['acc']=np.where((df['presence']==df['response']),'1','0')


df=DataFrame(df)

df.to_csv('')

#save means of RT
means=df.groupby(['task','set_size','subject'])[['RT']].mean()

means=means.unstack()

means.to_csv('')

#save means of acc
means2=df.groupby(['task','set_size','subject'])[['acc']].mean()

means2=means2.unstack()

means2.to_csv('')

