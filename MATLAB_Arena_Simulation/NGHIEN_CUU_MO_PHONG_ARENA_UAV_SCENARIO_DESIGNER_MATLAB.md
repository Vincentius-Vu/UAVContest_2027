# BÁO CÁO NGHIÊN CỨU & THIẾT KẾ MÔ PHỎNG SÂN THI ĐẤU (ARENA) UAV CONTEST 2027
## ỨNG DỤNG MATLAB UAV SCENARIO DESIGNER & UAV TOOLBOX
**Đơn vị thực hiện:** Phòng Thí nghiệm CPAS Lab — Trường Đại học Tôn Đức Thắng (TDTU)  
**Thời gian:** Tháng 11/2026 (Phiên bản phục vụ UAV Contest 2027)

---

## I. ĐẶT VẤN ĐỀ VÀ MỤC TIÊU NGHIÊN CỨU

Cuộc thi Quốc tế **"UAV CONTEST 2027"** với chủ đề *"Hệ sinh thái Logistics Tự hành Tầm thấp"* đặt ra các thách thức kỹ thuật cao cấp trong môi trường kín không GPS (*GPS-denied*):
1. Không gian bay giới hạn $12.0 \times 24.0\text{ m}$, trần bay $\le 5.0\text{ m}$.
2. Vượt qua 4 cổng hành lang hẹp (ACC1–ACC4, đường kính $\varnothing 1.6\text{ m}$).
3. Gắp hàng từ bệ cố định P1–P3 ($1.0 \times 1.0 \times 1.0\text{ m}$) và thả hàng chính xác vào các mục tiêu D1–D5 ($\varnothing 0.4$–$1.0\text{ m}$).
4. Vòng Chung kết có mục tiêu di động **Mobile Receiver** di chuyển tuyến tính $10\text{ cm/s}$ ($0.1\text{ m/s}$).
5. Hạng mục nâng cao **Coordinated Ops (Đa tác tử)**: UAV-A và UAV-B cùng vận hành trong sân đấu, chuyển tiếp hàng hóa và phối hợp qua giao thức mạng nhị phân mở CABP, đồng thời bắt buộc duy trì khoảng cách an toàn $\ge 1.5\text{ m}$ (tránh va chạm và rủi ro phạt 20 điểm).

Để hỗ trợ Ban Tổ chức chuẩn hóa thiết kế sân đấu và cung cấp công cụ mô phỏng chuẩn xác (*Digital Twin*) cho các đội tuyển sinh viên trong nước và quốc tế, CPAS Lab tiến hành nghiên cứu khả năng xây dựng và mô phỏng toàn bộ Arena bằng ứng dụng **UAV Scenario Designer** cùng hệ sinh thái **UAV Toolbox** trên nền tảng **MATLAB R2023b/R2024a**.

---

## II. ĐÁNH GIÁ KHẢ NĂNG CỦA MATLAB UAV SCENARIO DESIGNER

### 1. Bản chất của App UAV Scenario Designer
`uavScenarioDesigner` là ứng dụng giao diện đồ họa (Interactive GUI App) thuộc MATLAB UAV Toolbox:
* **Mục đích:** Thiết kế trực quan, chỉnh sửa tham số, đặt quỹ đạo bay và cấu hình cảm biến cho các thiết bị bay không người lái trong môi trường 3D tĩnh và động.
* **Cơ chế hoạt động:** App vận hành dựa trên lớp đối tượng nền tảng `uavScenario`. Mọi thao tác kéo thả trên giao diện đều có thể xuất ngược thành kịch bản mã nguồn MATLAB (`generateScript`), lưu thành tệp `.mat`, hoặc liên kết trực tiếp với mô hình điều khiển Simulink.
* **Giao diện trực quan:** Cho phép quan sát toàn cảnh từ các góc nhìn 3D (Isometric, Top-down, Camera View gắn trên UAV), kiểm tra trực quan khoảng cách các chướng ngại vật trước khi cho bay thực tế.

