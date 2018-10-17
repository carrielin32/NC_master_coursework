from __future__ import division
import sys
from pandas import Series, DataFrame
import pandas as pd
import numpy as np
from scipy import stats
from scipy.stats import norm
from math import exp,sqrt
#Z = norm.ppf

df = pd.read_csv('/Users/carrielin/Desktop/data_transformed.csv')

#check data type 
df['subject']=df['subject'].astype(str) 
df['subj_new']=df['subject'].str[2:] #extract last number of original subject_ID

df.to_csv('/Users/carrielin/Desktop/data_transformed.csv')

df = pd.read_csv('/Users/carrielin/Desktop/data_transformed.csv',index_col=['condition','subj_new'])

df=DataFrame(df)

df['miss']=np.where((df['acc']== 0) & (df['target']== 1),'1','0')  #calculate miss

df['crs']=np.where((df['acc']== 1) & (df['target']== 2),'1','0')  #calculate correcht rejections


df.to_csv('/Users/carrielin/Desktop/data_transformed_1.csv')


#hit, miss,false alarm, correct rejection (number)
df = pd.read_csv('/Users/carrielin/Desktop/data_transformed_1.csv',index_col=['condition','subj'])

df=df.groupby(['condition','subj_new'])[['hit','miss','fas','crs']]

 
def dPrime(hit, miss, fas, crs):
    # Floors an ceilings are replaced by half hits and half FA's
    halfHit = (0.5/(hit+miss))
    halfFa = (0.5/(fas+crs))
 
    # Calculate hitrate and avoid d' infinity
    hitRate = (hit/(hit+miss))
    if hitRate == 1: hitRate = 1-halfHit
    if hitRate == 0: hitRate = halfHit
 
    # Calculate false alarm rate and avoid d' infinity
    faRate = (fas/(fas+crs))
    if faRate == 1: faRate = 1-halfFa
    if faRate == 0: faRate = halfFa
 
    # Return d', beta, c, Ad' and Br
    out = {}
   # out['d'] = Z(hitRate) - Z(faRate)
   # out['beta'] = exp((Z(faRate)**2 - Z(hitRate)**2)/2)
   # out['c'] = -(Z(hitRate) + Z(faRate))/2
   # out['Ad'] = norm.cdf(out['d']/sqrt(2))
    out['Br'] = (faRate/(1- hitRate + faRate))  #calculate Br here 
    return pd.Series(out['Br'], index=['Br'])

#check data type again 

df= df.apply(lambda x: dPrime(x['hit'], x['miss'], x['fas'], x['crs']), axis=1)

df.to_csv('')


#make scatter plot now 
import matplotlib.pyplot as plt 
import seaborn as sns #plot scatter with regression line

sns.set(color_codes=True)
g = sns.lmplot(data=df, x="condition", y="Br", palette="Set2")
sns.plt.show()


