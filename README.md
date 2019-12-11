# adas-pro-sivic
This repository contains source code for search-based software testing of a pedestrian detection system using the virtual prototyping platform Pro-SiVIC. We hope that the example code provided can help future developers and researchers getting started with software testing using Pro-SiVIC. The examples use Data Distribution Service (DDS) for communication between Pro-SiVIC and MATLAB and Simulink, resepctively.

The corresponding research article is currently in preparation (Dec 2019).

The repository contains four main parts:

- sbst_pedestrian_detection_system: An adaptation of the original NSGA-II algorithm for search-based testing in Pro-SiVIC.
- utils: Various scripts that can be used to reproduce our results.
- example_prosivic_matlab: Examples of DDS communication between Pro-SiVIC and MATLAB applications.
- example_prosivic_simulink: An example of DDS communication between Pro-SiVIC and Simulink blocks.

## sbst_pedestrian_detection_system
This is the core component of the repository, demonstrating how NSGA-II can be used to generate critical test scenarios for a pedestrian detection system simulated using Pro-SiVIC. The implementation shows how NSGA-II can be for multi-objective optimization, in this case to generate test scenarios for the given scene that minimize three objective functions:
1. the minimum distance between the pedestrian and the car (`min_dist`)
1. the minimum time to collision (`min_ttc`)
1. the minimum distance between the pedestrian and the "acute warning area" in front of the car (`min_dist_awa`)

Note that all objective functions are considered equally important.

The four subfolders contain the following:

- genetic_algo: A refactored version of the original algorithm NSGA-II tailored developed by the Kanpur Genetic Algorithm Labarotary http://www.iitk.ac.in/kangal/ We hope that the refactored version will be easier to understand for non-experts 

Workaround to start DCPSInforRepo: DCPSInfoRepo -o f:/temp/repo.ior -ORBListenEndpoints iiop://:4242

## utils
Supporting scripts to reproduce our results. Instructions will follow when the paper manuscript has been finished.


## example_prosivic_matlab
The code can be used to get started with DDS communication between Pro-SiVIC and MATLAB. The code is provided as is, but should be fairly straightforward even without documentation beyond code comments.

## example_prosivic_simulink
The code can be used to get started with DDS communication between Pro-SiVIC and Simulink. The code is provided as is, but should be fairly straightforward even without documentation beyond code comments.
