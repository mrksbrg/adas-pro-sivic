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

sivic_2_prescan = pd.read_csv("sivic_2_prescan.csv")

# COMPARE Objective Function 1: Min distance between car and pedestrian
sivic_2_prescan_diff_of1 = abs(sivic_2_prescan["ps_of1"] - sivic_2_prescan["sivic_of1"])
sns.set()
sns.distplot(sivic_2_prescan_diff_of1, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between car and pedestrian (OF1)')
plt.xlabel('meter')
plt.show()

# COMPARE Objective Function 2: Min time to collision
sivic_2_prescan_diff_of2 = abs(sivic_2_prescan["ps_of2"] - sivic_2_prescan["sivic_of2"])
sns.set()
sns.distplot(sivic_2_prescan_diff_of2, bins=100, kde=False)
plt.title('Absolute diff. in min. time to collision (OF2)')
plt.xlabel('seconds')
plt.show()

# COMPARE Objective Function 3: Min distance between acute warning area and pedestrian
sivic_2_prescan_diff_of3 = abs(sivic_2_prescan["ps_of3"] - sivic_2_prescan["sivic_of3"])
sns.set()
sns.distplot(sivic_2_prescan_diff_of3, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between AWA and pedestrian (OF3)')
plt.xlabel('meter')
plt.show()

###########################
### PreScan 2 Pro-SiVIC ###
###########################

prescan_2_sivic = pd.read_csv("prescan_2_sivic.csv")

# COMPARE Objective Function 1: Min distance between car and pedestrian
prescan_2_sivic_diff_of1 = abs(prescan_2_sivic["ps_of1"] - prescan_2_sivic["sivic_of1"])
sns.set()
sns.distplot(prescan_2_sivic_diff_of1, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between car and pedestrian (OF1)')
plt.xlabel('meter')
plt.show()

# COMPARE Objective Function 2: Min time to collision
prescan_2_sivic_diff_of2 = abs(prescan_2_sivic["ps_of2"] - prescan_2_sivic["sivic_of2"])
sns.set()
sns.distplot(prescan_2_sivic_diff_of2, bins=100, kde=False)
plt.title('Absolute diff. in min. time to collision (OF2)')
plt.xlabel('seconds')
plt.show()

# COMPARE Objective Function 3: Min distance between acute warning area and pedestrian
prescan_2_sivic_diff_of3 = abs(prescan_2_sivic["ps_of3"] - prescan_2_sivic["sivic_of3"])
sns.set()
sns.distplot(prescan_2_sivic_diff_of3, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between AWA and pedestrian (OF3)')
plt.xlabel('meter')
plt.show()

###################
### All results ###
###################

all_results = pd.read_csv("all_results.csv")

# COMPARE Objective Function 1: Min distance between car and pedestrian
all_results_diff_of1 = abs(all_results["ps_of1"] - all_results["sivic_of1"])
sns.set()
sns.distplot(all_results_diff_of1, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between car and pedestrian (OF1)')
plt.xlabel('meter')
plt.show()

# COMPARE Objective Function 2: Min time to collision
all_results_diff_of2 = abs(all_results["ps_of2"] - all_results["sivic_of2"])
sns.set()
sns.distplot(all_results_diff_of2, bins=100, kde=False)
plt.title('Absolute diff. in min. time to collision (OF2)')
plt.xlabel('seconds')
plt.show()

# COMPARE Objective Function 3: Min distance between acute warning area and pedestrian
all_results_diff_of3 = abs(all_results["ps_of3"] - all_results["sivic_of3"])
sns.set()
sns.distplot(all_results_diff_of3, bins=100, kde=False)
plt.title('Absolute diff. in min. distance between AWA and pedestrian (OF3)')
plt.xlabel('meter')
plt.show()