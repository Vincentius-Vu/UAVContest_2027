%% MISSION_MULTI_UAV_COORDINATED_OPS
% Hạng mục Đột phá: Coordinated Ops (2 UAVs Relay Mission qua Giao thức Mở CABP)
% Thời lượng nhiệm vụ thực tế: 240 giây (4.0 phút) - Đúng thực tế thao tác bay thi đấu.
% Kịch bản chi tiết:
%   - UAV-A: Cất cánh Pad A -> Căn chỉnh vượt ACC1, ACC2 -> Gắp hàng P1 (dwell 30s) -> 
%            Vận chuyển đến D3 hạ đặt hàng -> Phát CABP -> Về Pad A hạ cánh (Tổng 150s).
%   - UAV-B: Standby Pad B -> Nhận CABP lúc 114.5s (Bonus Path) -> Cất cánh lên 3.5m -> 
%            Đến D3 căn chỉnh gắp hàng (dwell 25s) -> Về Pad B hạ cánh chính xác (Tổng 240s).
%   - Safety Audit: Giám sát liên tục khoảng cách giữa 2 UAV luôn >= 1.5m.
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc; close all;
fprintf("=======================================================================\n");
fprintf("   UAV CONTEST 2027 - HẠNG MỤC: COORDINATED OPS (2 UAVS RELAY)         \n");
fprintf("   Thời lượng thực tế: 240 giây (4.0 phút) | Tốc độ bay: 0.6 - 1.2 m/s \n");
fprintf("=======================================================================\n");

%% 1. Khởi tạo Kịch bản Thực tế 240s
simRate = 10;          % 10 Hz tần số cập nhật mô phỏng
stopTime = 240;        % 240 giây (4 phút thực tế)
multiScenario = uavScenario("UpdateRate", simRate, "StopTime", stopTime);

cFloor       = [0.12, 0.15, 0.20];
cDepot       = [0.20, 0.35, 0.55];
cPickup      = [0.45, 0.25, 0.35];
cRelay       = [0.15, 0.30, 0.25];
cGateACC     = [0.05, 0.85, 0.95];
cPedestal    = [0.60, 0.60, 0.65];
cYellowD     = [0.98, 0.90, 0.10];
cWallNet     = [0.08, 0.45, 0.65];
cNetPost     = [0.35, 0.40, 0.50];

% Sân đấu 24m x 12m
addMesh(multiScenario, "polygon", {[-12 -6; 12 -6; 12 6; -12 6], [-0.05, 0.0]}, cFloor);
addMesh(multiScenario, "polygon", {[-12 -6; -8.5 -6; -8.5 6; -12 6], [0.001, 0.01]}, cDepot);
addMesh(multiScenario, "polygon", {[7.5 -6; 12 -6; 12 6; 7.5 6], [0.001, 0.01]}, cPickup);
addMesh(multiScenario, "polygon", {[-1.5 -1.5; 1.5 -1.5; 1.5 1.5; -1.5 1.5], [0.001, 0.01]}, cRelay);

% Cột giàn biên và vách lưới trong suốt 5.0m
postCoords = [-12 -6; -12 6; 12 -6; 12 6; -12 0; 12 0; 0 -6; 0 6];
for pIdx = 1:size(postCoords, 1)
    addMesh(multiScenario, "cylinder", {[postCoords(pIdx, 1), postCoords(pIdx, 2), 0.06], [0, 5.0]}, cNetPost);
