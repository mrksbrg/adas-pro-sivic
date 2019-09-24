% First PreScan replication, straight road
prev_time = -1;

for car_speed = 5:30:35
    for ped_x = -60:40:-20
        %car_speed = 55;
        %ped_x = -23;
        ped_y = -117.5;
        ped_orient = 65;
        ped_speed = 2.25;

        % load the static scene
        %ret = sendCommand('PAUSE', 'localhost');
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

        % pause the simulation (in order to launch pass command)
        ret = sendCommand('PAUSE', 'localhost');
        ret = sendCommand('COMD', 'localhost', set_ped_speed_cmd);
        
        % execute X simulation steps
        nbr_sim_steps = 5000; % 5000 is good
        step = 1;
        if prev_time <= 1
            prev_time = 0;
        end
        
        % Instructions used for debugging
        %ret = sendCommand('SYNCHRODDS', 'localhost');
        ret = sendCommand('COMD', 'localhost', 'pass 8'); % workaround: ignore the first
        [car_head, car_data] = ProSiVIC_DDS('car_obs','objectobserver');
        [ped_head, ped_data] = ProSiVIC_DDS('ped_obs','objectobserver');
        [cam_head, cam_data] = ProSiVIC_DDS('ego_car/chassis/dashcam/cam','camera');      
        dds_times = [0:1:50];
        tcp_times = [0:1:50];
        pause(1)
        
        while step < nbr_sim_steps
            [time_head, time_data] = ProSiVIC_DDS('timeWrapper','time');
            dds_times(step) = time_head(1);
            
            % Instructions used for debugging
            tcp_time = sendCommand ('GETP','localhost','timeWrapper','SimuTime');           
            tcp_times(step) = str2num(tcp_time);
            
            ret = sendCommand('COMD', 'localhost', 'pass 8'); % matching the 0.040 periodicity     
            [car_head, car_data] = ProSiVIC_DDS('car_obs','objectobserver');
            [ped_head, ped_data] = ProSiVIC_DDS('ped_obs','objectobserver');
            [cam_head, cam_data] = ProSiVIC_DDS('dashcam/cam','camera');
            %imshow(cam_data)
            [radar_head, target_data] = ProSiVIC_DDS('radar/radar','radar');
                                    
            % Information that shall be sent to PDS
            ego_car_speed = car_data(7);
            ego_car_orient = car_data(6);
            if radar_head(2) > 0
                ped_dist = target_data(1);
                ped_long_speed = target_data(3);
                ped_azimuth = target_data(2);
            else
                ped_dist = -1;
                ped_long_speed = -1;
                ped_azimuth = -1;
            end       
                
            % check three stop criteria  
            if ped_head(1) ~= prev_time            
                %disp(step);
                ped_data(1);
                car_data(1);
                if (car_data(1) > 23)
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
    end
end
