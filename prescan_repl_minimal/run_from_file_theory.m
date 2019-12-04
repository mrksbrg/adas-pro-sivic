% This script calculates theoretical trajectories for a PreScan or Pro-SiVIC
% scenario, finds the time where the distance between the car and the
% pedestrian is the smallest and returns this value.
%
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

%%%%%%%%%%%%%%%%%%%%%%
%%% INITIALIZATION %%%
%%%%%%%%%%%%%%%%%%%%%%

mfilepath = fileparts(which('run_from_file_theory.m'));
addpath(fullfile(mfilepath,'/utils'));
addpath(fullfile(mfilepath,'/genetic_algo'));
long_time_format = 'yyyymmdd_HHMMss_FFF';
imported_data = importdata('input/test_input.csv', ',');
sivic_input = 1; % 0 = PreScan input, 1 = Pro-SiVIC input
results_PreScan = imported_data;

% initialize result matrix with NaN for all elements
results_theory = NaN(size(imported_data, 1), 6);

% The center of the Mini Cooper in the Pro-SiVIC scene is (282.70, 301.75)
% Note that this corresponds to a chassis at x=284.0 in Pro-SiVIC, as the
% rear axis is the primary point for positioning. To compensate for this,
% we subtract 1.3 m from xCar in the Simulink model.
car_x0 = 282.70;
car_y0 = 301.75;

for i = 1:size(imported_data,1)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 1. SET UP SCENARIO %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if sivic_input == 0 % convert input values if they come from PreScan
        ped_x0_PreScan = imported_data(i,1); % x of the pedestrian
        ped_y0_PreScan = imported_data(i,2); % x of the pedestrian
        ped_orient_PreScan = imported_data(i,3); % orientation of the pedestrian
        ped_v_PreScan = imported_data(i,4); % speed of the pedestrian in m/s
        car_v_PreScan = imported_data(i,5); % speed of the car in m/s
        
        ped_x = car_x0 - ped_x0_PreScan;
        ped_y = car_y0 + (50 - ped_y0_PreScan);
        ped_orient = -180 + ped_orient_PreScan;
        ped_speed = ped_v_PreScan;
        car_speed = 3.6 * car_v_PreScan;
        
    else % otherwise read them directly from file
        ped_x = imported_data(i,1); % x of the pedestrian
        ped_y = imported_data(i,2); % x of the pedestrian
        ped_orient = imported_data(i,3); % orientation of the pedestrian
        ped_speed = imported_data(i,4); % speed of the pedestrian in m/s
        car_speed = imported_data(i,5); % speed of the car in m/s
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 2. CALCULATE THEORETICAL DISTANCES %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    sim_time_step = 0.005;
    sim_time = 10;
    min_dist_theory = calc_min_dist_theory(sim_time_step, sim_time, car_x0,...
        car_y0, car_speed, ped_x, ped_y, ped_orient, ped_speed);
    
    % store results for printing to file
    results_theory(i,1) = ped_x;
    results_theory(i,2) = ped_y;
    results_theory(i,3) = ped_orient;
    results_theory(i,4) = ped_speed;
    results_theory(i,5) = car_speed;
    results_theory(i,6) = min_dist_theory;
    
end % one individual scenario

%%%%%%%%%%%%%%%%%%%%%%%%
%%% 3. Print results %%%
%%%%%%%%%%%%%%%%%%%%%%%%

time_now = datestr(now, long_time_format);
file_theory = strcat('output/results_theory_', time_now, '.csv');
fid = fopen(file_theory, 'w');
fprintf(fid, '%s\n',['theory_x0p' ',' 'theory_y0p' ',' 'theory_orient' ','...
    'theory_v0p' ',' 'theory_v0c' ',' 'theory_of1']);
clear EC
EC(:,1:6) = results_theory;
clear a;
for i = 1 : size(EC, 1)
    a(:, i) = EC(i, :);
end
fprintf(fid, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f \n', a);
fclose(fid);