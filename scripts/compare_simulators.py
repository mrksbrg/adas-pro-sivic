import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np

prescan_orig = pd.read_csv("prescan_results.csv")
sivic_repl = pd.read_csv("prosivic_results.csv")

#sivic_orig = pd.read_csv("prosivic_results_2")
#prescan_repl = pd.read_csv("prescan_results_2")

print(prescan_orig.head())