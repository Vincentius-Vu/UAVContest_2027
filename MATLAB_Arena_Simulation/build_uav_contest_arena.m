%% BUILD_UAV_CONTEST_ARENA
% Build and simulate the official UAV Contest 2027 Arena (12m x 24m)
% Compatible with MATLAB UAV Toolbox and UAV Scenario Designer App.
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc;
fprintf("=== Building UAV Contest 2027 Arena Scenario ===\n");

%% 1. Initialize UAV Scenario (ENU Coordinate System)
% UpdateRate = 20 Hz, StopTime = 60 seconds
arenaScenario = uavScenario("UpdateRate", 20, "StopTime", 60);

%% 2. Arena Dimensions & Coordinates
% Length (X): 24.0 m (-12.0 to +12.0 m)
% Width  (Y): 12.0 m (-6.0 to +6.0 m)
% Height (Z): Ceiling net at 5.0 m
xMin = -12.0; xMax = 12.0;
yMin = -6.0;  yMax = 6.0;

% Colors (RGB in [0, 1])
cFloor       = [0.12, 0.15, 0.20];  % Deep slate floor
cDepot       = [0.20, 0.35, 0.55];  % Blue Depot Zone
cPickup      = [0.45, 0.25, 0.35];  % Purple/Burgundy Pickup Zone
cRelay       = [0.15, 0.30, 0.25];  % Emerald Relay Zone
cGateACC     = [0.05, 0.85, 0.95];  % Cyber Cyan Gate
cPedestal    = [0.60, 0.60, 0.65];  % Metal pedestal
cRedD        = [0.95, 0.15, 0.15];  % D1, D2 (Red)
cYellowD     = [0.98, 0.90, 0.10];  % D3, D4 (Yellow)
cBlueD       = [0.15, 0.25, 0.95];  % D5 (Blue)
cMobileCart  = [0.95, 0.55, 0.10];  % Mobile Receiver cart (Amber)
cUWBAnchor   = [0.10, 0.90, 0.50];  % UWB Anchor pillars (Green)
cWallNet     = [0.08, 0.45, 0.65];  % Cyber translucent safety netting
cNetPost     = [0.35, 0.40, 0.50];  % Metal safety posts

%% 3. Add Arena Floor & Zoned Markings
% Main arena floor (24m x 12m, Z = -0.05 to 0.0)
floorPoly = [xMin yMin; xMax yMin; xMax yMax; xMin yMax];
addMesh(arenaScenario, "polygon", {floorPoly, [-0.05, 0.0]}, cFloor);

% Zone 1: Depot Area (12m x 3.5m) at X = [-12.0, -8.5]
depotPoly = [-12.0 yMin; -8.5 yMin; -8.5 yMax; -12.0 yMax];
addMesh(arenaScenario, "polygon", {depotPoly, [0.001, 0.01]}, cDepot);

% Zone 2: Pickup Area (12m x 4.5m) at X = [7.5, 12.0]
pickupPoly = [7.5 yMin; 12.0 yMin; 12.0 yMax; 7.5 yMax];
addMesh(arenaScenario, "polygon", {pickupPoly, [0.001, 0.01]}, cPickup);

% Zone 3: Relay & Drop Zone (3m x 3m center area) at X = [-1.5, 1.5], Y = [-1.5, 1.5]
relayPoly = [-1.5 -1.5; 1.5 -1.5; 1.5 1.5; -1.5 1.5];
addMesh(arenaScenario, "polygon", {relayPoly, [0.001, 0.01]}, cRelay);

%% 4. Add Safety Perimeter Wall / Netting (Height 5.0m, Transparent / Translucent)
% 4.1 Slender corner & perimeter safety posts (to clearly show arena boundaries)
postCoords = [
    -12.0, -6.0;   -12.0,  0.0;   -12.0,  6.0;
      0.0, -6.0;                    0.0,  6.0;
     12.0, -6.0;    12.0,  0.0;    12.0,  6.0
];
for pIdx = 1:size(postCoords, 1)
    px = postCoords(pIdx, 1);
    py = postCoords(pIdx, 2);
    addMesh(arenaScenario, "cylinder", {[px, py, 0.06], [0, 5.0]}, cNetPost);
