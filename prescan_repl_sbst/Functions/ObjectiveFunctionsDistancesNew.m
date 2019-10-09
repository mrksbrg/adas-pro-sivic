function [BestDist2,TTCMIN,BestDistPAWA]=ObjectiveFunctionsDistancesNew(TotSim,SimulationTimeStep, xCar,yCar,vCar0,xPerson,yPerson,vPerson,ThP,TTCcol)


   [BestDist2,BestDistPAWA]= CalculationDistancesNew(TotSim,SimulationTimeStep,xCar,yCar,vCar0,xPerson,yPerson, vPerson,ThP);
	   TTCMIN=min(TTCcol.signals.values);