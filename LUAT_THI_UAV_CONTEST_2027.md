# LUẬT THI CHÍNH THỨC — UAV CONTEST 2027
> **HỘI THI QUỐC TẾ VỀ NGHIÊN CỨU VÀ GIÁO DỤC UAV LẦN THỨ 4 (UAV CONTEST 2027)**  
> **Lịch sử cuộc thi**: Lần 1 (2024 - TDTU, Việt Nam) $\rightarrow$ Lần 2 (2025 - VSB Ostrava, Cộng hòa Séc) $\rightarrow$ Lần 3 (2026 - HCM-UTE, Việt Nam) $\rightarrow$ **Lần 4 (2027 - TDTU, Việt Nam)**  
> **Chủ đề**: *"Autonomous Intralogistics & Cyber-Physical Swarm Challenge"* (Logistics Tự Chủ & Tác Thể Thực-Ảo)  
> **Đơn vị đăng cai**: Trường Đại học Tôn Đức Thắng (TDTU) — Nhân kỷ niệm 30 năm thành lập Trường (24/9/1997 – 24/9/2027)  
> **Đơn vị biên soạn Luật thi & Sa bàn**: Đội ngũ Giảng viên, Nghiên cứu viên Khoa Điện – Điện tử & CPAS Lab, TDTU.

---

## BẢNG SO SÁNH NÂNG CẤP (2024 vs 2027)

| Hạng mục | UAV Contest 2026 (HCM-UTE - Single Arena) | UAV Contest 2027 (TDTU Tân Phong - Dual Arenas) | Tính khả thi cho sinh viên |
|---|---|---|---|
| **Sân thi đấu (Arena)** | HCM-UTE Gymnasium ($12\times 35 \text{ m}$ tổng thể) | **TDTU Gymnasium ($>1000\text{m}^2$): 02 Sân song song ($25\times 30 \text{ m}$ / sân)** | Tăng gấp đôi năng lực thi đấu vòng bảng |
| **Nhiệm vụ chính** | Thả bóng tennis vào các lỗ tiêu chuẩn | **Gắp/Vận chuyển gói hàng đến Trạm lưu kho** | Kế thừa thuật toán nhận diện AprilTag/Camera |
| **Hình thức điều khiển** | Game 1: Tự động / Game 2: Bằng tay | **Game 1: Đơn tác tử tự trị / Game 2: Phối hợp Bầy đàn (Swarm)** | Lộ trình nâng cấp độ khó từng bước |
| **Công nghệ Định vị** | Camera / Marker thị giác đơn lẻ | **UWB RTLS + VIO + AprilTag markers** | CPAS Lab cung cấp SDK mở dễ tiếp cận |
| **Giao thức Truyền tin** | MAVLink / Tự phát triển | **CPAS Agent Beacon Protocol (CABP v0.2)** | Cung cấp sẵn thư viện C++/Python |
| **Trọng tài & Giám sát** | Quan sát thủ công của trọng tài | **Ground Truth Camera System (BOC)** | Đảm bảo tính khách quan & chính xác |

---

## CHƯƠNG 1: THỂ LỆ TỔNG QUAN VÀ NHIỆM VỤ THI ĐẤU

### 1.1 Chủ đề cuộc thi
Chủ đề chính thức của UAV Contest 2027 là **"Autonomous Intralogistics & Cyber-Physical Swarm Challenge"** (Thử thách Logistics Tự chủ & Tác thể Thực-Ảo). Cuộc thi mô phỏng bài toán vận chuyển, phân loại và giao nhận hàng hóa tự động trong nhà kho thông minh thuộc không gian bị từ chối GPS (GPS-denied environment).

