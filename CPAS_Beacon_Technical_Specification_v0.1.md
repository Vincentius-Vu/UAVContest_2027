# ĐẶC TẢ KỸ THUẬT — CPAS BEACON PROTOCOL v0.1
### Cyber-Physical Asset Systems Laboratory (CPAS Lab) — Ton Duc Thang University
### Tài liệu dùng làm đề bài nghiên cứu/thiết kế/thực thi cho sinh viên

**Trạng thái:** Draft kỹ thuật, làm nền cho luật chơi UAV Contest 2027 (track Coordinated Ops).
**Phạm vi:** Định nghĩa giao thức báo cáo trạng thái chuẩn hóa giữa các cyber-physical agent (UAV) chia sẻ cùng không gian vật lý.
**Ngày soạn:** 25/7/2026

---

## 1. MỤC TIÊU VÀ PHẠM VI

### 1.1 Mục tiêu
CPAS Beacon là một giao thức phát quảng bá (broadcast) trạng thái tối giản, tần suất cao, độ trễ thấp, cho phép:

1. Hai (hoặc nhiều) UAV hoạt động trong cùng không gian **nhận biết được vị trí và ý định của nhau** để tránh va chạm, không cần một bộ điều khiển trung tâm ra lệnh trực tiếp.
2. Một quan sát viên bên ngoài (trọng tài, hệ thống giám sát, hoặc — về sau — một agent khác không cùng đội thiết kế) **xác minh được trạng thái an toàn** của agent dựa trên dữ liệu khách quan, không dựa vào quan sát chủ quan hay lời khai của đội thi.
3. Tạo ra **dữ liệu thực nghiệm chuẩn hóa, đa nguồn** (nhiều đội, nhiều loại hardware) phục vụ nghiên cứu về sau (an toàn đa-agent, hợp đồng dựa trên guarantee).

### 1.2 Phạm vi của v0.1
Đây là phiên bản **tối giản có chủ đích** — chỉ giải quyết bài toán state broadcasting cơ bản. Các vấn đề sau **cố tình không đưa vào v0.1**, ghi nhận là hướng mở rộng (Mục 9):
- Xác thực định danh chống giả mạo (identity spoofing).
- Trường uncertainty/confidence gắn với state ước lượng.
- Cơ chế đàm phán/thương lượng giữa các agent (negotiation protocol).
- Liên agent giữa các đội khác nhau (chỉ áp dụng nội bộ 1 đội ở v0.1).

### 1.3 Nguyên tắc thiết kế
- **Transport-agnostic:** chuẩn hóa *định dạng bản tin*, không ép buộc công nghệ truyền dẫn cụ thể — để không loại trừ đội có hardware khác nhau.
- **Đơn giản trước, đúng sau:** ưu tiên một giao thức mà một nhóm sinh viên đại học có thể thiết kế, thực thi, và kiểm thử trọn vẹn trong 1–2 học kỳ.
- **Có thể quan sát từ bên ngoài:** mọi bản tin phải logging được bởi một bên thứ ba (BOC) mà không cần tham gia vào vòng điều khiển.
- **Fail-safe theo mặc định:** mất beacon phải kích hoạt hành vi an toàn đã định nghĩa trước (Mục 6), không được để hệ thống ở trạng thái không xác định.

---

## 2. KIẾN TRÚC HỆ THỐNG TỔNG QUAN

```
┌─────────────────┐        Beacon (broadcast)        ┌─────────────────┐
│   UAV Agent #1   │ ───────────────────────────────▶ │   UAV Agent #2   │
│ (Companion CPU)  │ ◀─────────────────────────────── │ (Companion CPU)  │
└─────────┬─────────┘                                  └─────────┬─────────┘
          │                                                       │
          │              Beacon (broadcast, không mã hóa)         │
          ▼                                                       ▼
                    ┌───────────────────────────────┐
                    │   Ground Logger / BOC Monitor   │
                    │  (thu log, không tham gia điều  │
                    │   khiển, dùng để chấm điểm)      │
                    └───────────────────────────────┘
```

**Ba thành phần logic bắt buộc trên mỗi UAV:**