### 2. Ma trận đối chiếu tính năng giữa Quy chuẩn Arena và UAV Toolbox

| Thực thể sân đấu (Rules 2027) | Đặc tính hình học / Động học | Khả năng đáp ứng của UAV Toolbox / App | Giải pháp hiện thực trong MATLAB |
|---|---|:---:|---|
| **Sàn đấu tổng thể** | $12.0 \times 24.0\text{ m}$, Z = 0 | **100% (Hoàn hảo)** | `addMesh(scenario, "polygon", {floorPoly, [-0.05 0]}, cFloor)` |
| **Phân khu chức năng** | Depot ($12\times 3.5\text{m}$), Pickup ($12\times 4.5\text{m}$), Relay ($3\times 3\text{m}$) | **100% (Hoàn hảo)** | Dựng đa giác nhiều lớp với màu sắc mã hóa phân khu |
| **Lưới an toàn bao quanh** | Chiều cao $5.0\text{ m}$, bao kín 4 cạnh | **100% (Hoàn hảo)** | Dựng 4 bức tường đa giác cao $5.0\text{ m}$ xung quanh |
| **Cổng hành lang ACC1–ACC4** | $\varnothing 1.6\text{ m}$, tâm cao $1.7\text{ m}$, đỉnh cao $2.6\text{ m}$ | **100% (Hoàn hảo)** | Dựng trụ đỡ (`polygon`) và xà trên/dưới hoặc mesh 3D vòng tròn (`custom`) |
| **Bệ lấy hàng P1–P3** | Bệ $1.0\times 1.0\times 1.0\text{ m}$ + Kiện hàng $0.3\text{m}$ | **100% (Hoàn hảo)** | Đa giác hộp extrusion `[0, 1.0]` và khối kiện hàng `[1.0, 1.3]` |
| **Mục tiêu D1–D5** | Tròn $\varnothing 0.4$–$1.0\text{ m}$, màu Đỏ/Vàng/Xanh | **100% (Hoàn hảo)** | Dùng kiểu mesh `"cylinder"` với bán kính và màu tương ứng |
| **Mobile Receiver (D2)** | Xe mang D2 di chuyển $10\text{ cm/s}$ | **100% (Đột phá)** | Tạo `uavPlatform` loại xe mặt đất (`cuboid`), gán `waypointTrajectory` vận tốc tuyến tính $0.1\text{ m/s}$ |
| **UAV-A & UAV-B** | Khung quadrotor $\le 1.0\text{m}$, bay đa tác tử | **100% (Hoàn hảo)** | `uavPlatform("quadrotor")`, gán quỹ đạo bay và kiểm soát tách biệt |
| **Hạ tầng UWB ngoài vành đai** | 4-8 cọc mốc Anchor bên ngoài sân | **100% (Hoàn hảo)** | Cột trụ cylinder cao $3.5\text{ m}$ đặt tại các tọa độ vành đai |
| **Khoảng cách an toàn $\ge 1.5\text{ m}$** | Tránh va chạm giữa 2 UAV | **100% (Hoàn hảo)** | Đọc tọa độ `read(platA)` và `read(platB)` trong vòng lặp mô phỏng để audit tự động |

---

## III. MÔ HÌNH HÓA CHI TIẾT CÁC THỰC THỂ SÂN ĐẤU (DIGITAL TWIN)

### 1. Hệ tọa độ chuẩn hóa (Reference Frame)
* Mô phỏng sử dụng hệ tọa độ cục bộ **ENU (East-North-Up)** hoặc **NED**:
  * Gốc tọa độ $(0, 0, 0)$ được đặt tại **Tâm sân đấu** (Relay Zone).
  * Chiều dài sân (trục $X$): Từ $-12.0\text{ m}$ (cuối Depot) đến $+12.0\text{ m}$ (cuối Pickup).
  * Chiều rộng sân (trục $Y$): Từ $-6.0\text{ m}$ (biên trái) đến $+6.0\text{ m}$ (biên phải).
  * Độ cao (trục $Z$): $0.0\text{ m}$ (mặt sàn) đến $+5.0\text{ m}$ (trần an toàn).

