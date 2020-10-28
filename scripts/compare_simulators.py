import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

###########################
### Pro-SiVIC 2 PreScan ###
###########################

#sivic_2_prescan = pd.read_csv("sivic_2_prescan.csv")
sivic_2_prescan = pd.read_csv("sivic_2_prescan_comma.csv")
prescan_2_sivic = pd.read_csv("prescan_2_sivic_comma.csv")
all_results = pd.read_csv("all_results_comma.csv")

#print(stats.desc(["ps_of1"]))

# COMPARE Objective Functions 1-3
sivic_2_prescan_diff_of1 = abs(sivic_2_prescan["ps_of1"] - sivic_2_prescan["sivic_of1"])
sivic_2_prescan_diff_of2 = abs(sivic_2_prescan["ps_of2"] - sivic_2_prescan["sivic_of2"])
sivic_2_prescan_diff_of3 = abs(sivic_2_prescan["ps_of3"] - sivic_2_prescan["sivic_of3"])

prescan_2_sivic_diff_of1 = abs(prescan_2_sivic["ps_of1"] - prescan_2_sivic["sivic_of1"])
prescan_2_sivic_diff_of2 = abs(prescan_2_sivic["ps_of2"] - prescan_2_sivic["sivic_of2"])
prescan_2_sivic_diff_of3 = abs(prescan_2_sivic["ps_of3"] - prescan_2_sivic["sivic_of3"])

all_results_diff_of1 = abs(all_results["ps_of1"] - all_results["sivic_of1"])
all_results_diff_of2 = abs(all_results["ps_of2"] - all_results["sivic_of2"])
all_results_diff_of3 = abs(all_results["ps_of3"] - all_results["sivic_of3"])

sns.set()
f, axes = plt.subplots(3, 3)
ax1 = sns.distplot(sivic_2_prescan_diff_of1, bins=100, kde=False, ax=axes[0,0])
ax1.set_ylabel('Pro-SiVIC -> PreScan', fontsize=14)
ax1.xaxis.set_label_position('top')
ax1.set_xlabel('Abs. diff. FF1 (m)', fontsize=20)
ax1.text(10, 80, 'Avg=3.11, SD=5.72, MDN=0.75', fontsize=12)
ax2 = sns.distplot(sivic_2_prescan_diff_of3, bins=100, kde=False, ax=axes[0,1])
ax2.set_ylabel('')
ax2.xaxis.set_label_position('top')
ax2.set_xlabel('Abs. diff. FF2 (m)', fontsize=20)
ax2.text(1.5, 100, 'Avg=0.50, SD=0.98, MDN=0.10', fontsize=12)
ax3 = sns.distplot(sivic_2_prescan_diff_of2, bins=100, kde=False, ax=axes[0,2])
ax3.set_ylabel('')
ax3.xaxis.set_label_position('top')
ax3.set_xlabel('Abs. diff. FF3 (s)', fontsize=20)
ax4 = sns.distplot(prescan_2_sivic_diff_of1, bins=100, kde=False, ax=axes[1,0])
ax4.set_ylabel('PreScan -> Pro-SiVIC', fontsize=14)
ax4.set_xlabel('')
ax4.text(6, 60, 'Avg=2.63, SD=5.02, MDN=0.70', fontsize=12)
ax5 = sns.distplot(prescan_2_sivic_diff_of3, bins=100, kde=False, ax=axes[1,1])
ax5.set_ylabel('')
ax5.set_xlabel('')
ax5.text(1.5, 100, 'Avg=0.48, SD=0.73, MDN=0.21', fontsize=12)
ax6 = sns.distplot(prescan_2_sivic_diff_of2, bins=100, kde=False, ax=axes[1,2])
ax6.set_ylabel('')
ax6.set_xlabel('')
ax7 = sns.distplot(all_results_diff_of1, bins=100, kde=False, ax=axes[2,0])
ax7.set_ylabel('All results', fontsize=14)
ax7.set_xlabel('')
ax7.text(10, 150, 'Avg=2.87, SD=5.39, MDN=0.73', fontsize=12)
ax8 = sns.distplot(all_results_diff_of3, bins=100, kde=False, ax=axes[2,1])
ax8.set_ylabel('')
ax8.set_xlabel('')
ax8.text(1.75, 200, 'Avg=0.49, SD=0.86, MDN=0.14', fontsize=12)
ax9 = sns.distplot(all_results_diff_of2, bins=100, kde=False, ax=axes[2,2])
ax9.set_ylabel('')
ax9.set_xlabel('')
plt.show()

###########################
### PreScan 2 Pro-SiVIC ###
###########################


# COMPARE Objective Functions 1-3


sns.set()
f, axes = plt.subplots(3, 3)
ax1 = sns.distplot(prescan_2_sivic_diff_of1, bins=100, kde=False, ax=axes[0])
ax1.set_ylabel('')
ax1.set_xlabel('Abs. diff. FF1 (m)')
ax2 = sns.distplot(prescan_2_sivic_diff_of3, bins=100, kde=False, ax=axes[1])
ax2.set_ylabel('')
ax2.set_xlabel('Abs. diff. FF2 (m)')
ax3 = sns.distplot(prescan_2_sivic_diff_of2, bins=100, kde=False, ax=axes[2])
ax3.set_ylabel('')
ax3.set_xlabel('Abs. diff. FF3 (s)')
plt.show()

###################
### All results ###
###################



# COMPARE Objective Functions 1-3

sns.set()
f, axes = plt.subplots(1, 3)
ax1 = sns.distplot(all_results_diff_of1, bins=100, kde=False, ax=axes[0])
ax1.set_ylabel('')
ax1.set_xlabel('Abs. diff. FF1 (m)')
ax2 = sns.distplot(all_results_diff_of3, bins=100, kde=False, ax=axes[1])
ax2.set_ylabel('')
ax2.set_xlabel('Abs. diff. FF2 (m)')
ax3 = sns.distplot(all_results_diff_of2, bins=100, kde=False, ax=axes[2])
ax3.set_ylabel('')
ax3.set_xlabel('Abs. diff. FF3 (s)')
plt.show()