| Thành phần | Vai trò |
|---|---|
| **State Source** | Nguồn dữ liệu trạng thái nội bộ (từ EKF/state estimator hoặc flight controller — VD Pixhawk/ArduPilot/PX4) |
| **Beacon Encoder/Transmitter** | Đóng gói state theo schema chuẩn (Mục 3), phát theo tần suất quy định (Mục 5) |
| **Beacon Receiver/Safety Monitor** | Nhận beacon từ agent khác, kiểm tra tính hợp lệ/độ trễ, kích hoạt logic an toàn khi cần (Mục 6) |

**Lưu ý kiến trúc quan trọng:** Beacon Transmitter/Receiver nên chạy trên **companion computer** (Raspberry Pi/Jetson Nano/tương đương) chứ không phải trực tiếp trên flight controller — để tách bạch vòng điều khiển bay (control-critical, cần formal guarantee) khỏi vòng truyền thông (best-effort). Đây là ứng dụng trực tiếp của nguyên tắc "control-centric integrate AI": beacon là lớp advisory/monitoring, không phải lớp có authority ghi trực tiếp lên actuator.

---

## 3. ĐỊNH DẠNG BẢN TIN (MESSAGE SCHEMA)

### 3.1 Hai biến thể khuyến nghị

Sinh viên nên triển khai **cả hai**, dùng chung một schema logic:

- **Biến thể Debug (JSON, qua UDP/TCP text):** dễ đọc, dễ debug bằng Wireshark/console trong giai đoạn phát triển.
- **Biến thể Production (Binary, compact):** dùng thật trong thi đấu — giảm băng thông, giảm độ trễ, phù hợp cho radio băng thông thấp (LoRa) nếu đội chọn hướng đó.

### 3.2 Schema logic (áp dụng cho cả hai biến thể)

| # | Trường | Kiểu | Đơn vị/Miền giá trị | Bắt buộc | Ghi chú |
|---|---|---|---|---|---|
| 1 | `protocol_version` | uint8 | Hiện tại = `1` | ✅ | Cho phép versioning về sau |
| 2 | `agent_id` | uint16 (production) / string (debug) | VD: đội 07, UAV 1 → `0x0701` | ✅ | Duy nhất trong phạm vi 1 trận đấu |
| 3 | `seq_num` | uint32 | Tăng dần, không reset trong 1 phiên bay | ✅ | Dùng để phát hiện mất gói (Mục 6.1) |
| 4 | `timestamp` | uint64 | milliseconds, epoch hoặc relative-to-takeoff | ✅ | Xem Mục 4 về đồng bộ thời gian |
| 5 | `position_x` | float32 | mét, hệ quy chiếu arena | ✅ | Gốc tọa độ = góc Depot (quy ước cố định trong luật chơi) |
| 6 | `position_y` | float32 | mét | ✅ | |
| 7 | `position_z` | float32 | mét (độ cao so với sàn arena) | ✅ | |
| 8 | `velocity_x/y/z` | float32 × 3 | m/s | ⚪ khuyến khích | Cho phép receiver dự đoán vị trí giữa 2 lần nhận (dead reckoning) |
| 9 | `heading` | float32 | độ, 0–360 | ⚪ khuyến khích | Hữu ích cho collision prediction |
| 10 | `agent_state` | enum (uint8) | `0=IDLE, 1=EXECUTING, 2=RETURNING, 3=LANDING, 4=EMERGENCY` | ✅ | |
| 11 | `battery_pct` | uint8 | 0–100 | ⚪ khuyến khích | |
| 12 | `battery_critical` | bool (1 bit) | | ✅ | Cờ riêng biệt, độc lập với `battery_pct`, để logic an toàn không phụ thuộc ngưỡng % có thể bị đội chỉnh sai |
| 13 | `checksum`/`crc16` | uint16 | | ✅ (production) | Phát hiện bản tin lỗi do nhiễu truyền dẫn |

### 3.3 Kích thước bản tin ước tính (biến thể Production, binary, đóng gói chặt)
Xấp xỉ **32–36 byte/bản tin** (không kèm velocity/heading tùy chọn: ~24 byte). Đây là kích thước rất nhỏ — quan trọng vì phải đạt tần suất phát cao (Mục 5) trên băng thông hạn chế.

