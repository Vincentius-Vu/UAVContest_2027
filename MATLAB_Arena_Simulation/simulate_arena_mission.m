%% SIMULATE_ARENA_MISSION
% Animate and verify the UAV Contest 2027 Arena flight missions.
% Checks multi-UAV safety distance (>= 1.5m) and real-time trajectory.
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc; close all;
fprintf("=== Launching UAV Contest 2027 Arena Mission Simulation ===\n");

% 1. Load Arena Scenario
scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = pwd;
end
matPath = fullfile(scriptDir, "uav_contest_2027_arena.mat");
if ~isfile(matPath)
    fprintf("Scenario MAT-file not found. Running build_uav_contest_arena.m first...\n");
    run(fullfile(scriptDir, "build_uav_contest_arena.m"));
else
    load(matPath, "arenaScenario");
end

% 2. Setup 3D Visualization Window (if running interactively)
isInteractive = usejava('desktop');
if isInteractive
    fig = figure("Name", "UAV Contest 2027 - Arena Simulation (TDTU)", ...
        "NumberTitle", "off", "Position", [100, 100, 1200, 750], "Color", [0.05 0.08 0.15]);
    ax = show3D(arenaScenario, "Parent", gca);
    title(ax, "UAV CONTEST 2027 — Arena 12m x 24m Multi-Agent Simulation", ...
        "Color", [0.2 0.9 1.0], "FontSize", 14, "FontWeight", "bold");
    xlabel(ax, "Length X (m) [Depot: -12 to -8.5 | Pickup: 7.5 to 12]", "Color", [0.8 0.8 0.8]);
    ylabel(ax, "Width Y (m) [-6 to +6]", "Color", [0.8 0.8 0.8]);
    zlabel(ax, "Altitude Z (m) [Ceiling: 5.0m]", "Color", [0.8 0.8 0.8]);
    view(ax, [-35, 30]);
    grid(ax, "on");
    set(ax, "Color", [0.08 0.12 0.22], "XColor", [0.5 0.6 0.7], "YColor", [0.5 0.6 0.7], "ZColor", [0.5 0.6 0.7]);
    axis(ax, [-14 14 -8 8 0 6]);
    
    % Apply Transparent Safety Wall Netting (FaceAlpha = 0.05)
    applyWallTransparency(ax, 0.05);
else
    fprintf(">> Running in Headless / Batch Mode (High-speed trajectory verification).\n");
end

% 3. Setup and Run Simulation
setup(arenaScenario);

fprintf(">> Simulation starting at %d Hz update rate (StopTime: %.1fs)...\n", arenaScenario.UpdateRate, arenaScenario.StopTime);
fprintf("   - UAV_A: Passes ACC1-ACC4, picks up cargo at P2, relays to D3.\n");
fprintf("   - UAV_B: Autonomous multi-agent takeoff upon CABP signal, grabs relay at D3.\n");
fprintf("   - MobileReceiver: Linear motion target D2 at 10 cm/s.\n");

minDistance = Inf;
safetyThreshold = 1.5; % Minimum separation rule: >= 1.5m

platA = arenaScenario.Platforms(2); % UAV_A
platB = arenaScenario.Platforms(3); % UAV_B

stepCount = 0;
totalSteps = arenaScenario.StopTime * arenaScenario.UpdateRate;

while arenaScenario.IsRunning
    advance(arenaScenario);
    updateSensors(arenaScenario);
    stepCount = stepCount + 1;
    
    % Check separation distance between UAV_A and UAV_B
    motionA = read(platA);
    motionB = read(platB);
    posA = motionA(1:3);
    posB = motionB(1:3);
    distAB = norm(posA - posB);
    if distAB < minDistance
        minDistance = distAB;
    end
    
    % Update 3D visualization periodically if interactive
    if isInteractive
        if mod(stepCount, 5) == 0
            show3D(arenaScenario, "Parent", ax, "FastUpdate", true);
            drawnow limitrate;
        end
    else
        if mod(stepCount, round(totalSteps / 4)) == 0
            fprintf("   Progress: %3.0f%% (Sim Time: %.1fs | Dist A-B: %.2fm)\n", ...
                (stepCount / totalSteps) * 100, arenaScenario.CurrentTime, distAB);
        end
    end
end

fprintf("\n=== Simulation Completed Successfully! ===\n");
fprintf(">> Total Simulation Time: %.1f seconds.\n", arenaScenario.CurrentTime);
fprintf(">> Minimum Separation Distance between UAV-A & UAV-B: %.2f m\n", minDistance);
if minDistance >= safetyThreshold
    fprintf(">> SAFETY AUDIT PASSED: Multi-UAV separation remained >= %.1f m (No penalty).\n", safetyThreshold);
else
    fprintf(">> SAFETY WARNING: UAVs came within %.2f m (< %.1f m rule)!\n", minDistance, safetyThreshold);
end

%% Helper Function: Apply Transparent Wall Netting
function applyWallTransparency(ax, alphaVal)
    if nargin < 2, alphaVal = 0.05; end
    patches = findobj(ax, "Type", "patch");
    count = 0;
    for i = 1:numel(patches)
        p = patches(i);
        if any(p.Vertices(:, 3) >= 4.9) && (range(p.Vertices(:, 1)) > 10 || range(p.Vertices(:, 2)) > 10)
            count = count + 1;
            if alphaVal == 0
                set(p, "FaceColor", "none", "EdgeColor", [0.08 0.65 0.85], "EdgeAlpha", 0.3);
            else
                set(p, "FaceAlpha", alphaVal, "EdgeColor", [0.08 0.65 0.85], "EdgeAlpha", 0.35);
            end
        end
    end
    if count > 0
        fprintf(">> Applied transparent netting to %d perimeter wall panels (FaceAlpha = %.2f).\n", count, alphaVal);
    end
end
