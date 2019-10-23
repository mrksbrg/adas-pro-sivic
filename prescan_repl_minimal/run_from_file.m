mfilepath=fileparts(which('run_from_file.m'));
addpath(fullfile(mfilepath,'/Functions'));
addpath(fullfile(mfilepath,'/GA'));

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
    
    % Debug scenario (no detection)
    %x0P=206.937812; y0P=309.450342; ThP=-28.096459 v0P=4.192310;v0C=86.042553;),
    
    % 206.516373  309.243690  -26.124790  4.182511  86.963155
    % 247.641689  312.517152  -115.855551  3.255967  55.519299
    % 237.058823  310.465038  -52.784776  3.842063  71.061850
    
    
%     ped_x = 78.833717;
%     ped_y = 41.544314;
%     ped_orient = 95.596676;
%     ped_speed = 2.386074;
%     car_speed = 25.000000
    
    % PreScan: 37.109120  43.119186  123.633950  4.258442  18.193262
    % 78.833717  41.544314  95.596676  2.386074  25.000000
    
    prescan_x = 78.833717;
    prescan_y = 41.544314;
    prescan_orient = 95.596676;
    ped_speed = 1.886074;
    prescan_car_speed = 25.000000
    
    % Convert to parameters for horseshoe ground in Pro-SiVIC
    ped_x = x0C - prescan_x
    ped_y = y0C + (50 - prescan_y)
    ped_orient = -180 + prescan_orient
    car_speed = prescan_car_speed * 3.6
    
    %*** RUN simulation in Pro-SiVIC until reaching the stop condition
    run_single_scenario
    
    %***
    
    [BestDist2,TTCMIN,BestDistPAWA] = calcObjFuncs(simOut, ped_orient) %simulationSteps,simOut.xCar,simOut.yCar,simOut.vCar,simOut.xPerson,simOut.yPerson,simOut.vPerson,ped_orient,simOut.TTCcol);
    
    % TEMP CHECK DETECTION
    Det=0;
    MaxD=0;
    for w=1:length(simOut.Detection.signals.values)
        if simOut.Detection.signals.values(w)>MaxD
            MaxD=simOut.Detection.signals.values ( w );
        end
    end
    if MaxD~=0
        Det=1;
    end
    disp(Det)
    
    % TEMP CHECK COLLISION
    MaxColl=0;
    for bb=1: size(simOut.Collision.signals.values,1)
        if simOut.Collision.signals.values(bb) > MaxColl
            MaxColl=simOut.Collision.signals.values(bb);
        end
    end
    
    if MaxColl~= 0
        CollisionYesNo=1;
    else
        CollisionYesNo=0;
    end
    disp(CollisionYesNo)
    
    SimTicToc = toc
    scenario(i,V+1) = SimTicToc;
end

% save to .csv file
formatOut = 'yyyymmdd_HHMMss_FFF';

ds=datestr(now,formatOut);
name = strcat('TestResults_',ds,'.csv');
fid =  fopen(name, 'w');
fprintf(fid, '%s  %s  %s  %s  %s  %s \n',['x0P' ',' 'y0P' ',' 'Th0P' ',' 'v0P' ',' 'v0C' ',' 'SimulationTime' ',' 'OF1'  ',' 'OF2'  ',' 'OF3'  ',' 'Det' ',' 'Col']);
fprintf(fid, '\n');
clear EC
EC(:,1:6)=scenario;
EC(:,7)=BestDist2;
EC(:,8)=TTCMIN;
EC(:,9)=BestDistPAWA;
EC(:,10)=Det;
EC(:,11)=CollisionYesNo;
clear a;
for i=1:size(EC,1)
    a(:,i)=EC(i,:);
end
fprintf(fid, '%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f,%d,%d \n', a);
