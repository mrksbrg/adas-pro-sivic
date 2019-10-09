To enable DDS (at least for TCP and shared memory), manually starting the background service is needed:

In F:\Pro-SiVIC\2018.0.1\bin, run the command: DCPSInfoRepo -o /repo.ior -ORBListenEndpoints iiop://:4242

To configure Pro-SiVIC for improved performance, apply the following changes to engine.conf:
[slow down]             false
[no render]             true