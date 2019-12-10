# adas-pro-sivic
This repository contains code for search-based software testing of a pedestrian detection system using the virtual prototyping platform Pro-SiVIC. We hope that the example code provided can help future developers and researchers getting started with software testing using Pro-SiVIC. The examples use Data Distribution Service (DDS) for communication between Pro-SiVIC and MATLAB and Simulink, resepctively.

The corresponding research article is currently in preparation (Dec 2019).

The repository contains four main parts:

- example_prosivic_matlab: Examples of DDS communication between Pro-SiVIC and MATLAB applications.
- example_prosivic_simulink: Examples of DDS communication between Pro-SiVIC and Simulink blocks.
- sbst_pedestrian_detection_system: An adaptation of the original NSGA-II algorithm for search-based testing in Pro-SiVIC.
- utils: Various scripts that can be used to reproduce our results.

## example_prosivic_matlab
The code can be used to get started with DDS communication between Pro-SiVIC and MATLAB. The code is provided as is, but should be fairly straightforward even without documentation beyond code comments.

## example_prosivic_simulink
The code can be used to get started with DDS communication between Pro-SiVIC and Simulink. The code is provided as is, but should be fairly straightforward even without documentation beyond code comments.

## sbst_pedestrian_detection_system
The core of the repository.
Workaround to start DCPSInforRepo: DCPSInfoRepo -o f:/temp/repo.ior -ORBListenEndpoints iiop://:4242

## utils
Supporting scripts to reproduce our results. Instructions will follow when the paper manuscript has been finished.

