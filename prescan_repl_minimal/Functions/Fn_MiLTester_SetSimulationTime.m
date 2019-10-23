function []=Fn_MiLTester_SetSimulationTime(SimulationRunningTime)

    hAcs = getActiveConfigSet(gcs);
    set_param(hAcs, 'StopTime', num2str(SimulationRunningTime));
end