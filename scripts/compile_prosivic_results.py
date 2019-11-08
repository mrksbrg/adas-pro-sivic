import os
import statistics
import csv
from collections import Counter
import pandas as pd
import numpy as np

class ExpSetup:

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
        self.detection = [det]
        self.collision = [col]
        self.nbr_results = 1

        self.results = Counter([ExpResult(min_dist, min_ttc, min_dist_awa, det, col)])

    def __str__(self):
        return "### Scenario (x0P=" + str(self.ped_x) + ", y0P=" + str(self.ped_y) + ", Th0P=" + str(self.ped_orient) + ", v0P=" + str(self.ped_speed) + ", v0C=" + str(self.car_speed) + ") ###"

    def __eq__(self, other):
        return self.ped_x == other.ped_x and self.ped_y == other.ped_y and self.ped_orient == other.ped_orient \
               and self.ped_speed == other.ped_speed and self.car_speed == other.car_speed

    def __lt__(self, other):
        return self.ped_x < other.ped_x

    def add_result(self, min_dist, min_ttc, min_dist_awa, det, col):
        self.min_dist.append(min_dist)
        self.min_dist_counter.update([min_dist])
        self.min_ttc.append(min_ttc)
        self.min_ttc_counter.update([min_ttc])
        self.min_dist_awa.append(min_dist_awa)
        self.min_dist_awa_counter.update([min_dist_awa])
        self.detection.append(det)
        self.collision.append(col)
        self.nbr_results += 1

        self.results.update([ExpResult(min_dist, min_ttc, min_dist_awa, det, col)])

    def get_nbr_results(self):
        return self.nbr_results

    def get_results(self):
        return self.results

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
        if len(self.min_dist) == 1:
            return 0
        else:
            return statistics.stdev(self.min_dist)

    def get_avg_min_ttc(self):
        sum = 0
        for res in self.min_ttc:
            sum += res
        return sum / len(self.min_ttc)

    def get_sd_min_ttc(self):
        if len(self.min_ttc) == 1:
            return 0
        else:
            return statistics.stdev(self.min_ttc)

    def get_avg_min_dist_awa(self):
        sum = 0
        for res in self.min_dist_awa:
            sum += res
        return sum / len(self.min_dist_awa)

    def get_sd_min_dist_awa(self):
        if len(self.min_dist_awa) == 1:
            return 0
        else:
            return statistics.stdev(self.min_dist_awa)

    def get_nbr_detections(self):
        sum = 0
        for res in self.detection:
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


class ExpResult:

    def __init__(self, min_dist, min_ttc, min_dist_awa, det, col):
        self.min_dist = min_dist
        self.min_ttc = min_ttc
        self.min_dist_awa = min_dist_awa
        self.detection = det
        self.collision = col

    @property
    def get_min_dist(self):
        return self.min_dist

    @property
    def get_min_ttc(self):
        return self.min_ttc

    @property
    def get_min_dist_awa(self):
        return self.min_dist_awa

    @property
    def get_detected(self):
        return self.detection

    @property
    def get_collision(self):
        return self.collision

    def __str__(self):
        return "\tOF1=" + str(self.min_dist) + ", OF2=" + str(self.min_ttc) + ", OF3=" + str(self.min_dist_awa) + ", Detection=" + str(self.detection) + ", Collision=" + str(self.collision)

    def __eq__(self, other):
        return self.min_dist == other.min_dist and self.min_ttc == other.min_ttc and self.min_dist_awa == other.min_dist_awa \
               and self.detection == other.detection and self.collision == other.collision

    def __lt__(self, other):
        return self.min_dist < other.min_dist

    def __hash__(self):
        return hash((self.min_dist, self.min_ttc, self.min_dist_awa, self.detection, self.collision))

dir_name = 'prosivic_results'
result_dataframes = []
scenario_results = []

for filename in os.listdir(dir_name):
    if filename.endswith(".csv"):
        df = pd.read_csv(dir_name + "\\" + filename)
        for index, row in df.iterrows():
            exp_setup = ExpSetup(row['ped_x'], row['ped_y'], row['ped_orient'], row['ped_speed'], row['car_speed'], row['of1'], row['of2'], row['of3'], row['detection'], row['collision'])
            if exp_setup not in scenario_results:
                scenario_results.append(exp_setup)
            else:
                #print("Adding results to: " + str(conf))
                i = scenario_results.index(exp_setup)
                scenario_results[i].add_result(row['of1'], row['of2'], row['of3'], row['detection'], row['collision'])

