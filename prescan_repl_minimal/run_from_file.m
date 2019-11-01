% This script demonstrates reads input parameters from a file and runs the
% corresponding scenarios in Pro-SiVIC.
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

mfilepath = fileparts(which('run_from_file.m'));
addpath(fullfile(mfilepath,'/utils'));
addpath(fullfile(mfilepath,'/genetic_algo'));
short_time_format = 'yyyymmdd_HHMMss';
long_time_format = 'yyyymmdd_HHMMss_FFF';
sivic_input = 0;
imported_data = importdata('input/PreScan_data_1.csv', ',');
% initialize result matrix with NaN for all elements
results_ProSivic = NaN(size(imported_data, 1), 10) * -1;
results_theory = NaN(size(imported_data, 1), 6) * -1;
warning off

% The center of the Mini Cooper in the Pro-SiVIC scene is (282.70, 301.75)
% Note that this corresponds to a chassis at x=284.0 in Pro-SiVIC, as the
% rear axis is the primary point for positioning. To compensate for this,
% we subtract 1.3 m from xCar in the Simulink model.
car_x0 = 282.70;
car_y0 = 301.75;

nbr_iterations = 1;
for iteration = 1:nbr_iterations % due to package loss between Pro-SiVIC and Simulink, we might want to run multiple times
    time_now = datestr(now, short_time_format);
    fprintf('%s - Starting iteration %s out of %s\n', time_now, int2str(iteration), int2str(nbr_iterations));
    for i = 1 : size(imported_data,1)
        tic
        
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
        
        sim_time = toc;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% 4. CALCULATE GROUND TRUTH DISTANCES %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % create a vector matching the simulation time
        sim_time_step = 0.005;
        sim_time = 10;
        nbr_sim_steps = sim_time / sim_time_step;
        ped_traj = NaN(nbr_sim_steps, 2);
        car_traj = NaN(nbr_sim_steps, 2);
        
        % car start position
        car_traj(1,1) = car_x0;
        car_traj(1,2) = car_y0;
        car_step_length = (car_speed / 3.6) * sim_time_step;
        for j = 2:nbr_sim_steps
            car_traj(j,1) = car_traj(j-1,1) - car_step_length;
            car_traj(j,2) = car_traj(j-1,2);
        end
        
        % pedestrian start position
        ped_traj(1,1) = ped_x;
        ped_traj(1,2) = ped_y;
        ped_step_length = ped_speed * sim_time_step;
        
        if ped_orient > -90
            % the pedestrian's x component does not match the car, i.e., x is increasing
            alpha = abs(0-ped_orient);
            for j = 2:nbr_sim_steps
                ped_traj(j,1) = ped_traj(j-1,1) + ped_step_length*sind(alpha);
                ped_traj(j,2) = ped_traj(j-1,2) - ped_step_length*cosd(alpha);
            end
            
        elseif ped_orient < -90
            % the pedestrian's x component matches the car, i.e., x is decreasing
            alpha = abs(-180-ped_orient);
            for j = 2:nbr_sim_steps
                ped_traj(j,1) = ped_traj(j-1,1) - ped_step_length*sind(alpha);
                ped_traj(j,2) = ped_traj(j-1,2) - ped_step_length*cosd(alpha);
            end
            
        else
            % the pedestrian runs perpendicularly to the road, i.e., x is constant
            for j = 2:nbr_sim_steps
                ped_traj(j,1) = ped_traj(j-1,1);
                ped_traj(j,2) = ped_traj(j-1,2) - ped_step_length;
            end
        end
        
        % calculate the minimum distance in an ideal world
        theory_distances = NaN(nbr_sim_steps, 1);
        theory_min_dist = realmax;
        for j = 1:nbr_sim_steps
            theory_distances(j) = sqrt((car_traj(j,1)-ped_traj(j,1))^2 + (car_traj(j,2)-ped_traj(j,2))^2);
            if theory_distances(j) < theory_min_dist
                theory_min_dist = theory_distances(j);
            end
        end
        
        % store results for later file writing        
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
        
        results_theory(i,1) = ped_x;
        results_theory(i,2) = ped_y;
        results_theory(i,3) = ped_orient;
        results_theory(i,4) = ped_speed;
        results_theory(i,5) = car_speed;
        results_theory(i,6) = theory_min_dist;
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Print Pro-SiVIC results %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    time_now = datestr(now, short_time_format);
    fprintf('%s - Iteration complete, writing results to file\n' , time_now);

    time_now = datestr(now, long_time_format);
    file_ProSivic = strcat('output/results_Pro-SiVIC-', time_now, '.csv');
    fid_2 = fopen(file_ProSivic, 'w');
    
    fprintf(fid_2, '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'OF1' ',' 'OF2' ',' 'OF3'  ',' 'Det' ',' 'Coll']);
    fprintf(fid_2, '\n');
    
    clear tmp_results
    tmp_results(:, 1:10) = results_ProSivic;
    clear final_results;
    
    for i = 1:size(tmp_results, 1)
        final_results(:, i) = tmp_results(i, :);
    end
    
    fprintf(fid_2, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%d \n', final_results);  
    fclose(fid_2);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Print theoretical results %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    file_theory = strcat('output/results_theory-', time_now, '.csv');
    fid_3 = fopen(file_theory, 'w');
    
    fprintf(fid_3, '%s\n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'OF1_truth']);
    
    clear tmp_results
    tmp_results(:,1:6) = results_theory;
    clear final_results
    
    for i = 1:size(tmp_results, 1)
        final_results(:, i) = tmp_results(i, :);
    end
    
    fprintf(fid_3, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f \n', final_results);
    fclose(fid_3);
    
end