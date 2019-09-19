% First PreScan replication, straight road

for car_speed = 5:30:35
    for ped_x = -60:40:-20

        %load the static scene
        ret = sendCommand('LOAD', 'localhost', 'prescan_repl_1.script');

        % set properties of the car
        init_speed_cmd = ['ego_car/car.SetInitSpeed ' num2str(car_speed)];
        init_speed_limit_cmd = ['ego_car/car.SetInitSpeedLimit ', num2str(car_speed)];
        ret = sendCommand('COMD', 'localhost', init_speed_cmd);
        ret = sendCommand('COMD', 'localhost', init_speed_limit_cmd);

        % set properties for the pedestrian
        ret = sendCommand('COMD', 'localhost', 'dummy/pedestrian.SetSpeed 2');
        pos_cmd = ['dummy/pedestrian.SetPosition ' num2str(ped_x) ' -115 0'];
        ret = sendCommand('COMD', 'localhost', pos_cmd);
        ret = sendCommand('COMD', 'localhost', 'dummy/pedestrian.SetFileNameTrack ped_crossing')
        ret = sendCommand('COMD', 'localhost', 'dummy/pedestrian.SetFileNameTrajectory ped_crossing')

        %create sivicTime object
        ret = sendCommand('COMD', 'localhost', 'new sivicTime timeWrapper')
        ret = sendCommand('SETP', 'localhost','timeWrapper','ExportMode','Mode_on')

        %pause the simulation (in order to launch pass command)
        ret = sendCommand('PAUSE','localhost')

        %execute X simulation steps
        ret = sendCommand('COMD', 'localhost', 'pass 1000') % 5000 is good

        %retreive the simulation time
        SimuTime = sendCommand ('GETP','localhost','timeWrapper','SimuTime')
    end
end
