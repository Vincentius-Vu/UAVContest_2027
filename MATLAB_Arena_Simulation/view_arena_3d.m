%% VIEW_ARENA_3D
% Interactive 3D Viewer for UAV Contest 2027 Arena with Transparent Walls.
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc;
fprintf("=== Opening 3D Interactive Arena Viewer (Transparent Netting) ===\n");

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir)
    scriptDir = pwd;
end
matPath = fullfile(scriptDir, "uav_contest_2027_arena.mat");
if ~isfile(matPath)
    run(fullfile(scriptDir, "build_uav_contest_arena.m"));
else
    load(matPath, "arenaScenario");
end

fig = figure("Name", "UAV Contest 2027 - Arena 3D View (Transparent Walls)", ...
    "NumberTitle", "off", "Position", [120, 100, 1200, 750], "Color", [0.05 0.08 0.15]);

ax = show3D(arenaScenario, "Parent", gca);
title(ax, "UAV CONTEST 2027 — Arena 12m x 24m (Transparent Safety Netting)", ...
    "Color", [0.2 0.9 1.0], "FontSize", 14, "FontWeight", "bold");
xlabel(ax, "Length X (m) [Depot: -12 to -8.5 | Pickup: 7.5 to 12]", "Color", [0.8 0.8 0.8]);
ylabel(ax, "Width Y (m) [-6 to +6]", "Color", [0.8 0.8 0.8]);
zlabel(ax, "Altitude Z (m) [Ceiling: 5.0m]", "Color", [0.8 0.8 0.8]);
view(ax, [-35, 28]);
grid(ax, "on");
set(ax, "Color", [0.08 0.12 0.22], "XColor", [0.5 0.6 0.7], "YColor", [0.5 0.6 0.7], "ZColor", [0.5 0.6 0.7]);
axis(ax, [-14 14 -8 8 0 6]);

% Apply Transparent Safety Netting (alpha = 0.05)
patches = findobj(ax, "Type", "patch");
wallCount = 0;
for i = 1:numel(patches)
    p = patches(i);
    if any(p.Vertices(:, 3) >= 4.9) && (range(p.Vertices(:, 1)) > 10 || range(p.Vertices(:, 2)) > 10)
        wallCount = wallCount + 1;
        set(p, "FaceAlpha", 0.05, "EdgeColor", [0.08 0.65 0.85], "EdgeAlpha", 0.35);
    end
end
fprintf(">> Done! Set transparency (FaceAlpha = 0.05) on %d perimeter wall panels.\n", wallCount);
fprintf(">> Arena is now 100%% unobstructed from all camera angles.\n");
