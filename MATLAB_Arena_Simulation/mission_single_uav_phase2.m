%% MISSION_SINGLE_UAV_PHASE2
% Track Chuẩn - Pha 2: Giao hàng Tự Động 100% (Delivery Mission)
% Thời lượng nhiệm vụ thực tế: 210 giây (3.5 phút) - Đúng thực tế xử lý ảnh CV và thả 5 điểm.
% Quy định: Bay tự động hoàn toàn, trần bay bắt buộc 3.0m - 5.0m.
% Nhiệm vụ: Cất cánh tự động -> Thả bóng D1..D5 (kèm D2 Mobile Receiver 10 cm/s) -> 
%           Quay về RTL -> Hạ cánh tự động chính xác tâm Depot (Tổng 210s).
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc; close all;
fprintf("=======================================================================\n");
fprintf("   UAV CONTEST 2027 - TRACK CHUẨN: PHA 2 (AUTONOMOUS DELIVERY)         \n");
fprintf("   Thời lượng thực tế: 210 giây (3.5 phút) | Tốc độ bay: 0.6 - 1.0 m/s \n");
fprintf("=======================================================================\n");

%% 1. Khởi tạo Kịch bản Pha 2 (210 giây)
simRate = 10;          % 10 Hz
stopTime = 210;        % 210 giây (3.5 phút thực tế)
phase2Scenario = uavScenario("UpdateRate", simRate, "StopTime", stopTime);

cFloor       = [0.12, 0.15, 0.20];
cDepot       = [0.20, 0.35, 0.55];
cPickup      = [0.45, 0.25, 0.35];
cRedD        = [0.95, 0.15, 0.15];
cYellowD     = [0.98, 0.90, 0.10];
cBlueD       = [0.15, 0.25, 0.95];
cMobileCart  = [0.95, 0.55, 0.10];
cWallNet     = [0.08, 0.45, 0.65];
cNetPost     = [0.35, 0.40, 0.50];

% Sàn đấu 24m x 12m
addMesh(phase2Scenario, "polygon", {[-12 -6; 12 -6; 12 6; -12 6], [-0.05, 0.0]}, cFloor);
addMesh(phase2Scenario, "polygon", {[-12 -6; -8.5 -6; -8.5 6; -12 6], [0.001, 0.01]}, cDepot);
addMesh(phase2Scenario, "polygon", {[7.5 -6; 12 -6; 12 6; 7.5 6], [0.001, 0.01]}, cPickup);

% Cột và vách lưới trong suốt
postCoords = [-12 -6; -12 6; 12 -6; 12 6; -12 0; 12 0; 0 -6; 0 6];
for pIdx = 1:size(postCoords, 1)
    addMesh(phase2Scenario, "cylinder", {[postCoords(pIdx, 1), postCoords(pIdx, 2), 0.06], [0, 5.0]}, cNetPost);
