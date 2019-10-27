import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np

class Configuration:

    def __init__(self, ped_x, ped_y, ped_orient, ped_speed, car_speed, min_dist, min_ttc, min_dist_awa, det, col):
        self.ped_x = ped_x
        self.ped_y = ped_y
        self.ped_orient = ped_orient
        self.ped_speed = ped_speed
        self.car_speed = car_speed
        self.min_dist_counter = Counter([min_dist])
        self.min_dist = [min_dist]
        self.min_ttc = [min_ttc]
        self.min_ttc_counter = Counter([min_ttc])
        self.min_dist_awa = [min_dist_awa]
        self.min_dist_awa_counter = Counter(([min_dist_awa]))
        self.detected = [det]
        self.collision = [col]
        self.nbr_results = 1

    def __str__(self):
        return "### Scenario (x0P=" + str(self.ped_x) + ", y0P=" + str(self.ped_y) + ", Th0P=" + str(self.ped_orient) + ", v0P=" + str(self.ped_speed) + ", v0C=" + str(self.car_speed) + ") ###"

    def __eq__(self, other):
        return self.ped_x == other.ped_x and self.ped_y == other.ped_y and self.ped_orient == other.ped_orient \
               and self.ped_speed == other.ped_speed and self.car_speed == other.car_speed

    def __lt__(self, other):
        return self.ped_x < other.ped_x

    def add_result(self, min_dist, min_ttc, min_dest_awa, det, col):
        self.min_dist.append(min_dist)
        self.min_dist_counter.update([min_dist])
        self.min_ttc.append(min_ttc)
        self.min_ttc_counter.update([min_ttc])
        self.min_dist_awa.append(min_dest_awa)
        self.min_dist_awa_counter.update([min_dest_awa])
        self.detected.append(det)
        self.collision.append(col)
        self.nbr_results += 1

    def get_nbr_results(self):
        return self.nbr_results

    def get_nbr_unique_results(self):
        unique_list_of1 = []
        unique_list_of2 = []
        unique_list_of3 = []
        for x in self.min_dist:
            if x not in unique_list_of1:
                unique_list_of1.append(x)
        for y in self.min_ttc:
            if y not in unique_list_of2:
                unique_list_of2.append(y)
        for z in self.min_dist_awa:
            if z not in unique_list_of3:
                unique_list_of3.append(z)
        return {'of1': unique_list_of1, 'of2': unique_list_of2, 'of3': unique_list_of3}

    def get_avg_min_dist(self):
        sum = 0
        for res in self.min_dist:
            sum += res
        return sum / len(self.min_dist)

    def get_sd_min_dist(self):
        return statistics.stdev(self.min_dist)

    def get_avg_min_ttc(self):
        sum = 0
        for res in self.min_ttc:
            sum += res
        return sum / len(self.min_ttc)

    def get_sd_min_ttc(self):
        return statistics.stdev(self.min_ttc)

    def get_avg_min_dist_awa(self):
        sum = 0
        for res in self.min_dist_awa:
            sum += res
        return sum / len(self.min_dist_awa)

    def get_sd_min_dist_awa(self):
        return statistics.stdev(self.min_dist_awa)

    def get_nbr_detections(self):
        sum = 0
        for res in self.detected:
            sum += res
        return sum

    def get_nbr_collisions(self):
        sum = 0
        for res in self.collision:
            sum += res
        return sum

    @property
    def get_ped_x(self):
        return self.ped_x

    @property
    def get_ped_y(self):
        return self.ped_y

    @property
    def get_ped_orient(self):
        return self.ped_orient

    @property
    def get_ped_speed(self):
        return self.ped_speed

    @property
    def get_car_speed(self):
        return self.car_speed

    @property
    def get_of1_counter(self):
        return self.min_dist_counter

dir_name = 'prosivic_results'
result_dataframes = []
scenario_results = []

for filename in os.listdir(dir_name):
    if filename.endswith(".csv"):
        df = pd.read_csv(dir_name + "\\" + filename)
        for index, row in df.iterrows():
            conf = Configuration(row['x0P'], row['y0P'], row['Th0P'], row['v0P'], row['v0C'], row['OF1'], row['OF2'], row['OF3'], row['Det'], row['Coll'])
            if conf not in scenario_results:
                scenario_results.append(conf)
            else:
                #print("Adding results to: " + str(conf))
                i = scenario_results.index(conf)
                scenario_results[i].add_result(row['OF1'], row['OF2'], row['OF3'], row['Det'], row['Coll'])

with open('merged_prosivic_results.csv', mode='w') as merged_file:
    merge_writer = csv.writer(merged_file, delimiter=',')
    merge_writer.writerow(['x0P', 'y0P', 'Th0P', 'v0P', 'v0C', 'nbr', 'OF1_unique', 'OF1_avg', 'OF1_sd', 'OF2_unique', 'OF2_avg', 'OF2_sd', 'OF3_unique', 'OF3_avg', 'OF3_sd', 'det_true', 'det_false', 'col_true', 'col_false'])

    for conf in scenario_results:
        print(conf)
        unique_per_of = conf.get_nbr_unique_results()
        print("\tNumber of results: " + str(conf.get_nbr_results()))
        print("\tmin_dist:\t\tUnique = " + str(len(unique_per_of["of1"])) + "\tAvg = " + str(conf.get_avg_min_dist()) + "\tSD = " + str(conf.get_sd_min_dist()))
        print("\t\tCounter min_dist: " + str(conf.min_dist_counter))
        print("\tmin_ttc:\t\tUnique = " + str(len(unique_per_of["of2"])) + "\tAvg = " + str(conf.get_avg_min_ttc()) + "\tSD = " + str(conf.get_sd_min_ttc()))
        print("\t\tCounter min_ttc: " + str(conf.min_ttc_counter))
        print("\tmin_dist_awa:\tUnique = " + str(len(unique_per_of["of3"])) + "\tAvg = " + str(conf.get_avg_min_dist_awa()) + "\tSD = " + str(conf.get_sd_min_dist_awa()))
        print("\t\tCounter min_dist_awa: " + str(conf.min_dist_awa_counter))
        print("\tNumber detections: " + str(conf.get_nbr_detections()) + " (out of " + str(conf.get_nbr_results()) + ")")
        print("\tNumber collisions: " + str(conf.get_nbr_collisions()) + " (out of " + str(conf.get_nbr_results()) + ")")

        merge_writer.writerow([conf.ped_x, conf.ped_y, conf.ped_orient, conf.ped_speed, conf.car_speed, conf.get_nbr_results(), len(unique_per_of["of1"]), conf.get_avg_min_dist(), conf.get_sd_min_dist(), len(unique_per_of["of2"]), conf.get_avg_min_ttc(), conf.get_sd_min_ttc(), len(unique_per_of["of3"]), conf.get_avg_min_dist_awa(), conf.get_sd_min_dist_awa(), conf.get_nbr_detections(), (conf.get_nbr_results()-conf.get_nbr_detections()), conf.get_nbr_collisions(), (conf.get_nbr_results()-conf.get_nbr_collisions())])
