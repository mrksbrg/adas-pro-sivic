% This script demonstrates how multi-objective optimization can be used for
% generation of critical scenarios in simulation-based ADAS testing. The script
% implements an evolutionary algorithm, NSGA-II, to find the optimal
% solution for multiple objectives, i.e., the pareto front for the objectives.
%
% The original algorithm NSGA-II was developed by the Kanpur Genetic
% Algorithm Labarotary http://www.iitk.ac.in/kangal/
%
%  Copyright (c) 2009, Aravind Seshadri
%  Copyright (c) 2015-2019, Raja Ben Abdessalem
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

for loops = 1 : 5
    try
        % Initilize the
        mfilepath=fileparts(which('run_NSGAII.m'));
        addpath(fullfile(mfilepath,'/Functions'));
        addpath(fullfile(mfilepath,'/GA'));
        load_system(fullfile(mfilepath,'/pedestrian_detection_system.slx'));
        tic
        
        ST=10;
        Fn_MiLTester_SetSimulationTime(ST);
        MaxAlgorithmIterations=100;
        SimulationTimeStep=0.005;
        startTime = rem(now,1);
        modelRunningTime=0;
        chromosome=[];
        b1=4;
        a1=0;
        
        pop=10;%20
        gen=2;%5
        
        pop = round(pop);
        gen = round(gen);
        
        M=3;
        V=5;
        x0C=282.70; y0C=301.75; % this is where the center of the Mini Cooper is in Pro-SiVIC
        min_range=[x0C-85;y0C+2;-140;1;1*3.6]; %[min_x_person; min_y_person;min_orientation_person;min_speed_person;min_speed_car]
        max_range=[x0C-20;y0C+15;-20;5;25*3.6];%[max_x_person; max_y_person;max_orientation_person;max_speed_person;max_speed_car]
        % Initialize the population
        
        min = min_range;
        max = max_range;
        K = M + V;
        
        NFIT=0;
        for i = 1 : pop
            numpop=i;
            display(numpop);
            AA=[];
            b=0;
            TotSim=10;
            for j = 1 : V
                chromosome(i,j) = (min(j) + (max(j) - min(j))*rand(1));
            end
            
            ped_x=chromosome(i,1)
            ped_y=chromosome(i,2)
            ped_orient=chromosome(i,3)
            ped_speed=chromosome(i,4)
            car_speed=chromosome(i,5)
            
            %chromosome(i,V+1:K)=[];
            sum1 = 0;
            sum2 = 0;
            sum3 = 0;
            D=1;
            BestDist=60;
            BestDist2=100;
            TTCMIN=4;
            BestDistPAWA=50;
            MaxD=0;
            Det=0;
            
            %***
            %%%% Change position and orientation of Pedestrian
            %%%%%%%%% Generate the experiment %%%%%%%%%
            run_single_scenario
            
            %%%%
            %Run Simulation
            
            %***
            for w=1:length(sim_out.Detection.signals.values)
                if sim_out.Detection.signals.values(w)>MaxD
                    MaxD=sim_out.Detection.signals.values(w);
                end
            end
            if MaxD~=0
                Det=1;
            end
            
            chromosome(i,V+1)=Det;
            % TotSim=max(SimStopTime.time);
            AA=sim_out.SimStopTime.time;
            b=numel(AA);
            TotSim=AA(b);
            [BestDist2,TTCMIN,BestDistPAWA]=calc_obj_funcs(sim_out,ped_orient);
            
            NFIT=NFIT+1;
            % sum0=normalizeVal(BestDist, 80,0);%MindistanceToCar P is in the AWA
            % sum1= normalizeVal(BestDist2, 100,0); %MindistanceToCar P is not in the AWA
            
            sum1= BestDist2; %MindistanceToCar
            
            % Decision variables are used to form the objective function.
            
            chromosome(i,V+2)= sum1;
            
            % sum2= normalizeVal(TTCMIN, 4,0); %MinTTC
            sum2= TTCMIN; %MinTTC
            chromosome(i,V+3) = sum2;
            % sum3= normalizeVal(BestDistPAWA,10,0); %Mindistancebetween P and AWA
            sum3= BestDistPAWA; %Mindistancebetween P and AWA
            % Decision variables are used to form the objective function.
            chromosome(i,V+4) = sum3;
            
        end
        
        % Sort the initialized population
        
        chromosome = non_domination_sort_mod(chromosome, M, V+1);
        
        formatOut = 'yyyymmdd_HHMMss_FFF';
        
        ds=datestr(now,formatOut);
        name1 = strcat('NSGAIIResults_',ds,'.txt');
        name2 = strcat('NSGAIIAfter100Results_',ds,'.txt');
        name3 = strcat('NSGAIIOracle_',ds,'.txt');
        
        fid = fopen(name1, 'w');
        
        fprintf(fid, '\n initial chromosome\n');
        fprintf(fid, '%s  %s  %s  %s  %s  %s  %s  %s  %s  %s  %s\n',['x0P' '       ' 'y0P' '        ' 'Th0P' '       ' 'v0P' '      ' 'v0C' '     ' 'Det' '   ' 'OF1' '    ' 'OF2' '   ' 'OF3'  '     ' 'Rank' '    ' 'CD']);
        fprintf(fid, '\n');
        EC(:,1:M+V+3)=chromosome;
        clear a;
        for i=1:size(EC,1)
            a(:,i)=EC(i,:);
        end
        fprintf(fid, '%.6f  %.6f  %.6f  %.6f  %.6f  %d  %.6f  %.6f  %.6f  %d %.6f \n', a);
        NCSIM=0;
        
        SimTimeUntilNow=toc
        gim=0;
        
        while SimTimeUntilNow < 9000 %150min
            SimTimeUntilNow=toc
            fprintf(fid, 'SimTimeUntilNow %.3f \n', SimTimeUntilNow);
            gim=gim+1;
            fprintf(fid, '\n Total number of times we call the sim until now = %d \n', NCSIM);
            fprintf(fid, '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% \n');
            fprintf(fid, 'Generation Number = %d \n',gim);
            
            %    display(i);
            t1NewSol=rem(now,1);
            timeSimUntilNow=0;
            pool = round(pop/2);
            tour = 2;
            
            parent_chromosome = tournament_selection(chromosome, pool, tour);
            
            mu = 20;
            mum = 20;
            %offspring_chromosome = genetic_operator(parent_chromosome,M, V, mu, mum, min_range, max_range);%%%%
            
            [N,m] = size(parent_chromosome);
            clear m
            p = 1;
            % Flags used to set if crossover and mutation were actually performed.
            % was_crossover = 0;
            % was_mutation = 0;
            for i = 1 : N
                % With 90 % probability perform crossover
                if rand(1) < 0.9
                    % Initialize the children to be null vector.
                    child_1 = [];
                    child_2 = [];
                    % Select the first parent
                    parent_1 = round(N*rand(1));
                    if parent_1 < 1
                        parent_1 = 1;
                    end
                    % Select the second parent
                    parent_2 = round(N*rand(1));
                    if parent_2 < 1
                        parent_2 = 1;
                    end
                    % Make sure both the parents are not the same.
                    while isequal(parent_chromosome(parent_1,:),parent_chromosome(parent_2,:))
                        parent_2 = round(N*rand(1));
                        if parent_2 < 1
                            parent_2 = 1;
                        end
                    end
                    % Get the chromosome information for each randomnly selected
                    % parents
                    parent_1 = parent_chromosome(parent_1,:);
                    parent_2 = parent_chromosome(parent_2,:);
                    % Perform corssover for each decision variable in the chromosome.
                    for j = 1 : V
                        % SBX (Simulated Binary Crossover).
                        % For more information about SBX refer the enclosed pdf file.
                        % Generate a random number
                        u(j) = rand(1);
                        if u(j) <= 0.5
                            bq(j) = (2*u(j))^(1/(mu+1));
                        else
                            bq(j) = (1/(2*(1 - u(j))))^(1/(mu+1));
                        end
                        % Generate the jth element of first child
                        child_1(j) = ...
                            0.5*(((1 + bq(j))*parent_1(j)) + (1 - bq(j))*parent_2(j));
                        % Generate the jth element of second child
                        child_2(j) = ...
                            0.5*(((1 - bq(j))*parent_1(j)) + (1 + bq(j))*parent_2(j));
                        % Make sure that the generated element is within the specified
                        % decision space else set it to the appropriate extrema.
                        if child_1(j) > max_range(j)
                            child_1(j) = max_range(j);
                        elseif child_1(j) < min_range(j)
                            child_1(j) = min_range(j);
                        end
                        if child_2(j) > max_range(j)
                            child_2(j) = max_range(j);
                        elseif child_2(j) < min_range(j)
                            child_2(j) = min_range(j);
                        end
                    end
                    
                else
                    % Initialize the children to be null vector.
                    child_1 = [];
                    child_2 = [];
                    % Select the first parent
                    parent_1 = round(N*rand(1));
                    if parent_1 < 1
                        parent_1 = 1;
                    end
                    % Select the second parent
                    parent_2 = round(N*rand(1));
                    if parent_2 < 1
                        parent_2 = 1;
                    end
                    % Make sure both the parents are not the same.
                    while isequal(parent_chromosome(parent_1,:),parent_chromosome(parent_2,:))
                        parent_2 = round(N*rand(1));
                        if parent_2 < 1
                            parent_2 = 1;
                        end
                    end
                    % Get the chromosome information for each randomnly selected
                    % parents
                    parent_1 = parent_chromosome(parent_1,:);
                    parent_2 = parent_chromosome(parent_2,:);
                    for j = 1 : V
                        child_1(j)=parent_1(j);
                        
                        child_2(j)=parent_2(j);
                    end
                    
                end
                
                if rand(1) < 0.5
                    %do mutation
                    delta=[2 2 10 1 1.4];
                    for j = 1 : V
                        
                        child_1(j) = child_1(j) + Fn_MiLTester_My_Normal_Rnd(0,delta(j));
                        % Make sure that the generated element is within the decision
                        % space.
                        if child_1(j) > max_range(j)
                            child_1(j) = max_range(j);
                        elseif child_1(j) < min_range(j)
                            child_1(j) = min_range(j);
                        end
                        
                        child_2(j) = child_2(j) + Fn_MiLTester_My_Normal_Rnd(0,delta(j));
                        % Make sure that the generated element is within the decision
                        % space.
                        if child_2(j) > max_range(j)
                            child_2(j) = max_range(j);
                        elseif child_2(j) < min_range(j)
                            child_2(j) = min_range(j);
                        end
                    end
                else
                    %copy
                    for j = 1 : V
                        child_1(j)=child_1(j);
                        
                        child_2(j)=child_2(j);
                    end
                end
                % Evaluate the objective function for the offsprings and as before
                % concatenate the offspring chromosome with objective value.
                % child_1(:,V + 1: M + V) = evaluate_objective(child_1, M, V);%%%%%%%%%%%%%
                
                sum1 = 0;
                sum2 = 0;
                sum3 = 0;
                D=1;
                BestDist=60;
                BestDist2=100;
                TTCMIN=4;
                BestDistPAWA=50;
                
                ped_x=child_1(1);
                ped_y=child_1(2);
                ped_orient=child_1(3);
                ped_speed=child_1(4);
                car_speed=child_1(5);
                
                MaxD=0;
                Det=0;
                %***
                %%%% Change position and orientation of Pedestrian
                %%%%%%%%% Generate the experiment %%%%%%%%%
                
                %%%%
                %Run Simulation
                run_single_scenario
                %***
                
                NCSIM=NCSIM+1;
                for w=1:length(sim_out.Detection.signals.values)
                    if sim_out.Detection.signals.values(w)>MaxD
                        MaxD=sim_out.Detection.signals.values(w);
                    end
                end
                if MaxD~=0
                    Det=1;
                end
                
                child_1(6)=Det;
                % TotSim=max(SimStopTime.time);
                AA=sim_out.SimStopTime.time;
                b=numel(AA);
                TotSim=AA(b);
                [BestDist2,TTCMIN,BestDistPAWA] = calc_obj_funcs(sim_out,ped_orient);
                NFIT=NFIT+1;
                
                % sum0=normalizeVal(BestDist, 80,0);%MindistanceToCar P is in the AWA
                % sum1= normalizeVal(BestDist2, 100,0); %MindistanceToCar P is not in the AWA
                sum1= BestDist2; %MindistanceToCar
                % Decision variables are used to form the objective function.
                
                child_1(:,V+2)= sum1;
                
                %sum2= normalizeVal(TTCMIN, 4,0); %MinTTC
                sum2= TTCMIN; %MinTTC
                
                child_1(:,V+3) = sum2;
                % sum3= normalizeVal(BestDistPAWA,10,0); %Mindistancebetween P and AWA
                sum3= BestDistPAWA; %Mindistancebetween P and AWA
                
                % Decision variables are used to form the objective function.
                child_1(:,V+4) = sum3;
                
                % child_2(:,V + 1: M + V) = evaluate_objective(child_2, M, V);%%%%%%%%%%%%
                
                sum1 = 0;
                sum2 = 0;
                sum3 = 0;
                D=1;
                BestDist=60;
                BestDist2=100;
                TTCMIN=4;
                BestDistPAWA=50;
                
                ped_x=child_2(1);
                ped_y=child_2(2);
                ped_orient=child_2(3);
                ped_speed=child_2(4);
                car_speed=child_2(5);
                
                MaxD=0;
                Det=0;
                %***
                %%%% Change position and orientation of Pedestrian
                %%%%%%%%% Generate the experiment %%%%%%%%%
                
                %%%%
                %Run Simulation
                run_single_scenario
                %***
                
                NCSIM=NCSIM+1;
                for w=1:length(sim_out.Detection.signals.values)
                    if sim_out.Detection.signals.values(w)>MaxD
                        MaxD=sim_out.Detection.signals.values(w);
                    end
                end
                if MaxD~=0
                    Det=1;
                end
                child_2(6)=Det;
                % TotSim=max(SimStopTime.time);
                AA=sim_out.SimStopTime.time;
                b=numel(AA);
                TotSim=AA(b);
                [BestDist2,TTCMIN,BestDistPAWA]=calc_obj_funcs(sim_out,ped_orient);
                NFIT=NFIT+1;
                %sum0=normalizeVal(BestDist, 80,0);%MindistanceToCar P is in the AWA
                % sum1= normalizeVal(BestDist2, 100,0); %MindistanceToCar P is not in the AWA
                sum1= BestDist2; %MindistanceToCar
                
                % Decision variables are used to form the objective function.
                
                child_2(:,V+2)= sum1;
                
                %sum2= normalizeVal(TTCMIN, 4,0); %MinTTC
                sum2= TTCMIN; %MinTTC
                
                child_2(:,V+3) = sum2;
                %  sum3= normalizeVal(BestDistPAWA,10,0); %Mindistancebetween P and AWA
                sum3=BestDistPAWA; %Mindistancebetween P and AWA
                
                % Decision variables are used to form the objective function.
                child_2(:,V+4) = sum3;
                
                % Keep proper count and appropriately fill the child variable with all
                % the generated children for the particular generation.
                
                child(p,:) = child_1;
                child(p+1,:) = child_2;
                p = p + 2;
                
            end
            offspring_chromosome = child;
            
            [main_pop,temp] = size(chromosome);
            [offspring_pop,temp] = size(offspring_chromosome);
            % temp is a dummy variable.
            clear temp
            % intermediate_chromosome is a concatenation of current population and
            % the offspring population.
            intermediate_chromosome(1:main_pop,:) = chromosome;
            intermediate_chromosome(main_pop + 1 : main_pop + offspring_pop,1 : M+V+1) = ...
                offspring_chromosome;
            
            intermediate_chromosome = ...
                non_domination_sort_mod(intermediate_chromosome, M, V+1);
            % Perform Selection
            fprintf(fid, 'Intermediate_Chromosome after sorting \n');
            clear InB
            clear InC
            
            InB(:,1:M+V+3)= intermediate_chromosome;
            clear a;
            for i=1:size(InB,1)
                a(:,i)=InB(i,:);
            end
            fprintf(fid, '%.6f  %.6f  %.6f  %.6f  %.6f  %d  %.6f  %.6f  %.6f  %d %.6f \n', a);
            
            SimTimeUntilNow=toc
            fprintf(fid, 'SimTimeUntilNow %.3f \n', SimTimeUntilNow);
            
            chromosome = replace_chromosome(intermediate_chromosome, M, V+1, pop);
            
            fprintf(fid, 'selected chromosome \n');
            InC(:,1:M+V+3)= chromosome;
            clear a;
            for i=1:size(InC,1)
                a(:,i)=InC(i,:);
            end
            fprintf(fid, '%.6f  %.6f  %.6f  %.6f  %.6f  %d  %.6f  %.6f  %.6f  %d %.6f \n', a);
            
            if ~mod(i,100)
                clc
                fprintf('%d generations completed\n',i);
            end
            
        end % end while
        
        % Result
        % Save the result in ASCII text format.
        fprintf(fid, '\n solution \n');
        clear a;
        for i=1:size(chromosome,1)
            a(:,i)=chromosome(i,:);
        end
        fprintf(fid, '%.6f  %.6f  %.6f  %.6f  %.6f  %d  %.6f  %.6f  %.6f  %d %.6f \n', a);
        
        totSimTime=toc
        fprintf(fid, 'totSimTime %.3f \n', totSimTime);
        fprintf(fid, '\n Total number of times we call the sim in about 150mn = %d \n', NCSIM);
        
        %save solution2.txt totSimTime -ASCII
        
        % Visualize
        % The following is used to visualize the result if objective space
        % dimension is visualizable.
        
        finishTime=rem(now,1);
        display(strcat('modelRunningTime=',num2str(round((finishTime-startTime)*(24*60))),'mn'));
        %plot(yPerson.time,yPerson.signals.values,'r');
        fclose(fid);
        
    catch exc
        display(getReport(exc));
        display('Error in model test run!');
    end
    
end