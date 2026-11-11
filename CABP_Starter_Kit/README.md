# CABP LITE STARTER KIT — UAV CONTEST
### Bộ mã nguồn mẫu Giao thức CPAS Agent Beacon Protocol (CABP)
**Đơn vị phát hành:** CPAS Lab — Khoa Điện – Điện tử, Trường Đại học Tôn Đức Thắng (TDTU)  
**Mục tiêu:** Hỗ trợ các đội thi tích hợp nhanh giao thức truyền thông đa tác tử cho Track Coordinated Ops chỉ trong 15–30 phút.

---

## 1. Cấu trúc thư viện

* `cabp_lite.py`: Thư viện lõi đóng gói/giải mã (Pack/Unpack) bản tin nhị phân chuẩn CABP qua UDP Broadcast (cổng mặc định `14555`).
  * **Bản tin Định kỳ (Periodic Beacon - 31 bytes, 5 Hz)**: Chia sẻ `agent_id`, `seq_num`, `state`, `intent`, tọa độ `(x, y, z)`, cảnh báo `battery_critical`.
  * **Bản tin Sự kiện (Mission Event - 16 bytes)**: Phát khi UAV-A đặt hàng thành công (`PACKAGE_PLACED`) kèm `location_id` (D1–D5).
* `mock_uav_a.py`: Kịch bản mẫu cho UAV-A phát bản tin khi hoàn tất Pha 1.
* `mock_uav_b.py`: Kịch bản mẫu cho UAV-B với máy trạng thái (*State Machine*):
  * Cửa sổ chờ timeout $3.0\text{ giây}$.
  * Nếu nhận được `mission_event` $\to$ Kích hoạt **Đường Bonus (+60 điểm)**, bay thẳng tới vị trí đích.
  * Nếu hết timeout không nhận được $\to$ Tự động chuyển **Đường Cơ bản (+40 điểm)** quét tuần tự mã QR.

---

## 2. Hướng dẫn chạy thử nghiệm nhanh (Quickstart)

Mở 2 cửa sổ Terminal độc lập trên máy tính hoặc Raspberry Pi:

### Bước 1: Khởi động UAV-B trước (Lắng nghe)
```bash
python mock_uav_b.py
```

### Bước 2: Khởi động UAV-A (Phát bản tin)
```bash
python mock_uav_a.py
```

Ngay lập tức, màn hình UAV-B sẽ bắt được tín hiệu `mission_event` từ UAV-A và chuyển sang chế độ bay thẳng (Đường Bonus).

---

## 3. Tích hợp vào hệ thống bay thật (DroneKit / MAVROS / ROS2)

### Đối với UAV-A (Sau khi đặt kiện hàng xuống sàn):
```python
from cabp_lite import CABPBroadcaster, CABPMessage, EventType

broadcaster = CABPBroadcaster()
# Giả sử phi công đặt hàng tại D3:
pkt = CABPMessage.pack_mission_event(agent_id=101, event_type=EventType.PACKAGE_PLACED, location_id=3)
for _ in range(3): # Gửi lặp 3 lần chống rớt gói Wi-Fi
    broadcaster.send(pkt)
```

### Đối với UAV-B (Tự động quyết định quỹ đạo bay):
```python
from cabp_lite import CABPReceiver, EventType

receiver = CABPReceiver()
# Đọc bản tin trong vòng 3.0s:
msg, _ = receiver.receive()
if msg and msg.get("event_type") == EventType.PACKAGE_PLACED:
    target_d = msg["location_id"]
    fly_direct_to(target_d) # Đường Bonus
else:
    scan_all_candidate_points() # Đường Cơ bản
```

---

## 4. Quy định an toàn bắt buộc (Authority Monotonicity)
Theo Mục XIII của Luật thi đấu, logic nhận diện CABP chỉ được phép đưa ra gợi ý điểm đích cho thuật toán dẫn đường, **tuyệt đối không được can thiệp trực tiếp vào xung điều khiển động cơ (PWM/Actuator)** của Flight Controller. Mọi hành vi mất kết nối mạng không được làm UAV mất lái hoặc treo máy tính nhúng.
