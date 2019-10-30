class Configuration:

    def __init__(self, ped_x, ped_y, ped_orient, ped_speed, car_speed, min_dist, min_ttc, min_dest_awa, det, col):
        self.ped_x = ped_x
        self.ped_y = ped_y
        self.ped_orient = ped_orient
        self.ped_speed = ped_speed
        self.car_speed = car_speed
        self.min_dist = [min_dist]
        self.min_ttc = [min_ttc]
        self.min_dist_awa = [min_dest_awa]
        self.detected = [det]
        self.collision = [col]

    def __str__(self):
        return self.ped_x + ", " + self.ped_y + ", " + self.ped_orient + ", " + ped_speed + ", " + car_speed

    def __eq__(self, other):
        return self.ped_x == other.ped_x and self.ped_y == other.ped_y and self.ped_orient == other.ped_orient \
               and self.ped_speed == other.ped_speed and self.car_speed == other.car_speed

    def __lt__(self, other):
        return self.ped_x < other.ped_x
