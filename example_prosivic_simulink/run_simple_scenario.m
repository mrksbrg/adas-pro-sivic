% Input: xPerson yPerson thetaPerson vPerson vCar
mfilepath=fileparts(which('run_simple_scenario.m'));
tic
prev_time = -1; % used to check timestamps in Pro-SiVIC
v0C = 70;
ped_x = -23;
ped_y = -120;
ped_orient = 65;
ped_speed = 3;
    
%*** RUN the Simulation in Pro-SiVIC
% load the static scene
ret = sendCommand('LOAD', 'localhost', 'example_scene.script');

% set properties of the car (that has cruise control)
init_car_speed_cmd = ['ego_car/car.SetInitSpeed ' num2str(car_speed)];
init_car_speed_limit_cmd = ['ego_car/car.SetInitSpeedLimit ', num2str(car_speed)];
ret = sendCommand('COMD', 'localhost', init_car_speed_cmd);
ret = sendCommand('COMD', 'localhost', init_car_speed_limit_cmd);

% set properties for the pedestrian
init_ped_position_cmd = ['dummy/pedestrian.SetPosition ' num2str(ped_x) num2str(ped_y)]; % skip the Z coordinate, road is ground
ret = sendCommand('COMD', 'localhost', init_ped_position_cmd);
init_ped_orientation_cmd = ['dummy/pedestrian.SetInitAngle 0 0 ' num2str(ped_orient)];
ret = sendCommand('COMD', 'localhost', init_ped_orientation_cmd);
set_ped_speed_cmd = ['dummy/pedestrian.SetSpeed ' num2str(ped_speed)];
% speed command must be sent after the simulation has started

% pause the simulation (in order to later launch pass command)
ret = sendCommand('PAUSE', 'localhost');
ret = sendCommand('COMD', 'localhost', set_ped_speed_cmd);

% execute X simulation steps
nbr_sim_steps = 5000; % 5000 is good
step = 1;
if prev_time <= 1
    prev_time = 0;
end

ret = sendCommand('PLAY', 'localhost');

sim(fullfile(mfilepath,'/simulink_example.slx'));

%***
SimTicToc=toc

