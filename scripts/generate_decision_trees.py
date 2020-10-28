import os
import statistics
import csv
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib import collections
from sklearn import preprocessing, tree
from dtreeviz.trees import dtreeviz # remember to load the package

color_blind_safety_colors = [
    None,  # 0 classes
    None,  # 1 class
    ['#B9AD5E', '#DB4325']  # 2 classes
]

color_blind_other_colors = [
    None,  # 0 classes
    None,  # 1 class
    ['#a1dab4', '#FEFEBB']  # 2 classes
]

###############
### PreScan ###
###############

prescan = pd.read_csv("prescan_2_sivic_comma.csv")
X_prescan = prescan[["ps_x", "ps_y", "ps_orient", "ps_vp", "ps_vc", "SafeViol"]]
features = ["x_0", "y_0", "theta", "p_v", "c_v", "SafeViol"]
df_prescan = pd.DataFrame(X_prescan.values, columns=features)

clf_prescan = tree.DecisionTreeClassifier(max_depth=2)
clf_prescan.fit(df_prescan.iloc[:, :-1], df_prescan.SafeViol) # all features but the last one

viz = dtreeviz(clf_prescan,
               df_prescan.iloc[:,:-1],
               df_prescan.SafeViol,
               colors={'classes':color_blind_safety_colors},
               target_name='SafeViol',
               feature_names=features,
               class_names=["False", "True"]
               )

viz.view()

#################
### Pro-SiVIC ###
#################

sivic = pd.read_csv("sivic_2_prescan_comma.csv")
X_sivic = sivic[["ps_x", "ps_y", "ps_orient", "ps_vp", "ps_vc", "SafeViol"]]
features = ["x_0", "y_0", "theta", "p_v", "c_v", "SafeViol"]
df_sivic = pd.DataFrame(X_sivic.values, columns=features)

clf_sivic = tree.DecisionTreeClassifier(max_depth=2)
clf_sivic.fit(df_sivic.iloc[:, :-1], df_sivic.SafeViol) # all features but the last one

viz = dtreeviz(clf_sivic,
               df_sivic.iloc[:,:-1],
               df_sivic.SafeViol,
               colors={'classes':color_blind_safety_colors},
               target_name='SafeViol',
               feature_names=features,
               class_names=["False", "True"]
               )

viz.view()

##################
### FF1 >= 5 m ###
##################

# all_results = pd.read_csv("all_results_comma.csv")
# X_diff = all_results[["ps_x", "ps_y", "ps_orient", "ps_vp", "ps_vc", "big_diff"]]
# features = ["x_0", "y_0", "theta", "p_v", "c_v", "big_diff"]
# df_diff = pd.DataFrame(X_diff.values, columns=features)
#
# clf_diff = tree.DecisionTreeClassifier(max_depth=3)
# clf_diff.fit(df_diff.iloc[:, :-1], df_diff.big_diff) # all features but the last one
#
# viz = dtreeviz(clf_diff,
#                df_diff.iloc[:,:-1],
#                df_diff.big_diff,
#                colors={'classes':color_blind_other_colors},
#                target_name='FF1 >= 5 m',
#                feature_names=features,
#                class_names=["False", "True"]
#                )
#
# viz.view()