function [SimulationTimeStep]=GetSimulationTimeStep()

    hAcs = getActiveConfigSet(gcs);
   SimulationTimeStepStr=get_param(hAcs, 'FixedStep');
  % SimulationTimeStepStr=get_param(hAcs, 'OutputOption');
    SimulationTimeStep=str2num(SimulationTimeStepStr);
end