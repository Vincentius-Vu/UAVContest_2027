%% RUN_UAV_CONTEST_MISSIONS
% Master Mission Launcher for UAV Contest 2027
% Select and run any of the official competition mission scenarios in MATLAB.
% Ton Duc Thang University - CPAS Lab (2026-2027)

clear; clc;
fprintf("=======================================================================\n");
fprintf("      TRƯỜNG ĐẠI HỌC TÔN ĐỨC THẮNG — CPAS LAB                         \n");
fprintf("      UAV CONTEST 2027 — MASTER MISSION SIMULATION LAUNCHER           \n");
fprintf("=======================================================================\n");
fprintf(" Vui lòng chọn kịch bản bay và hạ cánh theo nhiệm vụ cần mô phỏng:\n\n");
fprintf("   [1] TRACK CHUẨN - PHA 1 (Pick-Up Mission): 180 giây (3.0 phút)       \n");
fprintf("       Cất cánh Depot -> Chui 4 Cổng ACC1..ACC4 -> Gắp P2 -> Hạ cánh.  \n");
fprintf("   [2] TRACK CHUẨN - PHA 2 (Delivery Mission): 210 giây (3.5 phút)      \n");
fprintf("       Cất cánh tự động -> Thả bóng D1..D5 (Mobile Receiver) -> Hạ cánh.\n");
fprintf("   [3] TRACK ĐỘT PHÁ - COORDINATED OPS: 240 giây (4.0 phút)             \n");
fprintf("       UAV-A đặt hàng D3 -> Phát CABP -> UAV-B gắp hàng -> Hạ cánh A, B.\n");
fprintf("   [4] MỞ GIAO DIỆN APP UAV SCENARIO DESIGNER (Kéo thả trực quan).     \n");
fprintf("   [5] XEM TOÀN CẢNH SÂN ĐẤU 3D TRONG SUỐT (Interactive Viewer).       \n");
fprintf("=======================================================================\n");

choice = input(" Nhập lựa chọn của bạn [1 - 5] (Mặc định: 1): ", "s");
if isempty(choice), choice = "1"; end

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end

switch strtrim(choice)
    case "1"
        fprintf("\n>> Đang khởi chạy Pha 1: Lấy hàng qua 4 cổng và hạ cánh...\n");
        run(fullfile(scriptDir, "mission_single_uav_phase1.m"));
    case "2"
        fprintf("\n>> Đang khởi chạy Pha 2: Giao hàng tự động và hạ cánh chính xác...\n");
        run(fullfile(scriptDir, "mission_single_uav_phase2.m"));
    case "3"
        fprintf("\n>> Đang khởi chạy Coordinated Ops: Đa tác tử tiếp sức qua CABP...\n");
        run(fullfile(scriptDir, "mission_multi_uav_coordinated_ops.m"));
    case "4"
        fprintf("\n>> Đang mở App UAV Scenario Designer...\n");
        uavScenarioDesigner;
    case "5"
        fprintf("\n>> Đang mở Trình xem 3D sân đấu trong suốt...\n");
        run(fullfile(scriptDir, "view_arena_3d.m"));
    otherwise
        fprintf("\n>> Lựa chọn không hợp lệ. Mặc định chạy Pha 1...\n");
        run(fullfile(scriptDir, "mission_single_uav_phase1.m"));
end