### 1.2 Nhiệm vụ thi đấu (Task Description)
Mỗi đội thi có nhiệm vụ thiết kế, chế tạo và lập trình hệ thống UAV (kết hợp AMR ground robot nếu có) thực hiện chuỗi nhiệm vụ tự động:
1. **Cất cánh tự động** từ Vùng xuất phát (Start Zone, kích thước $1 \text{ m} \times 1 \text{ m}$).
2. **Nhận diện & Gắp kiện hàng**: Di chuyển đến Trạm nguồn (Source Station), sử dụng thị giác máy tính (AprilTag/Color code) để định vị và gắp/thu gom gói hàng tiêu chuẩn (kích thước $8 \times 8 \times 8 \text{ cm}$, khối lượng $80 - 120 \text{ g}$).
3. **Truyền tín hiệu nhận diện CABP**: Phát quảng bá vị trí tự ước lượng và ý định di chuyển (Estimated Position & Intent) thông qua giao thức **CABP v0.2** với tần số tối thiểu $5 \text{ Hz}$.
4. **Vượt chướng ngại vật & Vùng nhiễu**: Bay qua không gian có chướng ngại vật cố định và các vùng thách thức (khói nhẹ, hơi nước, ánh sáng thay đổi).
5. **Giao hàng đến Trạm đích**: Thả/đặt gói hàng chính xác vào các Trạm lưu kho (Target Drop Stations A, B, C) hoặc Trạm tiếp nhận di động (Ground AMR).
6. **Hạ cánh an toàn**: Trở về Vùng cất/hạ cánh và hạ cánh hoàn toàn tự động.

---

## CHƯƠNG 2: QUY ĐỊNH KỸ THUẬT VÀ PHẦN CỨNG UAV

### 2.1 Quy định phương tiện bay (UAV Specifications)
- **Thiết kế & Chế tạo**: Tất cả UAV phải do đội thi tự lắp ráp, tích hợp phần cứng và lập trình phần mềm. Không chấp nhận các dòng UAV thương mại nguyên chiếc (DJI, Autel, Skydio...).
- **Kích thước & Trọng lượng**: UAV phải nằm gọn trong khung xuất phát $1 \text{ m} \times 1 \text{ m} \times 1 \text{ m}$ trước khi cất cánh. Tổng khối lượng UAV (bao gồm pin và cơ cấu gắp) không vượt quá $3,5 \text{ kg}$.
- **Động cơ & Năng lượng**: Chỉ sử dụng động cơ điện Brushless/DC. Điện áp pin LiPo không vượt quá $6\text{S}$ ($25,2 \text{ V}$).
- **Khung điều khiển (Flight Controller)**: Cho phép sử dụng các dòng mạch điều khiển mã nguồn mở phổ biến (Pixhawk, Matek, CUAV, Kakute...) chạy firmware PX4 hoặc ArduPilot.
- **Máy tính đồng hành (Companion Computer)**: Yêu cầu trang bị máy tính biên (Raspberry Pi 4/5, NVIDIA Jetson Nano/Orin Nano, Radxa...) kết nối với Flight Controller qua MAVLink/UART để chạy thuật toán nhận diện và truyền giao thức CABP v0.2.

### 2.2 Quy định truyền dẫn và tần số
- **Dải tần cho phép**: $2,4 \text{ GHz}$, $5,8 \text{ GHz}$ cho điều khiển và truyền hình ảnh.
- **Tầng giao tiếp CABP**: Sử dụng UDP Broadcast qua mạng Wi-Fi $802.11$ sân thi đấu do Ban tổ chức cung cấp (hoặc ESP-NOW/LoRa bổ trợ).

---

## CHƯƠNG 3: CẤU TRÚC VÒNG THI VÀ LUẬT THI ĐẤU

### 3.1 Cấu trúc trận đấu (Match Format)
Mỗi trận đấu gồm 2 hiệp (Games) với tổng thời gian $20 \text{ phút}$ (không tính thời gian chuẩn bị $10 \text{ phút}$):
- **Hiệp 1: Tự trị Đơn tác tử (Single-Agent Autonomy)** — Thời gian $8 \text{ phút}$. 01 UAV tự chủ hoàn toàn bay gắp và giao hàng.
- **Hiệp 2: Phối hợp Bầy đàn (Multi-Agent Swarm Relay)** — Thời gian $12 \text{ phút}$. Đội thi vận hành đồng thời $2-3 \text{ UAV}$ (hoặc kết hợp UAV + AMR), chia sẻ thông tin vị trí qua giao thức CABP để phân chia trạm giao hàng và tránh va chạm tự động.

### 3.2 Thang điểm (Scoring System)

$$\text{Tổng điểm} = \text{Điểm giao hàng} + \text{Điểm định vị CABP} + \text{Điểm thưởng thời gian} - \text{Điểm phạt va chạm}$$