with open('mode_prosivic_results.csv', mode='w') as merged_file:
    mode_writer = csv.writer(merged_file, delimiter=',')
    mode_writer.writerow(['x0P', 'y0P', 'Th0P', 'v0P', 'v0C', 'OF1', 'OF2', 'OF3', 'det', 'col', 'conf'])

    #merge_writer.writerow(['x0P', 'y0P', 'Th0P', 'v0P', 'v0C', 'nbr', 'OF1_unique', 'OF1_avg', 'OF1_sd', 'OF2_unique', 'OF2_avg', 'OF2_sd', 'OF3_unique', 'OF3_avg', 'OF3_sd', 'det_true', 'det_false', 'col_true', 'col_false'])

    for exp_setup in scenario_results:
        print("\n" + str(exp_setup))
        print("\tNumber of results: " + str(exp_setup.get_nbr_results()))
        res = exp_setup.get_results()
        for result, count in res.most_common():
            print("\t" + str(count) + "x:" + str(result))

        unique_per_of = exp_setup.get_nbr_unique_results()
        print("\t\t# Result per objective function #")
        print("\t\tmin_dist:\t\tUnique = " + str(len(unique_per_of["of1"])) + "\tAvg = " + str(exp_setup.get_avg_min_dist()) + "\tSD = " + str(exp_setup.get_sd_min_dist()))
        print("\t\t\tCounter min_dist: " + str(exp_setup.min_dist_counter))
        print("\t\tmin_ttc:\t\tUnique = " + str(len(unique_per_of["of2"])) + "\tAvg = " + str(exp_setup.get_avg_min_ttc()) + "\tSD = " + str(exp_setup.get_sd_min_ttc()))
        print("\t\t\tCounter min_ttc: " + str(exp_setup.min_ttc_counter))
        print("\t\tmin_dist_awa:\tUnique = " + str(len(unique_per_of["of3"])) + "\tAvg = " + str(exp_setup.get_avg_min_dist_awa()) + "\tSD = " + str(exp_setup.get_sd_min_dist_awa()))
        print("\t\t\tCounter min_dist_awa: " + str(exp_setup.min_dist_awa_counter))
        print("\t\tNumber detections: " + str(exp_setup.get_nbr_detections()) + " (out of " + str(exp_setup.get_nbr_results()) + " = " + str(100 * (exp_setup.get_nbr_detections()/exp_setup.get_nbr_results())) + "%)")
        print("\t\tNumber collisions: " + str(exp_setup.get_nbr_collisions()) + " (out of " + str(exp_setup.get_nbr_results()) + " = " + str(100 * (exp_setup.get_nbr_collisions()/exp_setup.get_nbr_results())) + "%)")

        mode_result = res.most_common(1)[0][0] # this is the most common ExpResult (first element in first tuple in first element in the Counter)
        conf = (res.most_common(1)[0][1]/exp_setup.get_nbr_results()) # this is the count of the most common results divided by the total number

        mode_writer.writerow([exp_setup.ped_x, exp_setup.ped_y, exp_setup.ped_orient, exp_setup.ped_speed, exp_setup.car_speed, mode_result.min_dist, mode_result.min_ttc, mode_result.min_dist_awa, mode_result.detection, mode_result.collision, conf])
        #merge_writer.writerow([exp_setup.ped_x, exp_setup.ped_y, exp_setup.ped_orient, exp_setup.ped_speed, exp_setup.car_speed, exp_setup.get_nbr_results(), len(unique_per_of["of1"]), exp_setup.get_avg_min_dist(), exp_setup.get_sd_min_dist(), len(unique_per_of["of2"]), exp_setup.get_avg_min_ttc(), exp_setup.get_sd_min_ttc(), len(unique_per_of["of3"]), exp_setup.get_avg_min_dist_awa(), exp_setup.get_sd_min_dist_awa(), exp_setup.get_nbr_detections(), (exp_setup.get_nbr_results() - exp_setup.get_nbr_detections()), exp_setup.get_nbr_collisions(), (exp_setup.get_nbr_results() - exp_setup.get_nbr_collisions())])