### 2. Thiết lập chuyển động Mobile Receiver ($10\text{ cm/s}$)
Để mô phỏng điểm rơi động ở Vòng Chung kết, bệ xe Mobile Receiver được định nghĩa di chuyển tuyến tính tới-lui qua `waypointTrajectory`:
```matlab
cartWaypoints = [
    -3.0, 1.5, 0.1;
     3.0, 1.5, 0.1;
    -3.0, 1.5, 0.1
];
cartTimes = [0; 60; 120]; % Quãng đường 6.0m trong 60s -> Đúng 0.10 m/s (10 cm/s)
cartTraj = waypointTrajectory(cartWaypoints, TimeOfArrival=cartTimes);
mobileCart = uavPlatform("MobileReceiver", arenaScenario, Trajectory=cartTraj);
updateMesh(mobileCart, "cuboid", {[1.2, 1.2, 0.2]}, [0.95 0.55 0.10], [0 0 0], [1 0 0 0]);
```

### 3. Tích hợp Đa tác tử (Coordinated Ops) & Giao thức CABP
* **UAV-A:** Xuất phát từ Depot ($X = -10.0\text{m}, Y = -2.5\text{m}$), bay qua ACC1–ACC2, tiếp cận P2 gắp kiện hàng $300\text{g}$, vận chuyển qua ACC3–ACC4 và đặt tại điểm D3 ($X = 0, Y = 0$) lúc $t = 47\text{s}$.
* **CABP Event Broadcast:** Khi UAV-A đặt hàng thành công tại $t = 47\text{s}$, bản tin `mission_event` phát ra.
* **UAV-B:** Đang chờ tại Depot ($X = -10.0\text{m}, Y = +2.5\text{m}$). Nhận bản tin CABP lúc $t = 48\text{s}$ ($\le 3.0\text{s}$ threshold), UAV-B tự động kích hoạt cất cánh vượt trần $3.0\text{ m}$, bay thẳng đến D3 gắp hàng tiếp sức và hạ cánh về Depot.
* **Safety Audit:** Trong suốt quá trình bay, khoảng cách Euclidean $\Delta d = \|\mathbf{p}_A(t) - \mathbf{p}_B(t)\|$ được giám sát liên tục ở tần số $20\text{ Hz}$. Nếu $\Delta d < 1.5\text{ m}$, hệ thống phát tín hiệu vi phạm luật an toàn.

---

## IV. BỘ CÔNG CỤ ĐÃ TRIỂN KHAI TRONG DỰ ÁN

Phòng thí nghiệm CPAS Lab đã đóng gói hoàn thiện bộ mã nguồn MATLAB chạy được ngay trong thư mục:  
`11_Research_Progs/02_UAV_Contest_2027/MATLAB_Arena_Simulation/`

1. **`build_uav_contest_arena.m`**:
   - Dựng tự động toàn bộ 100% thực thể sân đấu $12 \times 24\text{ m}$, vạch phân khu, lưới an toàn, 4 cổng ACC, 3 bệ P1–P3, 5 điểm D1–D5, Mobile Receiver $10\text{ cm/s}$, trụ UWB ngoài vành đai, và cấu hình 2 UAV.
   - Gắn cảm biến mô phỏng: 3D LiDAR (`uavLidarPointCloudGenerator`) và cảm biến quán tính IMU (`insSensor`).
   - Tự động lưu mô hình ra tệp `uav_contest_2027_arena.mat`.

2. **`simulate_arena_mission.m`**:
   - Tự động tải `uav_contest_2027_arena.mat` và khởi chạy vòng lặp mô phỏng thời gian thực.
   - Hỗ trợ 2 chế độ:
     * **Interactive Mode (Desktop GUI):** Hiển thị cửa sổ đồ họa 3D xoay lật góc nhìn, camera orbit, bám bắt UAV.
     * **Headless / Batch Mode:** Chạy kiểm thử tốc độ cao phục vụ đánh giá an toàn quỹ đạo.
   - Kiểm tra và xác thực quy tắc khoảng cách an toàn $\ge 1.5\text{ m}$ giữa 2 UAV.