end

% 4.2 Top perimeter tension cable at height 5.0m (Z = 4.95 to 5.0)
addMesh(arenaScenario, "polygon", {[-12.05 yMin-0.05; -11.95 yMin-0.05; -11.95 yMax+0.05; -12.05 yMax+0.05], [4.95, 5.0]}, cGateACC);
addMesh(arenaScenario, "polygon", {[11.95 yMin-0.05; 12.05 yMin-0.05; 12.05 yMax+0.05; 11.95 yMax+0.05], [4.95, 5.0]}, cGateACC);
addMesh(arenaScenario, "polygon", {[xMin-0.05 -6.05; xMax+0.05 -6.05; xMax+0.05 -5.95; xMin-0.05 -5.95], [4.95, 5.0]}, cGateACC);
addMesh(arenaScenario, "polygon", {[xMin-0.05 5.95; xMax+0.05 5.95; xMax+0.05 6.05; xMin-0.05 6.05], [4.95, 5.0]}, cGateACC);

% 4.3 4 Transparent Safety Netting Panels (Height 0 to 5.0m)
% West wall (behind Depot)
addMesh(arenaScenario, "polygon", {[-12.02 yMin-0.02; -11.98 yMin-0.02; -11.98 yMax+0.02; -12.02 yMax+0.02], [0, 5.0]}, cWallNet);
% East wall (behind Pickup)
addMesh(arenaScenario, "polygon", {[11.98 yMin-0.02; 12.02 yMin-0.02; 12.02 yMax+0.02; 11.98 yMax+0.02], [0, 5.0]}, cWallNet);
% South wall
addMesh(arenaScenario, "polygon", {[xMin-0.02 -6.02; xMax+0.02 -6.02; xMax+0.02 -5.98; xMin-0.02 -5.98], [0, 5.0]}, cWallNet);
% North wall
addMesh(arenaScenario, "polygon", {[xMin-0.02 5.98; xMax+0.02 5.98; xMax+0.02 6.02; xMin-0.02 6.02], [0, 5.0]}, cWallNet);

%% 5. Add 3 Pickup Pedestals P1, P2, P3 (1.0m x 1.0m x 1.0m)
pPositions = [
    9.5, -3.0;  % P1
    9.5,  0.0;  % P2
    9.5,  3.0   % P3
];
for i = 1:size(pPositions, 1)
    px = pPositions(i, 1);
    py = pPositions(i, 2);
    boxPoly = [px-0.5 py-0.5; px+0.5 py-0.5; px+0.5 py+0.5; px-0.5 py+0.5];
    addMesh(arenaScenario, "polygon", {boxPoly, [0, 1.0]}, cPedestal);
    
    % Cargo mock (0.3m cube on top of pedestal)
    cargoPoly = [px-0.15 py-0.15; px+0.15 py-0.15; px+0.15 py+0.15; px-0.15 py+0.15];
    addMesh(arenaScenario, "polygon", {cargoPoly, [1.0, 1.3]}, [0.9 0.4 0.1]);
end

%% 6. Add Circular Air Corridors (ACC1 to ACC4)
% Inner diameter = 1.6m (radius 0.8m), center height = 1.7m, peak = 2.6m
% ACC1 & ACC2: Forward corridor (Depot -> Pickup) along Y = -2.5
% ACC3 & ACC4: Return corridor (Pickup -> Depot) along Y = +2.5
accCoords = [
    -5.0, -2.5;  % ACC1
     3.0, -2.5;  % ACC2
     3.0,  2.5;  % ACC3
    -5.0,  2.5   % ACC4
];

