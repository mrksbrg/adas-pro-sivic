% First PreScan replication, straight road
%clear all
%clear mex
%for car_speed = 5:30:35
%    for ped_x = -60:40:-20
        car_speed = 55;
        ped_x = -23;
        ped_y = -117.5;
        ped_orient = 65;
        ped_speed = 2.25;

        % load the static scene
        ret = sendCommand('LOAD', 'localhost', 'prescan_repl_1.script');
        
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

        % create sivicTime object
        ret = sendCommand('COMD', 'localhost', 'new sivicTime timeWrapper');
        ret = sendCommand('SETP', 'localhost','timeWrapper','ExportMode','Mode_on');

        % pause the simulation (in order to launch pass command)
        ret = sendCommand('PAUSE', 'localhost');
        ret = sendCommand('COMD', 'localhost', set_ped_speed_cmd);
        
        % execute X simulation steps
        nbr_sim_steps = 5000; % 5000 is good
        step = 0;
        while step < nbr_sim_steps
            ret = sendCommand('COMD', 'localhost', 'pass 8'); % matching the 0.040 periodicity     
            [car_head, car_data] = ProSiVIC_DDS('car_obs','objectobserver');
            [ped_head, ped_data] = ProSiVIC_DDS('ped_obs','objectobserver');
            %[cam_head, cam_data] = ProSiVIC_DDS('ego_car/chassis/dashcam/cam','camera')
            
            % check three stop criteria
            car_data(1)
            if (car_data(1) > 23)% || (ped_data(2) > (car_data(2) + 2)) || (ped_data(1) < car_data(1) + 1)
                break
                % flush whatever DDS messages are there            
            end
            step = step + 1;
        end
        
        ret = sendCommand('STOP', 'localhost');
        
        % retreive the simulation time
        SimuTime = sendCommand ('GETP','localhost','timeWrapper','SimuTime')
%    end
%end
