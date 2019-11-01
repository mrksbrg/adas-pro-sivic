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

function [min_dist, min_ttc, min_dist_awa] = calc_obj_funcs(sim_output, ped_orient)

nbr_sim_steps = length(sim_output.xCar.time);

car_x_array = sim_output.xCar;
car_y_array = sim_output.yCar;
car_speed_array = sim_output.vCar;
ped_x_array = sim_output.xPerson;
ped_y_array = sim_output.yPerson;
%ped_speed_array = sim_output.vPerson; % not used for the moment

awa_offset = 10; % the distance between the car and the acute warning area
length_awa = 50; % this is the length of the acute warning area

min_dist = 100;
min_ttc = min(sim_output.TTCcol.signals.values); % simply find in array
min_dist_awa = 50;

for i = 1:nbr_sim_steps
    
    % extract the positions for time step i
    car_x_value = car_x_array.signals.values(i, 1);
    car_y_value = car_y_array.signals.values(i, 1);
    car_speed_value = car_speed_array.signals.values(i, 1);
    ped_x_value = ped_x_array.signals.values(i, 1);
    ped_y_value = ped_y_array.signals.values(i, 1);
    
    % disregard the the heading 0s in the arrays (position not yet ready)
    if (ped_x_value ~= 0 && ped_y_value ~= 0 && car_x_value ~= 0 && car_y_value ~= 0)
        
        % Set a constant used to calculate the size of the acute warning
        % area in front of the car. The constant depends on the speed.
        if (car_speed_value * 3.6 < 60 * 3.6)
            dist_weight = 2.2;
        elseif (car_speed_value * 3.6  <= 80 * 3.6)
            dist_weight = 2.2 + 0.0075 * (car_speed_value * 3.6  - 60 * 3.6) *...
                (car_speed_value * 3.6  - 60 * 3.6);
        else
            dist_weight = 3.4;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% Pedestrian in position 1 %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ((ped_x_value <= car_x_value - awa_offset) &&...
                (ped_x_value >= (car_x_value - awa_offset - length_awa)) &&...
                (ped_y_value < car_y_value + 0.5 * dist_weight) &&...
                (ped_y_value > car_y_value - 0.5 * dist_weight))
            
            dist = sqrt((ped_x_value - car_x_value).^2 + (ped_y_value - car_y_value).^2);
            
            % if a minimum distance has been found, save it
            if dist < min_dist
                min_dist = dist;
            end
            
            min_dist_awa = 0; % the pedestrian is in the acute warning area
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Pedestrian in position 2 %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif ((ped_x_value <= car_x_value - awa_offset) &&...
                (ped_x_value >= (car_x_value - awa_offset -length_awa)) &&...
                (ped_y_value >= car_y_value + 0.5 * dist_weight))
            
            dist = sqrt((ped_x_value - car_x_value).^2 + (ped_y_value - car_y_value).^2);
            
            % if a minimum distance has been found, save it
            if dist < min_dist
                min_dist = dist;
            end
            
            dist_awa = abs((abs(car_y_value - ped_y_value) + 0.5 *...
                dist_weight)./sin(ped_orient * 0.0174533)); %distance between P and AWA
            
            if dist_awa < min_dist_awa
                min_dist_awa = dist_awa;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Pedestrian in position 3 %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif ((ped_x_value <= car_x_value) && (ped_x_value >= (car_x_value - awa_offset)))
            
            dist = sqrt((ped_x_value - car_x_value).^2 + (ped_y_value - car_y_value).^2);
            
            % if a minimum distance has been found, save it
            if dist < min_dist
                min_dist = dist;
            end
            
            if (ped_orient * 0.0174533) < 90
                dist_awa = abs(((car_x_value) -...
                    ped_x_value - awa_offset)./cos(ped_orient * 0.0174533));
            else
                dist_awa=sqrt((car_x_value - awa_offset - ped_x_value).^2 +...
                    (car_y_value + 0.5 * dist_weight - ped_y_value).^2);
            end
            
            if dist_awa < min_dist_awa
                min_dist_awa = dist_awa;            
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Pedestrian in position 4 %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif (ped_x_value <= (car_x_value - awa_offset - length_awa))
            
            dist = sqrt((ped_x_value - car_x_value).^2 + (ped_y_value - car_y_value).^2);
            
            % if a minimum distance has been found, save it
            if dist < min_dist
                min_dist = dist;
            end
            
            if (ped_orient * 0.0174533) > 90
                dist_awa = abs((ped_x_value -...
                    (car_x_value - awa_offset - length_awa))./((-1).*...
                    cos(ped_orient * 0.0174533)));
            else
                dist_awa = sqrt((ped_x_value -...
                    (car_x_value - awa_offset - length_awa)).^2 +...
                    (ped_y_value - car_y_value + 0.5 * dist_weight).^2);
            end
            
            if dist_awa < min_dist_awa
                min_dist_awa = dist_awa;              
            end
        end
    end
end