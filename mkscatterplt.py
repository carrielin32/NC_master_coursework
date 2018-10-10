import numpy as np 
import matplotlib.pyplot as plt 
import pandas as pd 
import seaborn as sns #plot scatter with regression line


# import data 
# N =
df = pd.read_csv('')

#group by task here  

g1 = (x1, y1) #import array data here  #x1: set size for task1; y1: individual mean RT within that set size)
g2 = (x2, y2) #import array data here

data = (g1, g2)
colors = ("blue","green") #blue for task1(p), green for task(s)
groups = ("parallel search","serial search")

# create plot (also suit for three data sets)
fig = plt.figure()
ax = fig.add_subplot(1,1,axisbg="1.0")

for data, color, group in zip(data, colors, groups):
	x, y = data  #x,y: array_like 
	ax.scatter(x, y, alpha=0.8, c=color, edgecolors='none', s=30, label=group)
	#s: marker size in points 
	#c: a single color format string; a 2D array in which the rows are RGB/RGBA)
    #alpha: scalar, the alpha blending value, 0(transparent)~1(opaque)

plt.title('Visual Search Performance')
plt.xlabel('Set Size of distractors(n)')
plt.ylabel('Search Time(RT,ms)')
plt.legend(loc=2)

plt.show()


# or call scatter twice 
plt.scatter(set_size, y1, color='blue')
plt.scatter(set_size, y2, color='green')

# plot via seaborn (with regression line)
sns.set_style('ticks')
x = df['set_size']
y = df['RT']
sns.regplot(df.X, df.Y, x_ci='ci', x=x, y=y, ci=95)
sns.despine()

# plot two set of data in one figure 

g = sns.FacetGrid(df, hue=df['task'],palette="Set2", height=5, hue_kws={"marker": ["^", "v"]})
g.map(sns.regplot, x=df['set_size'], y=df['RT'], x_ci='ci',ci=95)
g.add_legend()
g.set_xlabels('Set Size of distractors(n)')
g.set_ylabels('Search Time(RT,ms)')
g.set_titles('Visual Search Performance')

# lmplot method 
# use this method first
sns.set(color_codes=True)
g = sns.lmplot(x=df['set_size'], y=df['RT'], hue=df['task'], markers=["o", "x"], palette="Set2")





