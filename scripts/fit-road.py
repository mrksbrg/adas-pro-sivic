import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import pylab
#import plotly.graph_objs as go
#import statsmodels.formula.api as smf

colnames = ['x', 'y']
df = pd.read_csv('street-mapping.csv', names=colnames, header=None)
x = df['x']
y = df['y']
print(x)

# calculate polynomial
z = np.polyfit(df['x'], df['y'], 2)
f = np.poly1d(z)
print(f)



#b, m = polyfit(df['x'], df['y'], 1)
#ax.plot(df['x'], b + m * df['x'], 'blue', linewidth=1)


#py.plot_mpl(fig, filename='polynomial-Fit-with-matplotlib')

#model = poly.poly1d(weights)
#print(model)
#results = smf.ols(formula='y ~ model(x)', data=df).fit()

#print(results.summary())

# def func(x):
#     print(weights[0])
#     print(weights[1]*x)
#     print(weights[2]*x*x)
#     return weights[0] + (weights[1] * x) + (weights[2] * x * x)
#
# print("Result: " + str(func(72.09)))