end
addMesh(phase2Scenario, "polygon", {[-12.02 -6.02; -11.98 -6.02; -11.98 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);
addMesh(phase2Scenario, "polygon", {[11.98 -6.02; 12.02 -6.02; 12.02 6.02; 11.98 6.02], [0, 5.0]}, cWallNet);
addMesh(phase2Scenario, "polygon", {[-12.02 -6.02; 12.02 -6.02; 12.02 -5.98; -12.02 -5.98], [0, 5.0]}, cWallNet);
addMesh(phase2Scenario, "polygon", {[-12.02 5.98; 12.02 5.98; 12.02 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);

% 5 Điểm Giao Hàng D1 - D5
addMesh(phase2Scenario, "cylinder", {[-2.5, -3.5, 0.5], [0.01, 0.05]}, cRedD);
addMesh(phase2Scenario, "cylinder", {[0.0, 0.0, 0.3], [0.01, 0.05]}, cYellowD);
addMesh(phase2Scenario, "cylinder", {[1.5, -2.5, 0.3], [0.01, 0.05]}, cYellowD);
addMesh(phase2Scenario, "cylinder", {[2.5, 3.5, 0.2], [0.01, 0.05]}, cBlueD);

%% 2. Tạo Phương Tiện Di Động Mobile Receiver (Điểm D2 di chuyển 10 cm/s)
% Di chuyển tuyến tính qua lại giữa X = -3.0 đến X = +3.0 tại Y = 1.8 (6.0m trong 60s -> 0.10 m/s)
cartWaypoints = [
    -3.0,  1.8,  0.08;
     3.0,  1.8,  0.08;
    -3.0,  1.8,  0.08;
     3.0,  1.8,  0.08
];
cartTimes = [0.0; 60.0; 120.0; 180.0];
cartTraj = waypointTrajectory(cartWaypoints, TimeOfArrival=cartTimes);
mobileCart = uavPlatform("MobileReceiver_D2", phase2Scenario, Trajectory=cartTraj);
updateMesh(mobileCart, "cuboid", {[1.0, 1.0, 0.16]}, cMobileCart, [0 0 0], [1 0 0 0]);

%% 3. Quỹ Đạo Bay Thực Tế Pha 2 (210 giây, Trần bay 3.2m - 3.5m)
% Thời gian tiếp cận và nhận diện CV thả bóng tại mỗi điểm: 25 - 35s
uav2Waypoints = [
    % [X,      Y,     Z]   Giai đoạn nhiệm vụ
    -10.0,   0.0,  0.15;   % 1. Standby Pad Depot
    -10.0,   0.0,  3.50;   % 2. [CẤT CÁNH TỰ ĐỘNG] Đạt trần bay 3.50m (t=15s)
     -6.0,  -2.0,  3.40;   % 3. Cruise tới D1 (t=30s)
     -2.5,  -3.5,  3.30;   % 4. Hover nhận diện quang học & thả bóng D1 (t=45s)
     -0.5,  -1.0,  3.40;   % 5. Tiếp cận vùng Mobile Receiver D2 (t=62s)
      0.0,   1.8,  3.30;   % 6. [BÁM BẮT D2 10 CM/S] Dẫn đường thả trúng xe di động (t=85s)
      0.0,   0.0,  3.25;   % 7. Hover nhận diện quang học & thả bóng D3 (t=115s)
      1.5,  -2.5,  3.30;   % 8. Hover nhận diện quang học & thả bóng D4 (t=145s)
      2.5,   3.5,  3.30;   % 9. Hover căn chỉnh cực chuẩn thả bóng D5 (vòng nhỏ 0.4m) (t=175s)
      0.0,   1.5,  3.50;   % 10. Kích hoạt RTL (Return to Launch) (t=185s)
     -6.0,   0.5,  3.50;   % 11. Cruise về không phận Depot (t=195s)
    -10.0,   0.0,  3.50;   % 12. Hover ổn định trên tâm bệ đáp (t=202s)
    -10.0,   0.0,  1.20;   % 13. Giảm độ cao giai đoạn 1 (t=205s)
    -10.0,   0.0,  0.40;   % 14. Tiếp cận mặt đất (vz <= 0.2 m/s) (t=208s)
    -10.0,   0.0,  0.15;   % 15. [TOUCHDOWN TÂM DEPOT] Tiếp đất (t=210s)
    -10.0,   0.0,  0.15    % 16. Disarmed
];

uav2Times = [
      0.0;   % 1
     15.0;   % 2. Auto-takeoff
     30.0;   % 3. Approach D1
     45.0;   % 4. Drop D1 (15s căn chỉnh CV)
     62.0;   % 5. Search D2
     85.0;   % 6. Tracking & Drop D2 Mobile Receiver (23s bám bắt động)
    115.0;   % 7. Drop D3 (30s căn chỉnh)
    145.0;   % 8. Drop D4 (30s căn chỉnh)
    175.0;   % 9. Drop D5 (30s căn chỉnh vòng 0.4m)
    185.0;   % 10. RTL
    195.0;   % 11. Depot boundary
    202.0;   % 12. Hover pad
    205.0;   % 13. High descent
    208.0;   % 14. Ground effect descent
    210.0;   % 15. Touchdown
    210.01   % 16. Disarm
];

traj2 = waypointTrajectory(uav2Waypoints, TimeOfArrival=uav2Times, AutoBank=true);
uavDelivery = uavPlatform("UAV_Delivery", phase2Scenario, Trajectory=traj2);
updateMesh(uavDelivery, "quadrotor", {1.0}, [0.96 0.62 0.07], [0 0 0], eul2quat([0 0 0]));

%% 4. Thiết lập Giao diện Trực quan 3D & HUD
fig = figure("Name", "UAV Contest 2027 - Track Chuẩn Pha 2 (Realistic 3.5-Minute Mission)", ...
    "NumberTitle", "off", "Position", [120, 80, 1300, 820], "Color", [0.03 0.05 0.10]);
ax = show3D(phase2Scenario, "Parent", gca);
title(ax, "UAV CONTEST 2027 — PHA 2: GIAO HÀNG TỰ ĐỘNG & BÁM BẮT D2 (3.5 PHÚT THỰC TẾ)", ...
    "Color", [0.2 0.9 1.0], "FontSize", 13, "FontWeight", "bold");
xlabel(ax, "Chiều Dài Sân X (m)", "Color", [0.7 0.8 0.9]);
ylabel(ax, "Chiều Rộng Sân Y (m)", "Color", [0.7 0.8 0.9]);
zlabel(ax, "Độ Cao Z (m) [Trần quy chuẩn: 3.0m - 5.0m]", "Color", [0.7 0.8 0.9]);
view(ax, [-35, 32]);
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
plot3(ax, uav2Waypoints(:,1), uav2Waypoints(:,2), uav2Waypoints(:,3), ":", ...
    "Color", [0.96 0.62 0.07 0.35], "LineWidth", 1.2);

hFlightTrail = plot3(ax, nan, nan, nan, "-", "Color", [0.0 0.95 1.0], "LineWidth", 2.2);

hudText = annotation(fig, "textbox", [0.12, 0.75, 0.40, 0.18], ...
    "Color", [0.9 0.95 1.0], "BackgroundColor", [0.04 0.08 0.16 0.90], ...
    "EdgeColor", [0.06 0.71 0.83], "LineWidth", 1.6, "FontName", "Consolas", ...
    "FontSize", 10, "FontWeight", "bold", "String", "Đang khởi tạo nhiệm vụ 210s...");

%% 5. Vòng Lặp Mô Phỏng & Giám Sát Chấm Điểm
setup(phase2Scenario);
fprintf("\n>> Bắt đầu chuyến bay tự động thực tế Pha 2 (210 giây / 3.5 phút)...\n");

scorePhase2 = 0;
autoTakeoffScored = false;
dropScored = false(1, 5);
autoLandScored = false;
altitudeViolated = false;

trailX = []; trailY = []; trailZ = [];

step = 0;
while phase2Scenario.IsRunning
    advance(phase2Scenario);
    t = phase2Scenario.CurrentTime;
    step = step + 1;
    
    motion = read(uavDelivery);
    pos = motion(1:3);
    x = pos(1); y = pos(2); z = pos(3);
    
    trailX(end+1) = x; trailY(end+1) = y; trailZ(end+1) = z;
    
    % Diễn giải trạng thái
    if t < 15.0
        statusStr = "AUTONOMOUS TAKEOFF (Climbing to Safe Alt 3.50m)";
    elseif t < 45.0
        statusStr = "CV Tracking & Dropping Ball D1 (Red 1.0m)";
    elseif t < 85.0
        statusStr = "DYNAMIC TRACKING MOBILE RECEIVER D2 (10 cm/s)";
    elseif t < 115.0
        statusStr = "CV Tracking & Dropping Ball D3 (Yellow 0.6m)";
    elseif t < 145.0
        statusStr = "CV Tracking & Dropping Ball D4 (Yellow 0.6m)";
    elseif t < 175.0
        statusStr = "PRECISION CV DROP D5 (Smallest Blue 0.4m Circle)";
    elseif t < 195.0
        statusStr = "RTL (Return to Launch - Cruise 3.50m towards Depot)";
    elseif t < 205.0
        statusStr = "Precision Autonomous Landing Alignment";
    elseif t < 210.0
        statusStr = "Ground Effect Controlled Descent (vz <= 0.2 m/s)";
    else
        statusStr = "TOUCHDOWN & DISARMED (Center of Depot Pad)";
    end
    
    % Kiểm tra sự kiện cất cánh tự động
    if ~autoTakeoffScored && t >= 15.0 && z >= 3.0
        autoTakeoffScored = true; scorePhase2 = scorePhase2 + 20;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Cất cánh tự động đạt độ cao an toàn %.2fm (>=3.0m) (+20 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), z, scorePhase2);
    end
    
    % Giám sát vi phạm trần bay
    if t >= 15.0 && t <= 185.0
        if z < 3.0 || z > 5.0
            altitudeViolated = true;
        end
    end
    
    % Kiểm tra thả bóng D1
    if ~dropScored(1) && t >= 45.0 && abs(x - (-2.5)) < 0.5 && abs(y - (-3.5)) < 0.5
        dropScored(1) = true; scorePhase2 = scorePhase2 + 20;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Thả trúng bóng vào điểm D1 (Đỏ 1.0m) (+20 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    % Kiểm tra thả bóng D2 Mobile Receiver (10 cm/s)
    motionCart = read(mobileCart); posCart = motionCart(1:3);
    distToCart = norm([x - posCart(1), y - posCart(2)]);
    if ~dropScored(2) && t >= 85.0 && distToCart < 0.6
        dropScored(2) = true; scorePhase2 = scorePhase2 + 20;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Bám bắt & thả trúng D2 Mobile Receiver (10 cm/s) (+20 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    % Kiểm tra thả bóng D3
    if ~dropScored(3) && t >= 115.0 && abs(x - 0.0) < 0.4 && abs(y - 0.0) < 0.4
        dropScored(3) = true; scorePhase2 = scorePhase2 + 30;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Thả trúng bóng vào điểm D3 (Vàng 0.6m) (+30 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    % Kiểm tra thả bóng D4
    if ~dropScored(4) && t >= 145.0 && abs(x - 1.5) < 0.4 && abs(y - (-2.5)) < 0.4
        dropScored(4) = true; scorePhase2 = scorePhase2 + 30;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Thả trúng bóng vào điểm D4 (Vàng 0.6m) (+30 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    % Kiểm tra thả bóng D5
    if ~dropScored(5) && t >= 175.0 && abs(x - 2.5) < 0.35 && abs(y - 3.5) < 0.35
        dropScored(5) = true; scorePhase2 = scorePhase2 + 50;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Thả trúng bóng vào điểm D5 (Xanh 0.4m nhỏ nhất) (+50 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    % Kiểm tra hạ cánh tự động
    if ~autoLandScored && t >= 209.5 && z <= 0.20 && x <= -9.5 && abs(y) <= 0.5
        autoLandScored = true; scorePhase2 = scorePhase2 + 30;
        fprintf("   [t = %5.1fs | %02d:%02d] >> ĐẠT: Tự động hạ cánh chính xác tâm bệ Depot (+30 điểm) | Tổng: %dđ\n", ...
            t, floor(t/60), floor(mod(t, 60)), scorePhase2);
    end
    
    if isgraphics(fig) && mod(step, 2) == 0
        show3D(phase2Scenario, "Parent", ax, "FastUpdate", true);
        set(hFlightTrail, "XData", trailX, "YData", trailY, "ZData", trailZ);
        
        curMin = floor(t / 60); curSec = floor(mod(t, 60));
        hudStr = {
            sprintf("⏱ MISSION TIME: %02d:%02d / 03:30 (%.1fs)", curMin, curSec, t), ...
            sprintf("🛸 TRẠNG THÁI: %s", statusStr), ...
            sprintf("   Tọa độ: [%5.1f, %5.1f, %4.2fm]", x, y, z), ...
            sprintf("🎯 MỤC TIÊU ĐÃ THẢ: D1[%s] D2-ĐỘNG[%s] D3[%s] D4[%s] D5[%s]", ...
                mat2str(dropScored(1)), mat2str(dropScored(2)), mat2str(dropScored(3)), mat2str(dropScored(4)), mat2str(dropScored(5))), ...
            sprintf("🛡 TRẦN BAY (3.0m - 5.0m): [%s]", mat2str(~altitudeViolated)), ...
            sprintf("⭐ ĐIỂM SỐ PHA 2: %d / 200 ĐIỂM TỐI ĐA", scorePhase2)
        };
        set(hudText, "String", hudStr);
        drawnow limitrate;
    end
end

fprintf("\n=======================================================================\n");
fprintf(">> KẾT THÚC NHIỆM VỤ THỰC TẾ PHA 2 (3.5 PHÚT):\n");
fprintf("   - Cất cánh tự động (>=3.0m): %s\n", mat2str(autoTakeoffScored));
fprintf("   - Thả trúng D1 (Đỏ 1.0m): %s\n", mat2str(dropScored(1)));
fprintf("   - Thả trúng D2 (Mobile Receiver 10 cm/s): %s\n", mat2str(dropScored(2)));
fprintf("   - Thả trúng D3, D4 (Vàng 0.6m): %s, %s\n", mat2str(dropScored(3)), mat2str(dropScored(4)));
fprintf("   - Thả trúng D5 (Xanh 0.4m): %s\n", mat2str(dropScored(5)));
fprintf("   - Tuân thủ trần bay (3.0m - 5.0m): %s\n", mat2str(~altitudeViolated));
fprintf("   - Hạ cánh tự động chính xác tâm Depot: %s\n", mat2str(autoLandScored));
fprintf("   - TỔNG ĐIỂM PHA 2 ĐẠT ĐƯỢC: %d / 200 ĐIỂM TỐI ĐA.\n", scorePhase2);
fprintf("=======================================================================\n");
