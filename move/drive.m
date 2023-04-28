close all;

global encoders; 
global glob_time;
encoders = [];
glob_time = tic;

figure()
points = [
   -0.8400   -0.9300
   -0.7515   -0.8089
   -0.6585   -0.6912
   -0.5628   -0.5757
   -0.4645   -0.4624
   -0.3653   -0.3498
   -0.4180   -0.2094
   -0.2961   -0.1220
   -0.1780   -0.0295
   -0.1304    0.1127
   -0.0948   -0.0330
    0.0482    0.0125
    0.1685   -0.0770
    0.3110   -0.1240
    0.4545   -0.1678
    0.5985   -0.2095
    0.7422   -0.2528
    0.8852   -0.2979
    1.0282   -0.3431
    1.4, -0.3431 + (1.4-1.0282)*-0.35,
    ];
plot(points(:,1), points(:,2));
axis equal;

%[sensors,vels]= neatoSim(-0.8400, -0.9300, deg2rad(90), 1); % create the simulator
[sensors,vels]= neato('192.168.16.82'); % create the simulator

pause(15); % give the simulator a few seconds to load
move_many(points, sensors, vels);