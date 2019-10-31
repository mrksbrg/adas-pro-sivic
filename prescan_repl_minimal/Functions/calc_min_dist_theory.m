%  Copyright (c) 2019, Markus Borg
%  All rights reserved.
%
%  Redistribution and use in source and binary forms, with or without
%  modification, are permitted provided that the following conditions are
%  met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
%  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
%  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
%  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
%  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
%  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
%  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
%  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
%  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
%  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
%  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
%  POSSIBILITY OF SUCH DAMAGE.

function [min_dist_theory] = calc_min_dist_theory(sim_time_step, sim_time, car_x0, car_y0, car_speed, ped_x, ped_y, ped_orient, ped_speed)
        
% create vectors matching the simulation time
nbr_sim_steps = sim_time / sim_time_step;
ped_traj = NaN(nbr_sim_steps, 2);
car_traj = NaN(nbr_sim_steps, 2);

% calculate car trajectory
car_traj(1, 1) = car_x0;
car_traj(1, 2) = car_y0;
car_step_length = (car_speed / 3.6) * sim_time_step;
for j = 2:nbr_sim_steps
    car_traj(j, 1) = car_traj(j-1, 1) - car_step_length;
    car_traj(j, 2) = car_traj(j-1, 2);
end

% calculate pedestrian trajectory
ped_traj(1, 1) = ped_x;
ped_traj(1, 2) = ped_y;
ped_step_length = ped_speed * sim_time_step;
if ped_orient > -90
    % the pedestrian's x component does not match the car, i.e., x is increasing
    alpha = abs(0 - ped_orient);
    for j = 2:nbr_sim_steps
        ped_traj(j, 1) = ped_traj(j-1, 1) + ped_step_length * sind(alpha);
        ped_traj(j, 2) = ped_traj(j-1, 2) - ped_step_length * cosd(alpha);
    end
    
elseif ped_orient < -90
    % the pedestrian's x component matches the car, i.e., x is decreasing
    alpha = abs(-180 - ped_orient);
    for j = 2:nbr_sim_steps
        ped_traj(j, 1) = ped_traj(j-1, 1) - ped_step_length * sind(alpha);
        ped_traj(j, 2) = ped_traj(j-1, 2) - ped_step_length * cosd(alpha);
    end
    
else
    % the pedestrian runs perpendicularly to the road, i.e., x is constant
    for j = 2:nbr_sim_steps
        ped_traj(j, 1) = ped_traj(j-1, 1);
        ped_traj(j, 2) = ped_traj(j-1, 2) - ped_step_length;
    end
end

% find the minimum distance between car and pedestrian
distances_theory = NaN(nbr_sim_steps, 1);
min_dist_theory = realmax;
for j = 1:nbr_sim_steps
    distances_theory(j) = sqrt((car_traj(j, 1)-ped_traj(j, 1))^2 + (car_traj(j, 2)-ped_traj(j, 2))^2);
    if distances_theory(j) < min_dist_theory
        min_dist_theory = distances_theory(j);
    end
end