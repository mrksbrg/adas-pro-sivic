% Input: xPerson yPerson tetaPerson vPerson vCar
mfilepath=fileparts(which('runTest1.m'));

prev_time = -1; % used to check timestamps in Pro-SiVIC
population_size=5;

x0C=-72.7; y0C=-109; % this is where the center of the car is in Pro-SiVIC
min_r=[x0C+20;y0C-15;38;1;1]; %[min_x_person; min_y_person;min_orientation_person;min_speed_person;min_speed_car]
max_r=[x0C+85; y0C-2;158;5;25];%[max_x_person; max_y_person;max_orientation_person;max_speed_person;max_speed_car]

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
    
    %*** RUN the Simulation in Pro-SiVIC
    run_single_ProSiVIC_scenario
    %***
    SimTicToc=toc
    scenario(i,V+1)=SimTicToc;
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