% Function to generate a vertical circular ring custom mesh
for i = 1:size(accCoords, 1)
    gx = accCoords(i, 1);
    gy = accCoords(i, 2);
    
    % Create vertical arch/gate supporting pillars
    pillarL = [gx-0.1 gy-0.95; gx+0.1 gy-0.95; gx+0.1 gy-0.85; gx-0.1 gy-0.85];
    pillarR = [gx-0.1 gy+0.85; gx+0.1 gy+0.85; gx+0.1 gy+0.95; gx-0.1 gy+0.95];
    addMesh(arenaScenario, "polygon", {pillarL, [0, 2.6]}, [0.4 0.4 0.5]);
    addMesh(arenaScenario, "polygon", {pillarR, [0, 2.6]}, [0.4 0.4 0.5]);
    
    % Top crossbar at height 2.6m
    topBar = [gx-0.1 gy-0.95; gx+0.1 gy-0.95; gx+0.1 gy+0.95; gx-0.1 gy+0.95];
    addMesh(arenaScenario, "polygon", {topBar, [2.5, 2.65]}, cGateACC);
    % Bottom crossbar at height 0.9m
    botBar = [gx-0.1 gy-0.85; gx+0.1 gy-0.85; gx+0.1 gy+0.85; gx-0.1 gy+0.85];
    addMesh(arenaScenario, "polygon", {botBar, [0.85, 0.95]}, cGateACC);
end

%% 7. Add Delivery Target Points (D1 - D5)
% D1 (Red, diam 1.0m, r=0.5m)
addMesh(arenaScenario, "cylinder", {[-2.5, -3.5, 0.5], [0.01, 0.05]}, cRedD);
% D2 (Red, diam 1.0m, r=0.5m) - In Preliminary/Semi: Static; In Final: Mounted on cart
% Let's place D2 on a moving ground cart below!

% D3 (Yellow, diam 0.6m, r=0.3m)
addMesh(arenaScenario, "cylinder", {[0.0, 0.0, 0.3], [0.01, 0.05]}, cYellowD);

% D4 (Yellow, diam 0.6m, r=0.3m)
addMesh(arenaScenario, "cylinder", {[1.5, -2.5, 0.3], [0.01, 0.05]}, cYellowD);

% D5 (Blue, diam 0.4m, r=0.2m) - Smallest high-point target
addMesh(arenaScenario, "cylinder", {[2.5, 3.5, 0.2], [0.01, 0.05]}, cBlueD);

%% 8. Add Mobile Receiver Platform for Final Round (D2 on cart, 10 cm/s)
% Moves along linear track at Y = 1.5 between X = -3.0 and X = 3.0 (6 meters)
% Speed = 0.10 m/s -> 6m takes 60 seconds
cartWaypoints = [
    -3.0, 1.5, 0.1;
     3.0, 1.5, 0.1;
    -3.0, 1.5, 0.1
];
cartTimes = [0; 60; 120];
cartTraj = waypointTrajectory(cartWaypoints, TimeOfArrival=cartTimes);
mobileCart = uavPlatform("MobileReceiver", arenaScenario, Trajectory=cartTraj);
% Cuboid mesh for cart (1.2m x 1.2m x 0.2m)
updateMesh(mobileCart, "cuboid", {[1.2, 1.2, 0.2]}, cMobileCart, [0 0 0], [1 0 0 0]);

%% 9. Add UWB External Perimeter Anchors (4 corners)
anchorPositions = [
    -12.5, -6.5;
     12.5, -6.5;
     12.5,  6.5;
    -12.5,  6.5
];
for i = 1:size(anchorPositions, 1)
    ax = anchorPositions(i, 1);
    ay = anchorPositions(i, 2);
    addMesh(arenaScenario, "cylinder", {[ax, ay, 0.15], [0, 3.5]}, cUWBAnchor);
end

