# for each start y
#	for each orientation o
#		create a straight line in a trk-file named accordingly
#
# for each trk-file
#	for each x-offset
#		for each ped_speed
#			create a corresponding trj file

import numpy as np

for y in np.arange(-134, -111, 6.5): # later: step 0.5
	for o in range(38, 138, 50): # later: step 1
		filename = "generated_trajectories\\" + str(y) + "_" + str(o) + ".trk"
		f = open(filename, "w")
		print(filename)