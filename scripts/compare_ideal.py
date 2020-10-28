import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
from scipy import stats

##########################
### Simulators 2 Ideal ###
##########################

#sivic_2_prescan = pd.read_csv("sivic_2_prescan.csv")
sivic_2_prescan = pd.read_csv("sivic_2_prescan_comma.csv")
prescan_2_sivic = pd.read_csv("prescan_2_sivic_comma.csv")
all_results = pd.read_csv("all_results_comma.csv")

# COMPARE Objective Functions 1-3
#sivic_2_ideal_diff_of1 = abs(sivic_2_prescan["sivic_of1"] - sivic_2_prescan["theory_of1"])
sivic_2_ideal_diff_of1 = sivic_2_prescan["sivic_of1"] - sivic_2_prescan["theory_of1"]

#prescan_2_ideal_diff_of1 = abs(prescan_2_sivic["ps_of1"] - prescan_2_sivic["theory_of1"])
prescan_2_ideal_diff_of1 = prescan_2_sivic["ps_of1"] - prescan_2_sivic["theory_of1"]


#all_results_ideal_diff_of1 = abs(
#    abs(sivic_2_prescan["sivic_of1"] - sivic_2_prescan["theory_of1"]) -
#    abs(prescan_2_sivic["ps_of1"] - prescan_2_sivic["theory_of1"]))

all_results_ideal_diff_of1 = (sivic_2_prescan["sivic_of1"] - sivic_2_prescan["theory_of1"]) - (prescan_2_sivic["ps_of1"] - prescan_2_sivic["theory_of1"])

print(stats.describe(sivic_2_ideal_diff_of1))
print(sivic_2_ideal_diff_of1.std())
print(sivic_2_ideal_diff_of1.median())

print(stats.describe(prescan_2_ideal_diff_of1))
print(prescan_2_ideal_diff_of1.std())
print(prescan_2_ideal_diff_of1.median())

print(stats.describe(all_results_ideal_diff_of1))
print(all_results_ideal_diff_of1.std())
print(all_results_ideal_diff_of1.median())
print(stats.normaltest(all_results_ideal_diff_of1))

sns.set()
f, axes = plt.subplots(1, 3)
ax1 = sns.distplot(sivic_2_ideal_diff_of1, bins=100, kde=False, ax=axes[0])
ax1.set_ylabel('', fontsize=14)
ax1.xaxis.set_label_position('top')
ax1.set_xlabel('A) Pro-SiVIC vs. Ideal', fontsize=20)
ax1.text(-25, 25, 'M=-4.40, SD=4.30, MDN=-3.21', fontsize=12)
ax2 = sns.distplot(prescan_2_ideal_diff_of1, bins=100, kde=False, ax=axes[1])
ax2.set_ylabel('', fontsize=14)
ax2.xaxis.set_label_position('top')
ax2.set_xlabel('B) PreScan vs. Ideal', fontsize=20)
ax2.text(-12, 14, 'M=-3.63, SD=3.04, MDN=-3.00', fontsize=12)
ax3 = sns.distplot(all_results_ideal_diff_of1, bins=100, kde=False, ax=axes[2])
ax3.set_ylabel('', fontsize=14)
ax3.xaxis.set_label_position('top')
ax3.set_xlabel('C) Diff. A) - B)', fontsize=20)
ax3.text(-25, 15, 'M=-0.77, SD=5.59, MDN=-0.51', fontsize=12)
plt.show()