### 3.4 Ví dụ biến thể Debug (JSON)
```json
{
  "protocol_version": 1,
  "agent_id": "TEAM07-UAV1",
  "seq_num": 4821,
  "timestamp_ms": 1723000012345,
  "position": {"x": 3.42, "y": 1.15, "z": 4.0},
  "velocity": {"x": 0.5, "y": 0.0, "z": 0.1},
  "heading_deg": 87.3,
  "agent_state": "EXECUTING",
  "battery_pct": 62,
  "battery_critical": false
}
```

---

## 4. ĐỒNG BỘ THỜI GIAN

Đây là vấn đề kỹ thuật **dễ bị bỏ qua nhưng quan trọng** — nếu 2 UAV không có đồng hồ tương thích, trường `timestamp` vô nghĩa khi so sánh giữa các agent.

**Khuyến nghị cho v0.1 (đơn giản, đủ dùng):**
- Dùng **relative timestamp**: tất cả agent trong cùng 1 trận đấu đồng bộ đồng hồ tại thời điểm nhận tín hiệu bắt đầu trận từ trọng tài (t=0), qua một tín hiệu chung (VD: cùng nhận lệnh "START" qua kênh điều khiển mặt đất).
- Không cần NTP/PTP phức tạp ở giai đoạn này — sai số vài chục ms giữa 2 agent chấp nhận được cho bài toán tránh va chạm ở tốc độ UAV trong arena (thấp).

**Câu hỏi nghiên cứu để sinh viên khảo sát:** độ trôi (clock drift) giữa 2 companion computer độc lập sau 5 phút bay (thời lượng trận đấu) là bao nhiêu, và nó có ảnh hưởng đáng kể đến logic tránh va chạm hay không? Đây là một thí nghiệm nhỏ, đo được, phù hợp làm một mục trong báo cáo.

---

## 5. TẦNG VẬN CHUYỂN (TRANSPORT LAYER)

### 5.1 So sánh phương án — sinh viên cần tự đánh giá và chọn, có luận cứ

| Phương án | Ưu điểm | Nhược điểm | Phù hợp khi |
|---|---|---|---|
| **UDP Broadcast qua Wi-Fi** (802.11) | Dễ triển khai nhất, băng thông cao, latency thấp trong tầm gần | Nhiễu nếu nhiều đội dùng chung băng tần 2.4/5GHz trong cùng nhà thi đấu | Arena nhỏ, mật độ Wi-Fi kiểm soát được (BOC cấp kênh riêng cho từng đội) |
| **ESP-NOW** (trên chip ESP32) | Cực nhẹ, không cần kết nối AP, latency rất thấp | Giới hạn nhà cung cấp (Espressif), băng thông thấp hơn | Đội muốn giải pháp low-cost, low-power |
| **LoRa** | Tầm xa, ít bị nhiễu bởi Wi-Fi đông đúc | Băng thông rất thấp, không đạt tần suất cao (Mục 5.2) nếu không tối ưu kỹ | Không khuyến nghị cho beacon tần suất cao trong arena nhỏ — có thể phù hợp cho hướng mở rộng ngoài trời sau này |
| **MAVLink custom message** (qua kênh telemetry sẵn có) | Tận dụng hạ tầng đã có trên phần lớn flight controller | Phụ thuộc băng thông kênh MAVLink hiện tại, có thể tranh chấp với dữ liệu điều khiển | Đội đã dùng MAVLink cho toàn bộ hệ thống, muốn tối giản số lượng kênh truyền |

**Khuyến nghị mặc định cho v0.1:** UDP Broadcast qua Wi-Fi riêng cho từng đội (mỗi đội một SSID/kênh do BOC cấp phát trước trận) — cân bằng tốt nhất giữa độ dễ triển khai và hiệu năng, phù hợp năng lực đa số đội sinh viên.

### 5.2 Tần suất phát
- **Tối thiểu đề xuất: 5 Hz** (200ms/bản tin) — đủ để phát hiện chuyển động ở tốc độ UAV trong arena nhỏ (12×24m) trước khi khoảng cách an toàn bị vi phạm.
- Sinh viên nên **đo thực nghiệm** ngưỡng tần suất tối thiểu cần thiết dựa trên tốc độ bay tối đa cho phép trong luật chơi và khoảng cách an toàn tối thiểu quy định — đây là một phép tính/thí nghiệm cụ thể, không phải số áp đặt.

