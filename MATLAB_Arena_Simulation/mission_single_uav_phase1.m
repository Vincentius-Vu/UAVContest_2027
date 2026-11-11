%% MISSION_SINGLE_UAV_PHASE1
% Track Chuẩn - Pha 1: Lấy hàng lớn qua 4 Cổng Hành lang ACC1-ACC4
% Thời lượng nhiệm vụ thực tế: 180 giây (3.0 phút) - Đúng thực tế phi công bay tay trong nhà.
% Kịch bản chi tiết: 
%   Cất cánh Depot -> Căn chỉnh chui ACC1, ACC2 -> Tiếp cận bệ P2 -> 
%   Hạ ngàm khóa kiện hàng 300g (dwell 25s) -> Vận chuyển qua ACC3, ACC4 -> 
%   Đặt hàng Depot -> Hạ cánh chính xác trên bệ đáp (Tổng 180s).
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc; close all;
fprintf("=======================================================================\n");
fprintf("   UAV CONTEST 2027 - TRACK CHUẨN: PHA 1 (PICK-UP MISSION)             \n");
fprintf("   Thời lượng thực tế: 180 giây (3.0 phút) | Tốc độ bay: 0.5 - 1.0 m/s \n");
fprintf("=======================================================================\n");

%% 1. Khởi tạo Kịch bản Pha 1 (180 giây)
simRate = 10;          % 10 Hz tần số cập nhật
stopTime = 180;        % 180 giây (3 phút thực tế)
phase1Scenario = uavScenario("UpdateRate", simRate, "StopTime", stopTime);

cFloor       = [0.12, 0.15, 0.20];
cDepot       = [0.20, 0.35, 0.55];
cPickup      = [0.45, 0.25, 0.35];
cGateACC     = [0.05, 0.85, 0.95];
cPedestal    = [0.60, 0.60, 0.65];
cWallNet     = [0.08, 0.45, 0.65];
cNetPost     = [0.35, 0.40, 0.50];

% Sàn đấu 24m x 12m
addMesh(phase1Scenario, "polygon", {[-12 -6; 12 -6; 12 6; -12 6], [-0.05, 0.0]}, cFloor);
addMesh(phase1Scenario, "polygon", {[-12 -6; -8.5 -6; -8.5 6; -12 6], [0.001, 0.01]}, cDepot);
addMesh(phase1Scenario, "polygon", {[7.5 -6; 12 -6; 12 6; 7.5 6], [0.001, 0.01]}, cPickup);

% Cột và vách lưới trong suốt
postCoords = [-12 -6; -12 6; 12 -6; 12 6; -12 0; 12 0; 0 -6; 0 6];
for pIdx = 1:size(postCoords, 1)
    addMesh(phase1Scenario, "cylinder", {[postCoords(pIdx, 1), postCoords(pIdx, 2), 0.06], [0, 5.0]}, cNetPost);
