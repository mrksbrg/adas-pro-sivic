

function [BestDist2,BestDistPAWA]= CalculationDistancesNew(SimulationTime,SimulationTimeStep,xCar,yCar,vCar,xPerson,yPerson, vPerson,ThP)

%SimulationTimeStep=GetSimulationTimeStep();
SimulationSteps=SimulationTime/SimulationTimeStep;
%     IndXC=0;
%     IndVC=0;
%     IndYC=0;
%     IndT=0;
%     IndXP= 0;
%     IndY0P=0;
%     IndVP=0;
d=10;
L_AWA=50;

D=1;
D2=1;
D3=1;
BestIndXC=0;
BestIndVC=0;
BestIndYC=0;
% BestIndT=0;
BestIndXP= 0;
BestIndY0P=0;
BestIndVP=0;

BestDist=60;
BestDist2=100;
BestDistPAWA=50;
BESTBESTDistPAWA=50;


%Dist=0;

for i=3:(SimulationSteps+1),
    
    %C=xPerson.time(i,1);
    %LAWA=vCar.signals.values(i,1)*3.6 *(0.9 + vCar.signals.values(i,1)* 3.6 *0.015)-d;
    %display(LAWA);
    %C1=(xPerson.signals.values(i,1) - d - xCar.signals.values(i,1))/vCar.signals.values(i,1);
    %C2=(yCar.signals.values(i,1) + 0.5 * W_AWA - yPerson.signals.values(i,1))/vPerson.signals.values(i,1);
    %C3=(xPerson.signals.values(i,1) - d - L - xCar.signals.values(i,1))/vCar.signals.values(i,1);
    %C4=(yCar.signals.values(i,1) - 0.5 * W_AWA - yPerson.signals.values(i,1))/vPerson.signals.values(i,1);
    %D=distanceFunction(C, C1, C2, C3, C4);
    
    if (vCar.signals.values(i,1)*3.6 < 60*3.6),
        w = 2.2;
    elseif (vCar.signals.values(i,1)*3.6  <= 80*3.6),
        w = 2.2 + 0.0075 * (vCar.signals.values(i,1)*3.6  - 60*3.6) * (vCar.signals.values(i,1)*3.6  - 60*3.6);
    else
        w = 3.4;
    end
    
    if ((xPerson.signals.values(i,1) >= xCar.signals.values(i,1) + d) &&  (xPerson.signals.values(i,1) <= (xCar.signals.values(i,1)  + d +L_AWA)) && ( yPerson.signals.values(i,1) > yCar.signals.values(i,1) - 0.5 *w)  && (yPerson.signals.values(i,1) < yCar.signals.values(i,1) + 0.5 *w) )
        
        IndXC=xCar.signals.values(i,1);
        IndYC=yCar.signals.values(i,1);
        IndVC=vCar.signals.values(i,1);
        %IndT=xPerson.time(i,1);
        IndXP= xPerson.signals.values(i,1);
        IndY0P=yPerson.signals.values(i,1);
        IndVP=vPerson.signals.values(i,1);
        D=0;
        Dist=sqrt ((IndXP-IndXC).^2 + (IndY0P-IndYC).^2);
        
        if Dist < BestDist
            BestDist=Dist;
            
            BestIndXC=IndXC;
            BestIndYC=IndYC;
            BestIndVC=IndVC;
            BestIndXP= IndXP;
            BestIndY0P=IndY0P;
            BestIndVP=IndVP;
        end
        
        BestDistPAWA=0; %distance between P and AWA
        
        Dist2=sqrt ((xPerson.signals.values(i,1)-xCar.signals.values(i,1)).^2 + (yPerson.signals.values(i,1)-yCar.signals.values(i,1)).^2);
        
        
        if Dist2 < BestDist2
            BestDist2=Dist2;
            BestIndXC=xCar.signals.values(i,1);
            BestIndYC=yCar.signals.values(i,1);
            BestIndVC=vCar.signals.values(i,1);
            %BestIndT=xPerson.time(i,1);
            BestIndXP= xPerson.signals.values(i,1);
            BestIndY0P=yPerson.signals.values(i,1);
            BestIndVP=vPerson.signals.values(i,1);
        end
        
        
        
    else if ((xPerson.signals.values(i,1) >= xCar.signals.values(i,1) + d) &&  (xPerson.signals.values(i,1) <= (xCar.signals.values(i,1)  + d +L_AWA)) && (yPerson.signals.values(i,1) <= yCar.signals.values(i,1) - 0.5 * w))
            D2=0;
            Dist2=sqrt ((xPerson.signals.values(i,1)-xCar.signals.values(i,1)).^2 + (yPerson.signals.values(i,1)-yCar.signals.values(i,1)).^2);
            
            
            if Dist2 < BestDist2
                BestDist2=Dist2;
                BestIndXC=xCar.signals.values(i,1);
                BestIndYC=yCar.signals.values(i,1);
                BestIndVC=vCar.signals.values(i,1);
                %BestIndT=xPerson.time(i,1);
                BestIndXP= xPerson.signals.values(i,1);
                BestIndY0P=yPerson.signals.values(i,1);
                BestIndVP=vPerson.signals.values(i,1);
            end
            DistPAWA=abs((abs(yCar.signals.values(i,1)-yPerson.signals.values(i,1))- 0.5 * w)./sin(ThP*0.0174533)); %distance between P and AWA
            
            
            if DistPAWA < BestDistPAWA
                BestDistPAWA=DistPAWA;
                
                BestIndXC=xCar.signals.values(i,1);
                BestIndYC=yCar.signals.values(i,1);
                BestIndVC=vCar.signals.values(i,1);
                %BestIndT=xPerson.time(i,1);
                BestIndXP= xPerson.signals.values(i,1);
                BestIndY0P=yPerson.signals.values(i,1);
                BestIndVP=vPerson.signals.values(i,1);
            end
        else if ((xPerson.signals.values(i,1) >= xCar.signals.values(i,1)) &&  (xPerson.signals.values(i,1) <= (xCar.signals.values(i,1)  + d )))
                
                
                D3=0;
                Dist2=sqrt ((xPerson.signals.values(i,1)-xCar.signals.values(i,1)).^2 + (yPerson.signals.values(i,1)-yCar.signals.values(i,1)).^2);
                
                
                if Dist2 < BestDist2
                    BestDist2=Dist2;
                    BestIndXC=xCar.signals.values(i,1);
                    BestIndYC=yCar.signals.values(i,1);
                    BestIndVC=vCar.signals.values(i,1);
                    %BestIndT=xPerson.time(i,1);
                    BestIndXP= xPerson.signals.values(i,1);
                    BestIndY0P=yPerson.signals.values(i,1);
                    BestIndVP=vPerson.signals.values(i,1);
                end
                
                if (ThP*0.0174533) < 90
                DistPAWA=abs(((xCar.signals.values(i,1))- xPerson.signals.values(i,1) + d)./cos(ThP*0.0174533)); %distance between P and AWA
                else
                    DistPAWA=sqrt ((xCar.signals.values(i,1) +d - xPerson.signals.values(i,1)).^2 + (yCar.signals.values(i,1) - 0.5 * w - yPerson.signals.values(i,1)).^2);
                end
                
                if DistPAWA < BestDistPAWA
                    BestDistPAWA=DistPAWA;
                    
                    BestIndXC=xCar.signals.values(i,1);
                    BestIndYC=yCar.signals.values(i,1);
                    BestIndVC=vCar.signals.values(i,1);
                    %BestIndT=xPerson.time(i,1);
                    BestIndXP= xPerson.signals.values(i,1);
                    BestIndY0P=yPerson.signals.values(i,1);
                    BestIndVP=vPerson.signals.values(i,1);
                end
            else if (xPerson.signals.values(i,1) >= (xCar.signals.values(i,1)  + d +L_AWA)),
                    
                    Dist2=sqrt ((xPerson.signals.values(i,1)-xCar.signals.values(i,1)).^2 + (yPerson.signals.values(i,1)-yCar.signals.values(i,1)).^2);
                    
                    
                    if Dist2 < BestDist2
                        BestDist2=Dist2;
                        BestIndXC=xCar.signals.values(i,1);
                        BestIndYC=yCar.signals.values(i,1);
                        BestIndVC=vCar.signals.values(i,1);
                        %BestIndT=xPerson.time(i,1);
                        BestIndXP= xPerson.signals.values(i,1);
                        BestIndY0P=yPerson.signals.values(i,1);
                        BestIndVP=vPerson.signals.values(i,1);
                    end
                    
                    if (ThP*0.0174533) > 90
                    DistPAWA=abs(  (xPerson.signals.values(i,1)- (xCar.signals.values(i,1) + d +L_AWA))./((-1).* cos(ThP*0.0174533))); %distance between P and AWA
                    else
                        DistPAWA=sqrt ((xPerson.signals.values(i,1)- (xCar.signals.values(i,1) + d +L_AWA)).^2 + (yPerson.signals.values(i,1)-yCar.signals.values(i,1) - 0.5 *w).^2);
                    end
                    
                    if DistPAWA < BestDistPAWA
                        BestDistPAWA=DistPAWA;
                        
                        BestIndXC=xCar.signals.values(i,1);
                        BestIndYC=yCar.signals.values(i,1);
                        BestIndVC=vCar.signals.values(i,1);
                        %BestIndT=xPerson.time(i,1);
                        BestIndXP= xPerson.signals.values(i,1);
                        BestIndY0P=yPerson.signals.values(i,1);
                        BestIndVP=vPerson.signals.values(i,1);
                    end
                end
            end
        end
    end
    
    %     if BestDistPAWA < BESTBESTDistPAWA
    %         BESTBESTDistPAWA=BestDistPAWA;
    %     end
    
    
end
%display(BestDistPAWA);
end
%(BestDist);