| Hạng mục | Hành động đạt điểm | Điểm số |
|---|---|---|
| **Giao hàng Trạm A** | Đặt/thả hàng vào Trạm A (Kích thước $50 \times 50 \text{ cm}$) | **+50 điểm / gói** |
| **Giao hàng Trạm B** | Đặt/thả hàng vào Trạm B (Kích thước $35 \times 35 \text{ cm}$) | **+80 điểm / gói** |
| **Giao hàng Trạm C (Đặc biệt)** | Thả chính xác vào Trạm C ($20 \times 20 \text{ cm}$) hoặc Trạm di động AMR | **+120 điểm / gói** |
| **Xác thực Định vị CABP** | Sai số giữa Vị trí tự báo cáo (CABP) & Ground Truth (BOC) $< 15 \text{ cm}$ | **+20 điểm / gói** |
| **Tránh va chạm Bầy đàn** | Hoàn thành Hiệp 2 mà không xảy ra va chạm giữa các UAV trong đội | **+100 điểm thưởng** |

### 3.3 Quy định độ cao và An toàn không phận
- **Độ cao vận hành**: UAV phải bay ở độ cao từ $1,5 \text{ m}$ đến $4,5 \text{ m}$ so với mặt sàn.
- **Hệ thống Quét Laser An toàn (Laser Barrier)**: Có chùm laser quét ở độ cao $5,0 \text{ m}$ và $1,0 \text{ m}$. UAV vi phạm độ cao quá 3 giây sẽ bị nhắc nhở; vi phạm nghiêm trọng sẽ bị kích hoạt ngắt nguồn khẩn cấp (Emergency Kill Switch).

---

## CHƯƠNG 4: HẠ TẦNG KỸ THUẬT VÀ GIAO THỨC CABP V0.2

### 4.1 Giao thức CABP v0.2 (CPAS Agent Beacon Protocol)
Mọi UAV tham gia đều phải tích hợp bộ thư viện mã nguồn mở `cpas_beacon` (do CPAS Lab phát hành) và phát bản tin định kỳ $5 \text{ Hz}$ theo định dạng:

```json
{
  "protocol_version": 2,
  "agent_id": 101,
  "seq_num": 1420,
  "state": {"x": 3.42, "y": 8.15, "z": 2.10, "vx": 0.5, "vy": 0.1, "vz": 0.0},
  "intent": {"target_x": 5.0, "target_y": 12.0, "action": "PICKUP"},
  "safety": {"battery_pct": 88, "health_flags": 1}
}
```

### 4.2 Hệ thống Trọng tài & Ground Truth (BOC Ground Logger)
Ban tổ chức bố trí hệ thống 4 Overhead Cameras gắn trần nhà kết hợp mạng UWB Anchors để đo độ chính xác vị trí thực tế của từng UAV. Điểm số định vị được chấm dựa trên sự trung thực và chính xác của dữ liệu do đội thi tự báo cáo qua CABP so với dữ liệu Ground Truth độc lập.

---

## CHƯƠNG 5: HỒ SƠ ĐĂNG KÝ VÀ SẢN PHẨM BÀN GIAO

Mỗi đội thi cần nộp hồ sơ kỹ thuật trước ngày thi đấu 01 tháng, bao gồm:
1. **Bản mô tả kỹ thuật (Technical Report)**: Bản vẽ thiết kế UAV, sơ đồ khối phần cứng, giải thuật nhận diện hình ảnh và chiến thuật phối hợp bầy đàn.
2. **Mã nguồn tích hợp CABP**: Cam kết tích hợp thư viện `cpas_beacon` và vượt qua bài test mô phỏng (SITL Test) do Ban tổ chức cung cấp.

---

## CHƯƠNG 6: YÊU CẦU AN TOÀN VÀ XỬ LÝ VI PHẠM

- **Trang bị bảo hộ (PPE)**: Thành viên đội thi phải đeo kính bảo hộ và găng tay khi thao tác trực tiếp với UAV.
- **Kích hoạt ngắt khẩn cấp**: Mỗi UAV phải cài đặt nút ngắt khẩn cấp trên tay điều khiển (Radio Transmitter). Khi bấm nút, động cơ phải dừng lập tức.
- **Trường hợp loại khỏi cuộc thi (Disqualification)**:
  - UAV bay vượt ngoài ranh giới an toàn của sân thi đấu.
  - Cố tình gây nhiễu sóng điều khiển hoặc tín hiệu CABP của đội khác.
  - Thao tác không an toàn gây nguy hiểm cho khán giả và Ban tổ chức.

---
*Bản quyền quy chế thuộc về Ban Tổ Chức UAV Contest 2027 — Trường Đại học Tôn Đức Thắng & CPAS Lab.*