end
addMesh(phase1Scenario, "polygon", {[-12.02 -6.02; -11.98 -6.02; -11.98 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);
addMesh(phase1Scenario, "polygon", {[11.98 -6.02; 12.02 -6.02; 12.02 6.02; 11.98 6.02], [0, 5.0]}, cWallNet);
addMesh(phase1Scenario, "polygon", {[-12.02 -6.02; 12.02 -6.02; 12.02 -5.98; -12.02 -5.98], [0, 5.0]}, cWallNet);
addMesh(phase1Scenario, "polygon", {[-12.02 5.98; 12.02 5.98; 12.02 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);

% 4 Cổng ACC1-ACC4
accPositions = [-5.0, -2.5; 3.0, -2.5; 3.0, 2.5; -5.0, 2.5];
for aIdx = 1:size(accPositions, 1)
    gx = accPositions(aIdx, 1); gy = accPositions(aIdx, 2);
    addMesh(phase1Scenario, "polygon", {[gx-0.1 gy-0.9; gx+0.1 gy-0.9; gx+0.1 gy+0.9; gx-0.1 gy+0.9], [2.5, 2.65]}, cGateACC);
    addMesh(phase1Scenario, "polygon", {[gx-0.1 gy-0.8; gx+0.1 gy-0.8; gx+0.1 gy+0.8; gx-0.1 gy+0.8], [0.85, 0.95]}, cGateACC);
end

% Bệ Lấy Hàng P1, P2, P3
pPositions = [9.5, -3.0; 9.5, 0.0; 9.5, 3.0];
for pIdx = 1:size(pPositions, 1)
    px = pPositions(pIdx, 1); py = pPositions(pIdx, 2);
    addMesh(phase1Scenario, "polygon", {[px-0.5 py-0.5; px+0.5 py-0.5; px+0.5 py+0.5; px-0.5 py+0.5], [0, 1.0]}, cPedestal);
end

%% 2. Quỹ Đạo Bay Thực Tế (180 giây)
% Tốc độ tịnh tiến 0.6 - 0.9 m/s, thời gian căn chỉnh và dwell gắp hàng 25s
waypoints = [
    % [X,      Y,     Z]   Mô tả trạng thái
    -10.0,  -2.5,  0.15;   % 1. Standby Pad Depot
    -10.0,  -2.5,  1.70;   % 2. Cất cánh đạt tâm cổng 1.70m (t=10s)
     -7.5,  -2.5,  1.70;   % 3. Căn chỉnh góc tiến ACC1 (t=18s)
     -5.0,  -2.5,  1.70;   % 4. [CHUI ACC1] Chậm rãi qua cổng (t=28s)
     -1.0,  -2.5,  1.70;   % 5. Bay trong hành lang đi an toàn (t=40s)
      3.0,  -2.5,  1.70;   % 6. [CHUI ACC2] Căn chỉnh qua cổng (t=55s)
      7.0,  -1.2,  1.70;   % 7. Tiến vào Pickup Area (t=68s)
      9.5,   0.0,  1.70;   % 8. Hover ổn định trên đỉnh bệ P2 (t=80s)
      9.5,   0.0,  1.32;   % 9. Hạ ngàm gắp tiếp xúc kiện hàng 300g (t=90s)
      9.5,   0.0,  1.32;   % 10. [DWELL GẮP HÀNG] Phi công khóa chốt cơ khí (t=105s)
      9.5,   0.0,  1.70;   % 11. Nhấc bổng hàng tải nặng lên 1.70m (t=115s)
      7.0,   2.5,  1.70;   % 12. Căn hướng vào hành lang về (t=126s)
      3.0,   2.5,  1.70;   % 13. [CHUI ACC3] Bay qua cổng về (t=138s)
     -1.0,   2.5,  1.70;   % 14. Bay trong hành lang về (t=148s)
     -5.0,   2.5,  1.70;   % 15. [CHUI ACC4] Chui qua cổng cuối (t=158s)
     -8.5,   0.0,  1.70;   % 16. Tiến vào khoang Depot (t=166s)
    -10.0,   0.0,  1.20;   % 17. [GIAO HÀNG] Đặt kiện hàng an toàn (t=172s)
    -10.0,  -2.5,  1.00;   % 18. Bay chuyển tiếp sang bệ đáp (t=175s)
    -10.0,  -2.5,  0.40;   % 19. Tiếp cận mặt đất (vz <= 0.2 m/s) (t=178s)
    -10.0,  -2.5,  0.15;   % 20. [TOUCHDOWN DEPOT] Tiếp đất bệ đáp (t=180s)
    -10.0,  -2.5,  0.15    % 21. Disarm
];

timesOfArrival = [
      0.0;   % 1
     10.0;   % 2. Takeoff
     18.0;   % 3. Align ACC1
     28.0;   % 4. Pass ACC1
     40.0;   % 5. Mid-corridor
     55.0;   % 6. Pass ACC2
     68.0;   % 7. Enter Pickup
     80.0;   % 8. Hover P2
     90.0;   % 9. Lower gripper
    105.0;   % 10. Grip confirmed (15s dwell thao tác chính xác)
    115.0;   % 11. Lift cargo
    126.0;   % 12. Align ACC3
    138.0;   % 13. Pass ACC3
    148.0;   % 14. Mid-corridor return
    158.0;   % 15. Pass ACC4
    166.0;   % 16. Enter Depot
    172.0;   % 17. Deposit cargo
    175.0;   % 18. Approach pad
    178.0;   % 19. Ground effect
    180.0;   % 20. Touchdown
    180.01   % 21. Disarm
];

traj = waypointTrajectory(waypoints, TimeOfArrival=timesOfArrival, AutoBank=true);
uav = uavPlatform("UAV_Track1", phase1Scenario, Trajectory=traj);
updateMesh(uav, "quadrotor", {1.0}, [0.06 0.71 0.83], [0 0 0], eul2quat([0 0 0]));

%% 3. Thiết lập Giao diện Trực quan 3D & HUD
fig = figure("Name", "UAV Contest 2027 - Track Chuẩn Pha 1 (Realistic 3-Minute Mission)", ...
    "NumberTitle", "off", "Position", [100, 80, 1300, 820], "Color", [0.03 0.05 0.10]);
ax = show3D(phase1Scenario, "Parent", gca);
title(ax, "UAV CONTEST 2027 — PHA 1: LẤY HÀNG QUA 4 CỔNG ACC1-ACC4 (3.0 PHÚT THỰC TẾ)", ...
    "Color", [0.2 0.9 1.0], "FontSize", 13, "FontWeight", "bold");
xlabel(ax, "Chiều Dài Sân X (m) [Depot: -12..-8.5 | Pickup: 7.5..12]", "Color", [0.7 0.8 0.9]);
ylabel(ax, "Chiều Rộng Sân Y (m)", "Color", [0.7 0.8 0.9]);
zlabel(ax, "Độ Cao Z (m)", "Color", [0.7 0.8 0.9]);
view(ax, [-40, 26]);
grid(ax, "on");
set(ax, "Color", [0.05 0.08 0.15], "XColor", [0.4 0.5 0.7], "YColor", [0.4 0.5 0.7], "ZColor", [0.4 0.5 0.7]);
axis(ax, [-13 13 -7 7 0 5.5]);

% Vách trong suốt
patches = findobj(ax, "Type", "patch");
for i = 1:numel(patches)
    p = patches(i);
    if any(p.Vertices(:, 3) >= 4.9) && (range(p.Vertices(:, 1)) > 10 || range(p.Vertices(:, 2)) > 10)
        set(p, "FaceAlpha", 0.05, "EdgeColor", [0.08 0.65 0.85], "EdgeAlpha", 0.35);
    end
end

hold(ax, "on");
plot3(ax, waypoints(:,1), waypoints(:,2), waypoints(:,3), ":", ...
    "Color", [0.0 0.9 1.0 0.35], "LineWidth", 1.2);

hFlightTrail = plot3(ax, nan, nan, nan, "-", "Color", [0.0 0.95 1.0], "LineWidth", 2.2);

hudText = annotation(fig, "textbox", [0.12, 0.75, 0.40, 0.18], ...
    "Color", [0.9 0.95 1.0], "BackgroundColor", [0.04 0.08 0.16 0.90], ...
    "EdgeColor", [0.06 0.71 0.83], "LineWidth", 1.6, "FontName", "Consolas", ...
    "FontSize", 10, "FontWeight", "bold", "String", "Đang khởi tạo nhiệm vụ 180s...");

%% 4. Vòng Lặp Mô Phỏng & Giám Sát
setup(phase1Scenario);
fprintf("\n>> Bắt đầu chuyến bay thực tế Pha 1 (180 giây / 3 phút)...\n");

scorePhase1 = 0;
gatePassed = false(1, 4);
cargoPicked = false;
cargoDelivered = false;
landedSafe = false;

trailX = []; trailY = []; trailZ = [];

step = 0;
while phase1Scenario.IsRunning
    advance(phase1Scenario);
    t = phase1Scenario.CurrentTime;
    step = step + 1;
    
    motion = read(uav);
    pos = motion(1:3);
    x = pos(1); y = pos(2); z = pos(3);
    
    trailX(end+1) = x; trailY(end+1) = y; trailZ(end+1) = z;
    
    % Diễn giải trạng thái
    if t < 10.0
        statusStr = "Takeoff from Depot (Z -> 1.70m)";
    elseif t < 28.0
        statusStr = "Precision Alignment & Passing ACC1";
    elseif t < 55.0
        statusStr = "Navigating Corridor & Passing ACC2";
    elseif t < 80.0
        statusStr = "Approaching & Hovering Pedestal P2";
    elseif t < 105.0
        statusStr = "GRIPPER ENGAGING & LOCKING 300g CARGO (Manual Dwell)";
    elseif t < 115.0
        statusStr = "Lifting Payload to 1.70m Corridor Alt";
    elseif t < 138.0
        statusStr = "Passing Return Corridor Gate ACC3";
    elseif t < 158.0
        statusStr = "Passing Final Gate ACC4";
    elseif t < 172.0
        statusStr = "DEPOSITING CARGO SAFELY IN DEPOT (+60 Pts)";
    elseif t < 178.0
        statusStr = "Controlled Descent to Landing Pad";
    else
        statusStr = "TOUCHDOWN & DISARMED (Pad Depot Safe)";
    end
    
    % Sự kiện chấm điểm
    if ~gatePassed(1) && abs(x - (-5.0)) < 0.4 && abs(y - (-2.5)) < 0.6 && z > 0.9 && z < 2.5
        gatePassed(1) = true; scorePhase1 = scorePhase1 + 5;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Bay qua cổng ACC1 (+5 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    if ~gatePassed(2) && abs(x - 3.0) < 0.4 && abs(y - (-2.5)) < 0.6 && z > 0.9 && z < 2.5
        gatePassed(2) = true; scorePhase1 = scorePhase1 + 5;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Bay qua cổng ACC2 (+5 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    if ~cargoPicked && t >= 105.0 && abs(x - 9.5) < 0.5 && abs(y - 0.0) < 0.5
        cargoPicked = true;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Khóa gắp kiện hàng 300g tại trạm P2 thành công!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    if ~gatePassed(3) && abs(x - 3.0) < 0.4 && abs(y - 2.5) < 0.6 && z > 0.9 && z < 2.5
        gatePassed(3) = true; scorePhase1 = scorePhase1 + 5;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Bay qua cổng ACC3 (+5 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    if ~gatePassed(4) && abs(x - (-5.0)) < 0.4 && abs(y - 2.5) < 0.6 && z > 0.9 && z < 2.5
        gatePassed(4) = true; scorePhase1 = scorePhase1 + 5;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Bay qua cổng ACC4 (+5 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    if ~cargoDelivered && t >= 172.0 && x <= -8.5
        cargoDelivered = true; scorePhase1 = scorePhase1 + 60;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Đặt kiện hàng an toàn vào Depot (+60 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    if ~landedSafe && t >= 179.5 && z <= 0.20 && x <= -9.5
        landedSafe = true; scorePhase1 = scorePhase1 + 10;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Hạ cánh chính xác trên bệ đáp Depot (+10 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase1);
    end
    
    if isgraphics(fig) && mod(step, 2) == 0
        show3D(phase1Scenario, "Parent", ax, "FastUpdate", true);
        set(hFlightTrail, "XData", trailX, "YData", trailY, "ZData", trailZ);
        
        curMin = floor(t / 60); curSec = floor(mod(t, 60));
        hudStr = {
            sprintf("⏱ MISSION TIME: %02d:%02d / 03:00 (%.1fs)", curMin, curSec, t), ...
            sprintf("🛸 TRẠNG THÁI: %s", statusStr), ...
            sprintf("   Tọa độ: [%5.1f, %5.1f, %4.2fm]", x, y, z), ...
            sprintf("🎯 CỔNG VƯỢT QUA: ACC1[%s] ACC2[%s] ACC3[%s] ACC4[%s]", ...
                mat2str(gatePassed(1)), mat2str(gatePassed(2)), mat2str(gatePassed(3)), mat2str(gatePassed(4))), ...
            sprintf("📦 KIỆN HÀNG 300G: Gắp [%s] -> Giao [%s]", mat2str(cargoPicked), mat2str(cargoDelivered)), ...
            sprintf("⭐ ĐIỂM SỐ PHA 1: %d / 90 ĐIỂM", scorePhase1)
        };
        set(hudText, "String", hudStr);
        drawnow limitrate;
    end
end

fprintf("\n=======================================================================\n");
fprintf(">> KẾT THÚC NHIỆM VỤ THỰC TẾ PHA 1 (3.0 PHÚT):\n");
fprintf("   - Cổng ACC1..ACC4: %d/4 cổng hoàn thành.\n", sum(gatePassed));
fprintf("   - Lấy & chuyển kiện hàng 300g: %s\n", mat2str(cargoDelivered));
fprintf("   - Hạ cánh chính xác bệ đáp: %s\n", mat2str(landedSafe));
fprintf("   - TỔNG ĐIỂM PHA 1 ĐẠT ĐƯỢC: %d / 90 ĐIỂM TỐI ĐA.\n", scorePhase1);
fprintf("=======================================================================\n");
