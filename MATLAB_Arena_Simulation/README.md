# MATLAB UAV Arena Simulation — UAV Contest 2027
**Phòng thí nghiệm CPAS Lab — Đại học Tôn Đức Thắng (TDTU)**

Gói công cụ mô phỏng 3D sân thi đấu chính thức ($12\text{ m} \times 24\text{ m}$) của Cuộc thi Quốc tế **UAV CONTEST 2027**, được phát triển dựa trên **MATLAB UAV Toolbox (R2023b/R2024a)** và ứng dụng **UAV Scenario Designer**.

---

## 1. Cấu trúc thư mục

## 1. Cấu trúc bộ mã nguồn mô phỏng

* [`run_uav_contest_missions.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/run_uav_contest_missions.m): **Master Launcher** — Menu tương tác 1 chạm để chọn và khởi chạy bất kỳ kịch bản nào.
* [`mission_single_uav_phase1.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/mission_single_uav_phase1.m): **Pha 1 (Pick-Up Mission — 180s / 3.0 phút)**: Cất cánh từ bệ Depot $\to$ Bay xuyên 4 cổng ACC1..ACC4 $\to$ Tiếp cận bệ P2 gắp kiện hàng $300\text{g}$ (dwell 25s căn chỉnh cơ khí) $\to$ Chuyển về Depot $\to$ Hạ cánh chuẩn xác (Đạt 90/90 điểm).
* [`mission_single_uav_phase2.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/mission_single_uav_phase2.m): **Pha 2 (Autonomous Delivery — 210s / 3.5 phút)**: Cất cánh tự động đạt độ cao an toàn $\ge 3.0\text{ m}$ $\to$ Bay thả 5 bóng tennis vào D1..D5 (bám bắt mục tiêu D2 di động $10\text{ cm/s}$ trong 40s) $\to$ RTL $\to$ Hạ cánh tự động chính xác tâm Depot (Đạt 200/200 điểm).
* [`mission_multi_uav_coordinated_ops.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/mission_multi_uav_coordinated_ops.m): **Coordinated Ops (2 UAVs Tiếp sức — 240s / 4.0 phút)**: UAV-A đặt hàng D3 $\to$ Phát CABP $\to$ UAV-B nhận trong $0.5\text{s}$ ($\le 3\text{s}$ Bonus Path) $\to$ Cất cánh gắp hàng tiếp sức $\to$ Cả 2 UAV hạ cánh đồng bộ, bảo toàn khoảng cách an toàn $\ge 1.5\text{ m}$ (Đạt +70 điểm thưởng).
* [`build_uav_contest_arena.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/build_uav_contest_arena.m): Script tự động khởi tạo toàn bộ thực thể sân đấu, lưới an toàn trong suốt (Transparent Netting), gắn cảm biến LiDAR/IMU và lưu ra tệp `.mat`.
* [`view_arena_3d.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/view_arena_3d.m): Trình xem 3D tương tác với vách lưới an toàn trong suốt (FaceAlpha = 0.05), cho phép xoay lật góc nhìn không bị che khuất.
* [`simulate_arena_mission.m`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/simulate_arena_mission.m): Script mô phỏng kiểm tra va chạm đa tác tử tổng quát.
* `uav_contest_2027_arena.mat`: Mô hình Digital Twin đã đóng gói sẵn của Arena (chuẩn bị sẵn để nạp vào App hoặc Simulink).
* [`NGHIEN_CUU_MO_PHONG_ARENA_UAV_SCENARIO_DESIGNER_MATLAB.md`](file:///c:/Users/T14/Documents/GitHub/TextBooks/CPAS_Lab/11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/NGHIEN_CUU_MO_PHONG_ARENA_UAV_SCENARIO_DESIGNER_MATLAB.md): Báo cáo nghiên cứu đánh giá tính khả thi và tài liệu kỹ thuật chi tiết.

---

## 2. Hướng dẫn sử dụng

### Cách 1: Sử dụng giao diện đồ họa App UAV Scenario Designer
1. Khởi động MATLAB (R2023b trở lên).
2. Trong cửa sổ **Command Window**, gõ lệnh:
   ```matlab
   uavScenarioDesigner
   ```
3. Trên giao diện App:
   - Nhấn **Open / Import Scenario**.
   - Chọn tệp `uav_contest_2027_arena.mat`.
   - Toàn bộ sân thi đấu $12 \times 24\text{ m}$ cùng các tác tử bay UAV-A, UAV-B và xe mục tiêu Mobile Receiver sẽ hiển thị trực quan trong không gian 3D.
   - Bạn có thể dùng chuột kéo thả các điểm Waypoint, thay đổi tốc độ bay, gắn thêm cảm biến hoặc xem trước hoạt cảnh chuyển động.

### Cách 2: Chạy trực tiếp kịch bản kiểm tra an toàn bằng Script
1. Chạy lệnh dựng sân đấu:
   ```matlab
   run('build_uav_contest_arena.m')
   ```
2. Chạy mô phỏng chuyến bay tiếp sức đa tác tử (Coordinated Ops):
   ```matlab
   run('simulate_arena_mission.m')
   ```
   * *Nếu chạy trên MATLAB Desktop:* Cửa sổ 3D đồ họa mở ra với hoạt cảnh 2 UAV bay đồng bộ và xe mục tiêu chạy $10\text{ cm/s}$.
   * *Nếu chạy trên máy chủ / dòng lệnh (Headless):* Hệ thống chạy xác thực quỹ đạo tốc độ cao và in báo cáo thẩm định an toàn (Safety Audit).