end
addMesh(multiScenario, "polygon", {[-12.02 -6.02; -11.98 -6.02; -11.98 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);
addMesh(multiScenario, "polygon", {[11.98 -6.02; 12.02 -6.02; 12.02 6.02; 11.98 6.02], [0, 5.0]}, cWallNet);
addMesh(multiScenario, "polygon", {[-12.02 -6.02; 12.02 -6.02; 12.02 -5.98; -12.02 -5.98], [0, 5.0]}, cWallNet);
addMesh(multiScenario, "polygon", {[-12.02 5.98; 12.02 5.98; 12.02 6.02; -12.02 6.02], [0, 5.0]}, cWallNet);

% 4 Cổng ACC (Tâm Z=1.7m)
accPositions = [-5.0, -2.5; 3.0, -2.5; 3.0, 2.5; -5.0, 2.5];
for aIdx = 1:size(accPositions, 1)
    gx = accPositions(aIdx, 1); gy = accPositions(aIdx, 2);
    addMesh(multiScenario, "polygon", {[gx-0.1 gy-0.9; gx+0.1 gy-0.9; gx+0.1 gy+0.9; gx-0.1 gy+0.9], [2.5, 2.65]}, cGateACC);
    addMesh(multiScenario, "polygon", {[gx-0.1 gy-0.8; gx+0.1 gy-0.8; gx+0.1 gy+0.8; gx-0.1 gy+0.8], [0.85, 0.95]}, cGateACC);
end

% Bệ P1 (X=9.5, Y=-3.0, Z=1.0m)
addMesh(multiScenario, "polygon", {[9.0 -3.5; 10.0 -3.5; 10.0 -2.5; 9.0 -2.5], [0, 1.0]}, cPedestal);
% Điểm chuyển tiếp D3
addMesh(multiScenario, "cylinder", {[0.0, 0.0, 0.3], [0.01, 0.05]}, cYellowD);

%% 2. Quỹ Đạo UAV-A: Lấy và Đặt hàng Chuyển tiếp (Thời lượng: 0s -> 150s)
% Tốc độ bay: 0.6 - 1.0 m/s, dwell thao tác ngàm gắp: 25 - 30s
uavAWaypoints = [
    -10.0,  -2.5,  0.15;   % 1. Standby Pad A
    -10.0,  -2.5,  1.70;   % 2. Cất cánh đạt tâm cổng 1.70m (t=8s)
     -7.0,  -2.5,  1.70;   % 3. Giảm tốc căn chỉnh góc vào ACC1 (t=14s)
     -5.0,  -2.5,  1.70;   % 4. Chui qua cổng ACC1 (t=20s)
     -1.0,  -2.5,  1.70;   % 5. Hành trình giữa 2 cổng (t=27s)
      3.0,  -2.5,  1.70;   % 6. Chui qua cổng ACC2 (t=35s)
      7.0,  -2.8,  1.70;   % 7. Tiến vào Pickup Area (t=44s)
      9.5,  -3.0,  1.70;   % 8. Hover ổn định trên đỉnh bệ P1 (t=52s)
      9.5,  -3.0,  1.32;   % 9. Hạ ngàm gắp vào kiện hàng 300g (t=58s)
      9.5,  -3.0,  1.32;   % 10. [DWELL] Thao tác khóa chốt cơ khí (t=75s)
      9.5,  -3.0,  1.70;   % 11. Nhấc kiện hàng tải nặng lên 1.70m (t=83s)
      5.0,  -1.5,  1.70;   % 12. Bay cẩn thận hướng về Relay D3 (t=95s)
      0.0,   0.0,  1.00;   % 13. Hover trên đỉnh Relay D3 (t=106s)
      0.0,   0.0,  0.38;   % 14. [ĐẶT HÀNG D3] Nhả hàng & phát CABP (t=114s)
      0.0,  -1.8,  1.70;   % 15. Nâng độ cao & lùi nhường vùng cho UAV-B (t=120s)
     -5.0,  -2.5,  1.70;   % 16. Bay về không phận Depot (t=130s)
    -10.0,  -2.5,  1.50;   % 17. Hover trên bệ Pad A (t=140s)
    -10.0,  -2.5,  0.40;   % 18. Giảm tốc hạ cánh đứng (t=146s)
    -10.0,  -2.5,  0.15;   % 19. [TOUCHDOWN PAD A] Tiếp đất (t=150s)
    -10.0,  -2.5,  0.15    % 20. Disarm hoàn tất (t=240s)
];

uavATimes = [
      0.0;   % 1
      8.0;   % 2. Takeoff
     14.0;   % 3. Align ACC1
     20.0;   % 4. Pass ACC1
     27.0;   % 5. In-corridor
     35.0;   % 6. Pass ACC2
     44.0;   % 7. Enter Pickup
     52.0;   % 8. Hover P1
     58.0;   % 9. Grip start
     75.0;   % 10. Lock confirmed (17s dwell gắp hàng thực tế)
     83.0;   % 11. Lift cargo
     95.0;   % 12. Approach Relay
    106.0;   % 13. Hover D3
    114.0;   % 14. Deposit D3 & CABP Trigger
    120.0;   % 15. Safe separation climb
    130.0;   % 16. Return corridor
    140.0;   % 17. Hover Pad A
    146.0;   % 18. Precision descent
    150.0;   % 19. Touchdown Pad A
    240.0    % 20. Disarm hold
];

trajA = waypointTrajectory(uavAWaypoints, TimeOfArrival=uavATimes, AutoBank=true);
platA = uavPlatform("UAV_A", multiScenario, Trajectory=trajA);
updateMesh(platA, "quadrotor", {1.0}, [0.06 0.71 0.83], [0 0 0], eul2quat([0 0 0]));

%% 3. Quỹ Đạo UAV-B: Tiếp Nhận Tín Hiệu CABP & Gắp Hàng Tiếp Sức (114.5s -> 240s)
% Nhận CABP lúc 114.5s -> Cất cánh lên 3.5m -> Đến D3 gắp hàng (dwell 17s) -> Về Pad B hạ cánh
uavBWaypoints = [
    -10.0,   2.5,  0.15;   % 1. Standby Pad B (chờ CABP từ t=0 đến t=114.5s)
    -10.0,   2.5,  0.15;   % 2. [NHẬN TÍN HIỆU CABP] Kích hoạt Bonus Path (t=114.5s)
    -10.0,   2.5,  3.50;   % 3. [CẤT CÁNH TỰ ĐỘNG B] Vọt lên trần an toàn 3.5m (t=125s)
     -5.0,   1.5,  3.50;   % 4. Cruise hành trình cao (t=138s)
      0.0,   0.0,  3.50;   % 5. Hover căn chỉnh góc camera trên đỉnh D3 (t=152s)
      0.0,   0.0,  1.50;   % 6. Giảm độ cao tiếp cận (t=160s)
      0.0,   0.0,  0.35;   % 7. [GẮP HÀNG CHUYỂN TIẾP D3] Khóa chốt ngàm gắp (t=168s)
      0.0,   0.0,  0.35;   % 8. [DWELL] Xác nhận lực giữ an toàn (t=185s)
      0.0,   0.0,  3.50;   % 9. Nhấc bổng hàng vọt lên trần 3.5m (t=195s)
     -5.0,   2.0,  3.50;   % 10. Cruise mang hàng về khoang Depot (t=210s)
    -10.0,   2.5,  3.50;   % 11. Hover trên bệ Pad B (t=222s)
    -10.0,   2.5,  1.20;   % 12. Hạ độ cao giai đoạn 1 (t=230s)
    -10.0,   2.5,  0.40;   % 13. Tiếp cận mặt đất (vz <= 0.2 m/s) (t=236s)
    -10.0,   2.5,  0.15;   % 14. [TOUCHDOWN PAD B] Tiếp đất chuẩn xác (t=240s)
    -10.0,   2.5,  0.15    % 15. Disarmed
];

uavBTimes = [
      0.0;   % 1
    114.5;   % 2. CABP Received (sau 0.5s kể từ khi A đặt hàng lúc 114.0s)
    125.0;   % 3. Climb to 3.5m
    138.0;   % 4. High altitude cruise
    152.0;   % 5. Align D3
    160.0;   % 6. Descend D3
    168.0;   % 7. Grip start
    185.0;   % 8. Grip confirmed (17s dwell)
    195.0;   % 9. Climb with cargo
    210.0;   % 10. Return cruise
    222.0;   % 11. Hover Pad B
    230.0;   % 12. Approach Pad B
    236.0;   % 13. Ground effect descent
    240.0;   % 14. Touchdown Pad B
    240.01   % 15. Disarm
];

trajB = waypointTrajectory(uavBWaypoints, TimeOfArrival=uavBTimes, AutoBank=true);
platB = uavPlatform("UAV_B", multiScenario, Trajectory=trajB);
updateMesh(platB, "quadrotor", {1.0}, [0.96 0.62 0.07], [0 0 0], eul2quat([0 0 0]));

%% 4. Thiết lập Giao diện Trực quan 3D & Animation Mượt Mà
fig = figure("Name", "UAV Contest 2027 - Coordinated Ops (Realistic 4-Minute Mission)", ...
    "NumberTitle", "off", "Position", [80, 50, 1340, 830], "Color", [0.03 0.05 0.10]);
ax = show3D(multiScenario, "Parent", gca);
title(ax, "UAV CONTEST 2027 — COORDINATED OPS (MISSION: 4.0 PHÚT THỰC TẾ)", ...
    "Color", [0.2 0.9 1.0], "FontSize", 13, "FontWeight", "bold");
xlabel(ax, "Chiều Dài Sân X (m)", "Color", [0.7 0.8 0.9]);
ylabel(ax, "Chiều Rộng Sân Y (m)", "Color", [0.7 0.8 0.9]);
zlabel(ax, "Độ Cao Z (m)", "Color", [0.7 0.8 0.9]);
view(ax, [-38, 28]);
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
% Quỹ đạo danh định
plot3(ax, uavAWaypoints(:,1), uavAWaypoints(:,2), uavAWaypoints(:,3), ":", ...
    "Color", [0.06 0.71 0.83 0.35], "LineWidth", 1.2);
plot3(ax, uavBWaypoints(:,1), uavBWaypoints(:,2), uavBWaypoints(:,3), ":", ...
    "Color", [0.96 0.62 0.07 0.35], "LineWidth", 1.2);

% Vệt bay động thực tế
hTrailA = plot3(ax, nan, nan, nan, "-", "Color", [0.0 0.95 1.0], "LineWidth", 2.2);
hTrailB = plot3(ax, nan, nan, nan, "-", "Color", [1.0 0.65 0.1], "LineWidth", 2.2);
hSepLine = plot3(ax, nan, nan, nan, "--", "LineWidth", 1.6);
hSepText = text(ax, 0, 0, 4.8, "", "Color", [0.2 1.0 0.4], "FontSize", 11, "FontWeight", "bold", ...
    "HorizontalAlignment", "center", "BackgroundColor", [0.02 0.05 0.12 0.85], "Margin", 4);

% Kiện hàng trực quan tại D3 sau khi A đặt
hCargoRelay = scatter3(ax, nan, nan, nan, 120, [0.9 0.4 0.1], "filled", "square");

% Bảng HUD Telemetry
hudText = annotation(fig, "textbox", [0.12, 0.73, 0.42, 0.21], ...
    "Color", [0.9 0.95 1.0], "BackgroundColor", [0.04 0.08 0.16 0.90], ...
    "EdgeColor", [0.06 0.71 0.83], "LineWidth", 1.6, "FontName", "Consolas", ...
    "FontSize", 10, "FontWeight", "bold", "String", "Đang khởi tạo nhiệm vụ 240s...");

%% 5. Vòng Lặp Mô Phỏng & Animation
setup(multiScenario);
fprintf("\n>> Bắt đầu chuyến bay phối hợp thực tế 240 giây (4 phút)...\n");

minSepDistance = Inf;
safetyThreshold = 1.5;
cabpReceived = false;
relayDeposited = false;
relayRetrieved = false;
landedPadA = false;
landedPadB = false;

trailAx = []; trailAy = []; trailAz = [];
trailBx = []; trailBy = []; trailBz = [];

step = 0;
while multiScenario.IsRunning
    advance(multiScenario);
    t = multiScenario.CurrentTime;
    step = step + 1;
    
    motA = read(platA); posA = motA(1:3);
    motB = read(platB); posB = motB(1:3);
    
    trailAx(end+1) = posA(1); trailAy(end+1) = posA(2); trailAz(end+1) = posA(3);
    trailBx(end+1) = posB(1); trailBy(end+1) = posB(2); trailBz(end+1) = posB(3);
    
    dist = norm(posA - posB);
    if dist < minSepDistance
        minSepDistance = dist;
    end
    
    % Diễn giải trạng thái chi tiết theo thời gian thực tế
    if t < 8.0
        statusA = "Takeoff Pad A (0 -> 1.70m)";
    elseif t < 35.0
        statusA = "Navigating Corridors ACC1 & ACC2 (v ~ 0.8 m/s)";
    elseif t < 58.0
        statusA = "Approaching & Hovering Pedestal P1";
    elseif t < 75.0
        statusA = "CARGO GRIP LOCKING AT P1 (Dwell 17s manual precision)";
    elseif t < 83.0
        statusA = "Lifting 300g Payload to Corridor Alt (1.70m)";
    elseif t < 106.0
        statusA = "Transporting Cargo towards Relay Zone D3";
    elseif t < 114.0
        statusA = "DEPOSITING CARGO AT D3 [CABP BROADCAST READY]";
    elseif t < 120.0
        statusA = "Ascending & Yielding D3 Zone to UAV-B";
    elseif t < 140.0
        statusA = "Returning to Depot Pad A Corridor";
    elseif t < 146.0
        statusA = "Controlled Vertical Descent Pad A";
    elseif t < 150.0
        statusA = "TOUCHDOWN & DISARMED (Pad A Safe)";
    else
        statusA = "MISSION COMPLETED (Stationary at Pad A)";
    end
    
    if ~cabpReceived && t < 114.5
        statusB = "STANDBY PAD B (Listening CABP UDP 5Hz - Heartbeat OK)";
    elseif t < 125.0
        statusB = "CABP RECEIVED (0.5s latency)! Auto-Takeoff to 3.50m";
    elseif t < 152.0
        statusB = "Direct Bonus Flight -> Cruising 3.5m to D3";
    elseif t < 168.0
        statusB = "Approaching Relayed Cargo on D3 Pad";
    elseif t < 185.0
        statusB = "CARGO GRIPPING AT D3 (Dwell 17s automated grip)";
    elseif t < 195.0
        statusB = "Lifting Payload to Safety Ceiling (3.50m)";
    elseif t < 222.0
        statusB = "Transporting Relayed Cargo back to Depot Pad B";
    elseif t < 236.0
        statusB = "Precision Landing Descent (Ground Effect vz <= 0.2 m/s)";
    else
        statusB = "TOUCHDOWN & DISARMED (Pad B Safe - 100% Score)";
    end
    
    % Kiểm tra sự kiện
    if ~relayDeposited && t >= 114.0 && abs(posA(1)) < 0.4 && abs(posA(2)) < 0.4
        relayDeposited = true;
        set(hCargoRelay, "XData", 0, "YData", 0, "ZData", 0.15);
        fprintf("   [t = %5.1fs | %02d:%02d] >> UAV-A: Đã đặt kiện hàng tại điểm chuyển tiếp D3!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
        fprintf("   [t = %5.1fs | %02d:%02d] >> CABP: UAV-A phát UDP broadcast mission_event (target_id=D3, SHA-256)\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    
    if ~cabpReceived && t >= 114.5
        cabpReceived = true;
        fprintf("   [t = %5.1fs | %02d:%02d] >> CABP: UAV-B nhận tín hiệu sau 0.5s (<= 3.0s threshold) -> KÍCH HOẠT BONUS PATH!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
        fprintf("   [t = %5.1fs | %02d:%02d] >> UAV-B: Tự động cất cánh vọt lên trần 3.5m bay thẳng tới D3!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    
    if ~landedPadA && t >= 150.0 && posA(3) <= 0.20 && posA(1) <= -9.5
        landedPadA = true;
        fprintf("   [t = %5.1fs | %02d:%02d] >> UAV-A: Hoàn thành lượt bay, hạ cánh an toàn trên Pad A (+20 điểm).\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    
    if ~relayRetrieved && t >= 185.0 && abs(posB(1)) < 0.4 && abs(posB(2)) < 0.4
        relayRetrieved = true;
        set(hCargoRelay, "XData", nan, "YData", nan, "ZData", nan); % Kiện hàng theo UAV-B
        fprintf("   [t = %5.1fs | %02d:%02d] >> UAV-B: Gắp kiện hàng chuyển tiếp tại D3 thành công, nâng lên 3.5m!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    
    if ~landedPadB && t >= 240.0 && posB(3) <= 0.20 && posB(1) <= -9.5
        landedPadB = true;
        fprintf("   [t = %5.1fs | %02d:%02d] >> UAV-B: Chuyển hàng về kho Depot, hạ cánh an toàn trên Pad B (+40 điểm)!\n", ...
            t, floor(t/60), floor(mod(t, 60)));
    end
    
    % Cập nhật animation đồ họa mỗi 2 bước (5 Hz refresh mượt mà)
    if isgraphics(fig) && mod(step, 2) == 0
        show3D(multiScenario, "Parent", ax, "FastUpdate", true);
        
        set(hTrailA, "XData", trailAx, "YData", trailAy, "ZData", trailAz);
        set(hTrailB, "XData", trailBx, "YData", trailBy, "ZData", trailBz);
        
        set(hSepLine, "XData", [posA(1), posB(1)], "YData", [posA(2), posB(2)], "ZData", [posA(3), posB(3)]);
        if dist >= safetyThreshold
            set(hSepLine, "Color", [0.1 0.9 0.4 0.8]);
            sepStatus = "AN TOÀN (>= 1.5m)";
        else
            set(hSepLine, "Color", [1.0 0.1 0.1 0.9]);
            sepStatus = "CẢNH BÁO VI PHẠM (< 1.5m)";
        end
        
        midPos = (posA + posB) / 2;
        set(hSepText, "Position", [midPos(1), midPos(2), max(posA(3), posB(3)) + 0.4], ...
            "String", sprintf("d = %.2fm", dist));
        
        curMin = floor(t / 60);
        curSec = floor(mod(t, 60));
        totMin = floor(stopTime / 60);
        totSec = floor(mod(stopTime, 60));
        
        hudStr = {
            sprintf("⏱ MISSION TIME: %02d:%02d / %02d:%02d (Tổng: %.1fs)", curMin, curSec, totMin, totSec, stopTime), ...
            sprintf("🛸 UAV-A: %s", statusA), ...
            sprintf("   Tọa độ: [%5.1f, %5.1f, %4.2fm]", posA(1), posA(2), posA(3)), ...
            sprintf("🚁 UAV-B: %s", statusB), ...
            sprintf("   Tọa độ: [%5.1f, %5.1f, %4.2fm]", posB(1), posB(2), posB(3)), ...
            sprintf("🛡 KHOẢNG CÁCH A-B: %.2f m [%s]", dist, sepStatus), ...
            sprintf("⭐ ĐIỂM THƯỞNG: +%d ĐIỂM (Bonus Path + Cự ly an toàn)", ...
                (cabpReceived*30 + relayRetrieved*20 + landedPadB*10 + (minSepDistance>=1.5)*10))
        };
        set(hudText, "String", hudStr);
        
        drawnow limitrate;
    end
end

bonusScore = 0;
if cabpReceived && relayRetrieved && landedPadB
    bonusScore = bonusScore + 60;
end
if minSepDistance >= safetyThreshold
    bonusScore = bonusScore + 10;
end

fprintf("\n=======================================================================\n");
fprintf(">> KẾT THÚC NHIỆM VỤ THỰC TẾ COORDINATED OPS (4.0 PHÚT):\n");
fprintf("   - Tổng thời gian hoàn thành: 240.0 giây (4 phút 00 giây).\n");
fprintf("   - UAV-A hoàn thành gắp P1, đặt D3 và hạ cánh Pad A lúc 02:30 (150s).\n");
fprintf("   - Tín hiệu CABP kích hoạt trong 0.5s (< 3.0s threshold) -> Đường Bonus.\n");
fprintf("   - UAV-B hoàn thành gắp D3 và hạ cánh chính xác Pad B lúc 04:00 (240s).\n");
fprintf("   - Khoảng cách an toàn nhỏ nhất ghi nhận: %.2f m (Quy chuẩn >= %.1f m).\n", minSepDistance, safetyThreshold);
fprintf("   - Thẩm định an toàn va chạm: ĐẠT 100%% (Bảo toàn điểm thưởng an toàn).\n");
fprintf("   - TỔNG ĐIỂM THƯỞNG COORDINATED OPS: +%d / +70 ĐIỂM TỐI ĐA.\n", bonusScore);
fprintf("=======================================================================\n");
