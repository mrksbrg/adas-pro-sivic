mfilepath=fileparts(which('run_loop_ProSiVIC.m'));

population_size=1;

x0C=282.741; y0C=301.75; % this is where the center of the car is in Pro-SiVIC
min_r=[x0C-85;y0C+2;-140;1;1*3.6]; %[min_x_person; min_y_person;min_orientation_person;min_speed_person;min_speed_car]
max_r=[x0C-20;y0C+15;-20;5;25*3.6];%[max_x_person; max_y_person;max_orientation_person;max_speed_person;max_speed_car]

V=size(min_r,1);
scenario = zeros(population_size, V);
% Initialize the population

for i = 1 : population_size
    tic
    for j = 1 : V
        scenario(i,j) = (min_r(j) + (max_r(j) - min_r(j))*rand(1));
    end
    
    ped_x = scenario(i,1);
    ped_y = scenario(i,2);
    ped_orient = scenario(i,3);
    ped_speed = scenario(i,4);
    car_speed = scenario(i,5);
    
    % Scenario without detection: x0P=233.571311;  y0P=315.683983; ThP= -61.711837; v0P=2.817673; v0C=  90.000000
    % x0P=206.496730; y0P=309.754843 ThP= -29.752820  v0P=4.000000  v0C=85.078100;
    
    ped_x = 206.496730;
    ped_y = 309.754843;
    ped_orient = -29.752820;
    ped_speed = 4.000000;
    car_speed = 85.078100;
    
    %
    % Scenario with detection:  x0P=252.941874;  y0P=308.036294;  ThP=-91.541030;  v0P=2.160456; v0C=43.006057
    
    
    % x0P=206.975508;  y0P=309.150958  ThP=-30.062620  v0P=4.157015  v0C=86.489625;
    
    %     ped_x = 206.975508;
    %     ped_y = 309.150958;
    %     ped_orient = -30.062620;
    %     ped_speed = 4.157015;
    %     car_speed = 86.489625;
    
    %
    
    
    % Pro-SiVIC scenario with collision
    %     ped_x = 255;
    %     ped_y = 306;
    %     ped_orient = -65;
    %     ped_speed = 0.943505;
    %     car_speed = 17.532561;
    
    %Scenario 0 without Detection (SAME)
    %     prescan_x=47.300568
    %     prescan_y=40.783088
    %     prescan_orient=74.212567
    %     ped_speed=2.943505
    %     prescan_car_speed=17.532561
    
    %     %Scenario 1 without Detection (SAME)
    %     prescan_x=79.383629
    %     prescan_y=41.363451
    %     prescan_orient=96.567029
    %     ped_speed= 2.251676
    %     prescan_car_speed=23.596347
    %
    %     %Scenario 2 without Detection (SAME)
    %     prescan_x=28.469391;
    %     prescan_y=47.494615;
    %     prescan_orient=157.742920;
    %     ped_speed=3.625910;
    %     prescan_car_speed=24.305435;
    %
    %     %Scenario 3 without Detection (SAME)
    %     prescan_x=57.747341
    %     prescan_y=44.355933
    %     prescan_orient=50.774477
    %     ped_speed=2.036843
    %     prescan_car_speed=22.214259
    %
    %     %Scenario 1 with Detection (DIFFERENT)
    %     prescan_x=47.300568
    %     prescan_y=40.783088
    %     prescan_orient=74.212567
    %     ped_speed=2.943505
    %     prescan_car_speed=17.532561
    %
    %     %Scenario 2 with Detection (DIFFERENT)
    %     prescan_x=54.199988
    %     prescan_y=41.228122
    %     prescan_orient=46.629705
    %     ped_speed=3.218916
    %     prescan_car_speed=19.209868
    
    % Convert to parameters for horseshoe ground in Pro-SiVIC
    %     ped_x = x0C - prescan_x
    %     ped_y = y0C + (50 - prescan_y)
    %     ped_orient = -180 + prescan_orient
    %     car_speed = prescan_car_speed * 3.6
    % -30 degrees works
    %ped_orient = -172.5
    
    %*** RUN simulation in Pro-SiVIC until reaching the stop condition
    load_system(fullfile(mfilepath,'/prescan_repl_pds.slx'));
    
    run_single_ProSiVIC_scenario
    
    %***
    
    % Doesn't work!
    % Check the stop conditions in the Simulink model
    %for i=1:length(simOut.flagStop.signals.values)
    %    if (simOut.flagStop.signals.values(i)==1)
    %        ret = sendCommand('STOP', 'localhost');
    %        disp('STOP command sent to Pro-SiVIC')
    %    end
    %end
    
    SimTicToc = toc
    scenario(i,V+1) = SimTicToc;
end

% save to .csv file
formatOut = 'yyyymmdd_HHMMss_FFF';

ds=datestr(now,formatOut);
name = strcat('TestResults_',ds,'.csv');
fid =  fopen(name, 'w');
fprintf(fid, '%s  %s  %s  %s  %s  %s \n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'SimulationTime']);
fprintf(fid, '\n');
clear EC
EC(:,1:6)=scenario;
clear a;
for i=1:size(EC,1)
    a(:,i)=EC(i,:);
end
fprintf(fid, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f \n', a);