---

## 6. ĐỘ TIN CẬY VÀ LOGIC AN TOÀN

### 6.1 Phát hiện mất gói (Packet Loss Detection)
Dùng `seq_num` — nếu receiver phát hiện khoảng trống trong chuỗi số tăng dần, tính tỷ lệ mất gói trong cửa sổ trượt (VD: 1 giây gần nhất).

### 6.2 Trạng thái "Stale Beacon" — cơ chế bắt buộc
Định nghĩa một **timeout ngưỡng** (đề xuất khởi điểm: 500ms không nhận được beacon mới từ agent kia):

```
Nếu (thời điểm hiện tại - timestamp bản tin cuối nhận được) > STALE_THRESHOLD:
    → Agent chuyển sang chế độ "Beacon Lost"
    → Kích hoạt hành vi an toàn định nghĩa trước:
        - Giảm tốc độ tối đa cho phép, HOẶC
        - Giữ nguyên vị trí (hover) chờ khôi phục tín hiệu, HOẶC
        - Nếu vượt quá ngưỡng thứ 2 (VD: 2 giây) → kích hoạt RTH
```

**Đây chính là điểm nối trực tiếp với nguyên tắc Authority Monotonicity đã bàn trong kiến trúc CPA tổng quát:** Beacon Receiver chỉ có quyền **đề xuất/giới hạn** (giảm tốc độ, chuyển safety mode) — quyết định cuối cùng về actuator vẫn thuộc Control Authority Layer/flight controller, không phải thuộc logic beacon. Sinh viên cần thiết kế rõ ranh giới này trong kiến trúc phần mềm, không để Beacon module có quyền ghi trực tiếp lệnh động cơ.

### 6.3 Logic tránh va chạm tối giản (Minimum Separation Enforcement)
Ở mức v0.1, đề xuất một quy tắc đơn giản, dễ kiểm chứng:

```
Khoảng_cách = ||position_agent1 - position_agent2||
Nếu Khoảng_cách < D_MIN (VD: 1.0 m, cần thống nhất với luật chơi):
    → Cả hai agent nhận cảnh báo mức 1 (giảm tốc)
Nếu Khoảng_cách < D_CRITICAL (VD: 0.5 m):
    → Kích hoạt hành vi tránh khẩn cấp theo quy tắc ưu tiên đã định trước
      (VD: agent có priority thấp hơn — theo state hoặc theo ID — nhường đường)
```

Đây là bài toán mở thú vị cho sinh viên: quy tắc ưu tiên (priority rule) nên dựa trên tiêu chí gì — trạng thái nhiệm vụ (agent đang EXECUTING được ưu tiên hơn agent IDLE), hay đơn giản là ID nhỏ hơn thắng? Đây là câu hỏi thiết kế thật, nên để sinh viên đề xuất và bảo vệ lựa chọn trong báo cáo.

---

## 7. GHI LOG PHỤC VỤ GIÁM SÁT/CHẤM ĐIỂM

- Ground Logger phải ghi lại **toàn bộ chuỗi bản tin thô** (không chỉ tóm tắt) của mọi UAV thuộc track Coordinated Ops trong suốt trận đấu.
- Định dạng log đề xuất: CSV hoặc JSON-lines, timestamp theo đồng hồ Ground Logger (không phải đồng hồ agent) để có một nguồn tham chiếu thời gian độc lập, khách quan.
- Log này là **cơ sở chấm điểm bonus** (Mục VI, tài liệu luật chơi) — cần thiết kế để BOC có thể chạy lại (replay) và kiểm tra vi phạm khoảng cách an toàn sau trận đấu, không chỉ giám sát trực tiếp.

---

## 8. KIẾN TRÚC PHẦN CỨNG THAM CHIẾU (GỢI Ý CHO SINH VIÊN)

| Thành phần | Gợi ý lựa chọn |
|---|---|
| Companion computer | Raspberry Pi 4/5, hoặc ESP32 nếu chọn hướng tối giản/low-power |
| Kết nối tới Flight Controller | Serial (UART) qua MAVLink, đọc state estimator output |
| Radio (beacon transmission) | Wi-Fi tích hợp (nếu dùng Raspberry Pi) hoặc module Wi-Fi/ESP-NOW rời |
| Ngôn ngữ triển khai đề xuất | Python (prototype nhanh, dễ debug) → C/C++ (bản production, giảm latency) — đề xuất sinh viên làm cả hai như hai milestone liên tiếp |
| Thư viện serialize gợi ý | `struct` (Python) / `protobuf` hoặc thủ công (C++) cho biến thể binary; `json` chuẩn cho biến thể debug |