%% 10. Add UAV-A (Multirotor Platform) with Mission Flight Trajectory
% Depot -> Takeoff -> ACC1 -> ACC2 -> Pickup P2 -> ACC3 -> ACC4 -> Relay D3 -> Land Depot
uavAWaypoints = [
    -10.0, -2.5,  0.2;   % 1. Depot Takeoff Pad
    -10.0, -2.5,  1.7;   % 2. Ascend to gate centerline height (1.7m)
     -5.0, -2.5,  1.7;   % 3. Pass through ACC1
      3.0, -2.5,  1.7;   % 4. Pass through ACC2
      9.0,  0.0,  1.7;   % 5. Approach Pickup P2
      9.5,  0.0,  1.35;  % 6. Cargo Gripping at P2 (hold)
      9.0,  2.5,  1.7;   % 7. Ascend and align with return corridor
      3.0,  2.5,  1.7;   % 8. Pass through ACC3
     -1.0,  2.5,  1.7;   % 9. Approach Relay Zone
      0.0,  0.0,  0.3;   % 10. Place Cargo at D3 (Relay Zone)
     -5.0,  2.5,  1.7;   % 11. Pass through ACC4
    -10.0, -2.5,  1.5;   % 12. Return to Depot
    -10.0, -2.5,  0.2    % 13. Touchdown at Depot
];
uavATimes = [0; 3; 8; 16; 22; 26; 31; 37; 42; 47; 52; 57; 60];
uavATraj = waypointTrajectory(uavAWaypoints, TimeOfArrival=uavATimes, AutoBank=true);
uavA = uavPlatform("UAV_A", arenaScenario, Trajectory=uavATraj);
updateMesh(uavA, "quadrotor", {1.0}, [0.06 0.71 0.83], [0 0 0], eul2quat([0 0 0]));

%% 11. Add UAV-B (Multirotor Platform) for Coordinated Ops
% Starts at Depot, receives CABP event at t=48s, flies directly to D3 to pick up cargo
uavBWaypoints = [
    -10.0,  2.5, 0.2;   % 1. Standby at Depot Pad B (t=0 to t=48)
    -10.0,  2.5, 0.2;   % 2. Awaiting CABP Mission Event (t=48)
    -10.0,  2.5, 3.2;   % 3. Auto Takeoff to >= 3.0m altitude
      0.0,  0.0, 3.2;   % 4. Cruise to Relay D3
      0.0,  0.0, 0.4;   % 5. Descend to grab relayed cargo
      0.0,  0.0, 3.2;   % 6. Ascend with cargo
    -10.0,  2.5, 3.2;   % 7. Return to Depot
    -10.0,  2.5, 0.2    % 8. Safe Touchdown
];
uavBTimes = [0; 48; 50; 53; 55; 57; 59; 60];
uavBTraj = waypointTrajectory(uavBWaypoints, TimeOfArrival=uavBTimes, AutoBank=true);
uavB = uavPlatform("UAV_B", arenaScenario, Trajectory=uavBTraj);
updateMesh(uavB, "quadrotor", {1.0}, [0.96 0.62 0.07], [0 0 0], eul2quat([0 0 0]));

%% 12. Mount Sensors on UAV-B (LiDAR & INS)
try
    % 3D Obstacle Avoidance LiDAR (360 azimuth, range up to 12m)
    lidarModel = uavLidarPointCloudGenerator("UpdateRate", 10, "MaxRange", 12);
    lidar = uavSensor("Lidar", uavB, lidarModel, "MountingLocation", [0 0 0.1]);
    
    % Inertial Navigation Sensor (IMU/INS)
    insModel = insSensor();
    ins = uavSensor("INS", uavB, insModel);
    fprintf(">> Sensors (LiDAR + INS) successfully mounted on UAV_B.\n");
catch ME
    fprintf(">> Warning mounting sensors: %s\n", ME.message);
end

%% 13. Save Scenario for UAV Scenario Designer App
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = pwd;
end
savePath = fullfile(scriptDir, "uav_contest_2027_arena.mat");
save(savePath, "arenaScenario");
fprintf(">> Arena Scenario successfully saved to:\n   %s\n", savePath);
fprintf(">> To view and animate in MATLAB, run:\n   show3D(arenaScenario);\n");
fprintf(">> To edit in UAV Scenario Designer App, run:\n   uavScenarioDesigner\n");