3. **Tương thích với App `uavScenarioDesigner`**:
   - Người dùng chỉ cần gõ lệnh `uavScenarioDesigner` trong Command Window của MATLAB để mở giao diện đồ họa.
   - Trên thanh công cụ, chọn **Import Scenario** $\to$ mở tệp `uav_contest_2027_arena.mat` để xem, kéo thả thêm bớt chướng ngại vật hoặc điều chỉnh quỹ đạo bay trực quan.

---

## V. ĐÁNH GIÁ ƯU - NHƯỢC ĐIỂM & ĐỀ XUẤT MỞ RỘNG

### 1. Ưu điểm nổi bật của MATLAB UAV Scenario Designer
* **Tính toán động học & khí động học chính xác:** Tích hợp sẵn mô hình toán học bậc 6 của Quadrotor, mô phỏng đúng quán tính, độ trễ động cơ và góc nghiêng (*attitude/bank angle*).
* **Mô phỏng cảm biến vật lý chân thực:** Mô hình hóa nhiễu trắng, độ lệch drift của IMU, tần số quét và góc mở của LiDAR, cho phép sinh viên kiểm chứng thuật toán lọc Kalman (EKF) trước khi nạp lên máy tính bay PX4.
* **Cầu nối Simulink & ROS2:** Dễ dàng xuất kịch bản thành block `UAV Scenario Simulation` trong Simulink để thiết kế bộ điều khiển PID/LQR/MPC bám quỹ đạo, hoặc xuất dữ liệu qua cầu nối ROS2 (`ros2node`, `ros2publisher`) để kết nối với PX4 Software-In-The-Loop (SITL).

### 2. Hạn chế & Giải pháp khắc phục
* **Đồ họa môi trường ở mức cơ bản (Schematic / CAD 3D):** MATLAB tập trung vào tính toán vật lý chính xác, do đó hình ảnh camera mặc định không có hiệu ứng đổ bóng sân khấu hoặc ánh sáng phức tạp như Game Engine.
  * *Giải pháp:* MATLAB UAV Toolbox hỗ trợ **Unreal Engine 4/5 Co-Simulation** thông qua block `Simulation 3D Scene Configuration`. CPAS Lab có thể dùng giao tiếp này để xuất hình ảnh camera siêu thực (*photorealistic*) cho bài toán nhận diện Computer Vision ở Vòng Bán kết và Chung kết.
* **Thời gian ray-tracing LiDAR ở chế độ CPU:** Khi chạy nhiều cảm biến quét 3D đồng thời, tốc độ mô phỏng có thể chậm hơn thời gian thực nếu không kích hoạt GPU acceleration.
  * *Giải pháp:* Đặt tần số cập nhật LiDAR ở mức $10\text{ Hz}$ và giới hạn số tia quét phù hợp cho bài toán tránh va chạm.

---

## VI. KẾT LUẬN & KIẾN NGHỊ TRIỂN KHAI

1. **Khả thi 100%:** Việc sử dụng MATLAB UAV Scenario Designer và UAV Toolbox để xây dựng và mô phỏng Arena của Cuộc thi UAV Contest 2027 là **hoàn toàn khả thi, tin cậy và đạt chuẩn học thuật quốc tế**.
2. **Cung cấp cho các đội thi:** Đề xuất Ban Tổ chức đưa thư mục `MATLAB_Arena_Simulation` vào gói **Official Starter Kit** cùng với bộ mã nguồn CABP Python. Các đội thi có thể dùng bộ mô phỏng này để:
   * Kiểm thử thuật toán bay tự động qua 4 cổng ACC1–ACC4.
   * Luyện tập bài toán bám bắt mục tiêu di động Mobile Receiver $10\text{ cm/s}$.
   * Tối ưu hóa quỹ đạo Coordinated Ops để không bao giờ vi phạm vùng an toàn $1.5\text{ m}$.