---

## 9. KẾ HOẠCH NGHIÊN CỨU/TRIỂN KHAI ĐỀ XUẤT CHO SINH VIÊN

Chia thành các milestone độc lập, có thể giao cho 1 hoặc nhiều sinh viên/nhóm:

| Milestone | Nội dung | Deliverable |
|---|---|---|
| **M1 — Schema & Serialization** | Cài đặt encoder/decoder cho cả 2 biến thể (JSON, binary), viết unit test | Thư viện `cpas_beacon` (Python + C++), test coverage đầy đủ |
| **M2 — Point-to-point bench test** | Truyền/nhận giữa 2 board cố định trên bàn, đo latency, packet loss theo khoảng cách | Báo cáo đo lường: latency (ms), loss rate (%) theo khoảng cách/vật cản |
| **M3 — Time sync & stale detection** | Cài đặt cơ chế đồng bộ thời gian tương đối, logic phát hiện stale beacon | Demo: ngắt kết nối giả lập → hệ thống chuyển safety mode đúng ngưỡng thiết kế |
| **M4 — Collision logic (mô phỏng)** | Cài đặt logic Mục 6.3 trong môi trường mô phỏng (VD: 2 "agent ảo" di chuyển, không cần bay thật) | Demo mô phỏng + phân tích trường hợp biên (edge case) |
| **M5 — Tích hợp bay thật** | Gắn lên 2 UAV thật, bay thử trong không gian kiểm soát (không phải arena thi đấu) | Video demo + log thực tế + báo cáo sự cố gặp phải |
| **M6 — Kiểm thử theo kịch bản thi đấu** | Test trong mô hình thu nhỏ của arena thi đấu, đo hiệu năng dưới điều kiện tải thật (nhiều Wi-Fi cùng lúc nếu có nhiều đội test song song) | Báo cáo cuối cùng, làm input trực tiếp cho luật chơi chính thức |

**Gợi ý phân công:** M1–M3 phù hợp cho 1 sinh viên/đồ án tốt nghiệp (capstone) độc lập, tập trung vào phần mềm/giao thức. M4–M6 cần phối hợp với nhóm đang phát triển UAV thật (có thể liên kết với NCS Quang cho phần companion computer/BSP nếu phù hợp).

---

## 10. HƯỚNG MỞ RỘNG (KHÔNG THUỘC PHẠM VI v0.1, GHI NHẬN CHO NGHIÊN CỨU SAU)

- **Trường `confidence`/`uncertainty`:** gắn độ tin cậy (covariance) vào `position` — bước đầu tiên để nối beacon với hướng nghiên cứu Guarantee-Anchored Contract (SLA suy ra từ reachable set, không phải lời hứa).
- **Liên-đội (cross-team):** mở rộng beacon để agent của 2 đội khác nhau (không cùng thiết kế) cũng nhận biết được nhau — đây là bài toán khó hơn hẳn (cần chuẩn hóa hệ quy chiếu chung giữa các đội, cần cân nhắc bảo mật/spoofing).
- **Xác thực định danh nhẹ:** chữ ký số tối giản để chống giả mạo `agent_id`, phù hợp khi mở rộng liên-đội.

---

## GHI CHÚ CHO NGƯỜI HƯỚNG DẪN

Tài liệu này cố tình dừng ở mức "đặc tả đủ chi tiết để bắt đầu implement" chứ không phải "đặc tả hoàn chỉnh không còn gì để quyết định" — các con số ngưỡng (STALE_THRESHOLD, D_MIN, D_CRITICAL, tần suất 5Hz) đều là điểm khởi đầu hợp lý, không phải giá trị cuối cùng. Một phần giá trị học thuật của đồ án chính là để sinh viên tự đo đạc, biện luận, và điều chỉnh các ngưỡng này dựa trên thực nghiệm — đừng chốt cứng trước khi có dữ liệu thật.
