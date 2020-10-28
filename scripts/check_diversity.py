import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats

###########################
### Diversity of Output ###
###########################

diversity = pd.read_csv("diversity_comma.csv")

colors = ["#B9AD5E", "#DB4325"]

sns.set()
f, axes = plt.subplots(1, 5)
ax1 = sns.swarmplot(y="v_c", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[0])
ax1.set_ylabel('')
ax1.set_xlabel('v_c (m/s)')
#ax1.get_legend().remove()
ax2 = sns.swarmplot(y="x_0", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[1])
ax2.set_ylabel('')
ax2.set_xlabel('x_0 (m)')
ax2.get_legend().remove()
ax3 = sns.swarmplot(y="y_0", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[2])
ax3.set_ylabel('')
ax3.set_xlabel('y_0 (m)')
ax3.get_legend().remove()
ax4 = sns.swarmplot(y="theta", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[3])
ax4.set_ylabel('')
ax4.set_xlabel('theta (degrees)')
ax4.get_legend().remove()
ax5 = sns.swarmplot(y="v_p", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[4])
ax5.set_ylabel('')
ax5.set_xlabel('v_p (m/s)')
ax5.get_legend().remove()

plt.show()

sns.set()
f, axes = plt.subplots(1, 3)
ax1 = sns.swarmplot(y="OF1", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[0])
ax1.set_ylabel('')
ax1.set_xlabel('FF1 (m)')
#ax1.get_legend().remove()
ax2 = sns.swarmplot(y="OF2", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[1])
ax2.set_ylabel('')
ax2.set_xlabel('FF2 (m)')
ax2.get_legend().remove()
ax3 = sns.swarmplot(y="OF3", x="Simulator", hue="SafeViol", data=diversity, palette=colors, ax=axes[2])
ax3.set_ylabel('')
ax3.set_xlabel('FF3 (s)')
ax3.get_legend().remove()
plt.show()

###################
### HV boxplots ###
###################

hv = pd.read_csv("hv_compare_comma.csv")
print(stats.describe(hv))
print(hv.std())
print(hv.median())

colors = ["#B9AD5E", "#DB4325"]

sns.set()
f, axes = plt.subplots(1, 2)
ax1 = sns.boxplot(y="prescan", data=hv, ax=axes[0], width=0.3)
ax1.text(0.1, 0.8, 'M=0.26', fontsize=12)
ax2 = sns.boxplot(y="sivic", data=hv, ax=axes[1], width=0.3)
ax2.text(0.1, 0.6, 'M=0.23', fontsize=12)
ax1.set_ylabel('Hypervolume Indicator')
ax1.set_xlabel('PreScan')
ax2.set_ylabel('Hypervolume Indicator')
ax2.set_xlabel('Pro-SiVIC')
plt.show()

print(stats.mannwhitneyu(hv["prescan"], hv["sivic"]))