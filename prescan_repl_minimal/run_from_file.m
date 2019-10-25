% This script demonstrates reads input parameters from a file and runs the
% corresponding scenarios in Pro-SiVIC.
%
%  Copyright (c) 2019, Raja Ben Abdessalem
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

mfilepath = fileparts(which('run_from_file.m'));
addpath(fullfile(mfilepath,'/Functions'));
addpath(fullfile(mfilepath,'/GA'));

imported_data = importdata('input/test_input.csv', ',');
results_PreScan = imported_data;
% initialize result matrix with NaN for all elements
results_ProSivic = NaN(size(imported_data, 1), 10) * -1;

% the center of the Mini Cooper in the Pro-SiVIC scene is (282.70, 301.75)
x0_car = 282.70;
y0_car = 301.75; 

for i = 1 : size(imported_data,1)
    tic
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 1. SET UP SCENARIO %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    
    x0_ped_PreScan = imported_data(i,1); % x of the pedestrian
    y0_ped_PreScan = imported_data(i,2); % x of the pedestrian
    orient_ped_PreScan = imported_data(i,3); % orientation of the pedestrian
    v_ped_PreScan = imported_data(i,4); % speed of the pedestrian in m/s
    v_car_PreScan = imported_data(i,5); % speed of the car in m/s
    
    ped_x = x0_car - x0_ped_PreScan;
    ped_y = y0_car + (50 - y0_ped_PreScan);
    ped_orient = -180 + orient_ped_PreScan;
    ped_speed = v_ped_PreScan;
    car_speed = 3.6 * v_car_PreScan;
    
    %%%%%%%%%%%%%%%%%%%%%%%
    %%% 2. RUN SCENARIO %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    
    % run simulation in Pro-SiVIC until reaching one of the stop criteria
    run_single_scenario
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 3. EVALUATE RESULTS %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % three objectives to minimize
    % I. min_dist = minimum distance between pedestrian and car
    % II. min_ttc = minimum time to collision
    % III. min_dist_awa = minimum distance between pedestrian and acute warning
    % area (in front of the car)
    [min_dist, min_ttc, min_dist_awa] = calc_obj_funcs(sim_out, ped_orient); 
    
    % check if the simulation resulted in a pedestrian detection
    detection = 0;
    detection_vector = sim_out.Detection.signals.values;
    for j = 1 : length(detection_vector)
        if detection_vector(j) > 0
            detection = 1;
            break
        end
    end
    
    % check if the simulation resulted in a collision with the pedestrian
    collision = 0;
    collision_vector = sim_out.isCollision.signals.values;
    for j = 1 : length(collision_vector)   
        if collision_vector(j) > 0
            collision = 1;
            break
        end
    end
    
    sim_time = toc
    
    results_ProSivic(i,1) = ped_x;
    results_ProSivic(i,2) = ped_y;
    results_ProSivic(i,3) = ped_orient;
    results_ProSivic(i,4) = ped_speed;
    results_ProSivic(i,5) = car_speed;
    results_ProSivic(i,6) = min_dist;
    results_ProSivic(i,7) = min_ttc;
    results_ProSivic(i,8) = min_dist_awa;
    results_ProSivic(i,9) = detection;
    results_ProSivic(i,10) = collision;
      
    results_PreScan(i,6) = min_dist;
    results_PreScan(i,7) = min_ttc;
    results_PreScan(i,8) = detection;
    results_PreScan(i,9) = detection;
    results_PreScan(i,10) = collision;
end

% write results to files
file_PreScan = strcat('output/result_input_PreScan','.csv');
file_ProSivic = strcat('output/result_input_ProSivic','.csv');
fid_1 = fopen(file_PreScan, 'w');
fid_2 = fopen(file_ProSivic, 'w');
fprintf(fid_1, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n', ['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'OF1' ',' 'OF2' ',' 'OF3'  ',' 'Det' ',' 'Coll']);
fprintf(fid_1, '\n');

clear EC
EC(:, 1:10) = results_PreScan;
clear a;

for i = 1 : size(EC, 1)
    a(:, i) = EC(i, :);
end

fprintf(fid_1, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%d \n', a);

fprintf(fid_2, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'OF1' ',' 'OF2' ',' 'OF3'  ',' 'Det' ',' 'Coll']);
fprintf(fid_2, '\n');

clear EC
EC(:,1:10) = results_ProSivic;
clear a;

for i = 1 : size(EC, 1)
    a(:, i) = EC(i, :);
end

fprintf(fid_2, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%d \n', a);
fclose(fid_1);
fclose(fid_2);


% % save to .csv file
% formatOut = 'yyyymmdd_HHMMss_FFF';
% 
% ds=datestr(now,formatOut);
% name = strcat('TestResults_',ds,'.csv');
% fid =  fopen(name, 'w');
% fprintf(fid, '%s  %s  %s  %s  %s  %s \n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'SimulationTime' ',' 'OF1'  ',' 'OF2'  ',' 'OF3'  ',' 'Det' ',' 'Col']);
% fprintf(fid, '\n');
% clear EC
% EC(:,1:6)=scenario;
% EC(:,7)=BestDist2;
% EC(:,8)=TTCMIN;
% EC(:,9)=BestDistPAWA;
% EC(:,10)=det;
% EC(:,11)=col;
% clear a;
% for i=1:size(EC,1)
%     a(:,i)=EC(i,:);
% end
% fprintf(fid, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%d \n', a);
