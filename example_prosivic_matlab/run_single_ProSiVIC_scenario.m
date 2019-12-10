% load the static scene
ret = sendCommand('LOAD', 'localhost', 'simple_scene.script');

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

% Workaround: intentionally drop the first data from DDS
ret = sendCommand('COMD', 'localhost', 'pass 8'); % workaround: ignore the first
[car_head, car_data] = ProSiVIC_DDS('car_obs','objectobserver');
[ped_head, ped_data] = ProSiVIC_DDS('ped_obs','objectobserver');
[cam_head, cam_data] = ProSiVIC_DDS('ego_car/chassis/dashcam/cam','camera');
[radar_head, target_data] = ProSiVIC_DDS('radar/radar','radar');
pause(1)

while step < nbr_sim_steps    
    ret = sendCommand('COMD', 'localhost', 'pass 8'); % matching the 0.040 periodicity
    [car_head, car_data] = ProSiVIC_DDS('car_obs','objectobserver');
    [ped_head, ped_data] = ProSiVIC_DDS('ped_obs','objectobserver');
    [cam_head, cam_data] = ProSiVIC_DDS('dashcam/cam','camera');
    [radar_head, target_data] = ProSiVIC_DDS('radar/radar','radar');
    
    % check three stop criteria
    if ped_head(1) ~= prev_time
        if (car_data(1) > 27)
            disp("### Stopping simulation: Car drove 100 m")
            break
        elseif (ped_data(2) > (car_data(2) + 2))
            disp("### Stopping simulation: Pedestrian crossed the street")
            break
        elseif (ped_data(1) < (car_data(1) + 3.6))
            disp("### Stopping simulation: Car passed the pedestrian")
            break
        end
        step = step + 1;
    else
        disp("  - Received the same timestamp again... Time: " + ped_head(1))
    end
    prev_time = ped_head(1);
end

ret = sendCommand('STOP', 'localhost');

% retreive the simulation time
SimuTime = sendCommand ('GETP','localhost','timeWrapper','SimuTime')
pause(1)