# CPAS LOCALIZATION — GHI CHÚ KỸ THUẬT & CHƯƠNG TRÌNH NGHIÊN CỨU v0.1
### Cyber-Physical Asset Systems Laboratory (CPAS Lab) — Ton Duc Thang University
### Tài liệu bổ trợ cho CABP v0.2 — làm nền cho UAV Contest 2027

**Quan hệ với CABP:** Tài liệu này KHÔNG sửa đổi CABP Technical Specification. CABP là giao thức *truyền tải* trạng thái; tài liệu này bàn về *nguồn gốc* của trạng thái đó — tức là câu hỏi "Position mà CABP truyền đi, đến từ đâu, và tin được đến mức nào".
**Ngày soạn:** 25/7/2026

---

## 0. VẤN ĐỀ GỐC

CABP truyền `position` như một trường dữ liệu, ngầm định nó đáng tin. Nhưng nếu vị trí sai 30-50cm: collision detection sai, chấm điểm sai, safety response sai. **Toàn bộ kiến trúc phía trên (CABP, scoring, safety) chỉ tốt bằng chất lượng của Localization đứng sau nó.** Đây là lý do Localization không phải chi tiết triển khai — nó là trụ cột nghiên cứu riêng.

---

## 1. PHÂN TÁCH HAI HỆ QUY CHIẾU — NGUYÊN TẮC KIẾN TRÚC BẮT BUỘC

```
┌─────────────────────────┐         ┌─────────────────────────┐
│   AGENT (đội thi)         │         │   GROUND SYSTEM (BOC)     │
│                           │         │                           │
│  Sensor (UWB tag/VIO/IMU) │         │  Overhead camera / Mocap /│
│         │                 │         │  UWB reference grid độc   │
│         ▼                 │         │  lập với hệ của đội        │
│   EKF/UKF Fusion          │         │         │                 │
│         │                 │         │         ▼                 │
│         ▼                 │         │   GROUND TRUTH            │
│  ESTIMATED POSITION        │         │   (không qua CABP)        │
│  (đi qua CABP, có thể sai) │         │                           │
└───────────┬───────────────┘         └───────────┬───────────────┘
            │                                      │
            └──────────────► SO SÁNH SAU TRẬN ◄────┘
                    (đánh giá độ chính xác thật của mỗi đội)
```

### 1.1 Nguyên tắc bắt buộc
- **CABP chỉ mang Estimated Position.** Đây là ước lượng của chính agent, có thể sai — do lỗi cảm biến, do drift, do cả cố ý lẫn vô ý.
- **Ground Truth không bao giờ đi qua CABP.** Nó thuộc về hệ thống của BOC, độc lập hoàn toàn với hệ định vị của từng đội, không agent nào có quyền truy cập trong lúc thi đấu (tránh việc đội "gian lận" bằng cách dùng luôn Ground Truth của BOC thay vì tự định vị).
- **Judge không bao giờ chấm điểm chỉ dựa trên Estimated Position tự báo cáo của đội.** Đây là hệ quả trực tiếp của nguyên tắc trên: một đội có thể (vô tình hoặc cố ý) báo cáo vị trí sai; nếu scoring dựa hoàn toàn vào con số tự báo cáo, hệ thống mất tính khách quan. Ground Truth độc lập là cơ chế đối chiếu bắt buộc cho mọi tiêu chí chấm điểm liên quan đến vị trí (qua cổng, thả hàng chính xác, giữ khoảng cách an toàn).

### 1.2 Hệ quả cho thiết kế Ground System
BOC cần một hệ thống đo độc lập, tách biệt vật lý và tổ chức khỏi thiết bị của đội thi — không nhất thiết phải chính xác tuyệt đối (không cần Motion Capture đắt tiền), nhưng phải **độc lập** và **đủ tin cậy hơn** hệ của đội để làm trọng tài. Phương án khả thi nhất cho một arena cố định 12×24m: hệ camera trần nhà (overhead camera + CV tracking) hoặc một lưới UWB reference riêng của BOC — xem so sánh Mục 3.

---

## 2. VÍ DỤ ỨNG DỤNG: XÁC MINH ĐỘ TIN CẬY TỰ BÁO CÁO

Đây là thực nghiệm cụ thể, đo được, làm cầu nối trực tiếp tới hướng Guarantee-Anchored Contract đã bàn ở giai đoạn định hướng bài báo:

```
Với mỗi thời điểm t trong trận đấu:
    sai_số(t) = || Estimated_Position(t) − Ground_Truth(t) ||

Câu hỏi nghiên cứu:
- sai_số(t) có tương quan với confidence/covariance mà EKF của đội tự báo cáo không?
- Đội nào báo cáo confidence cao (chắc chắn) nhưng sai_số thực tế lớn → đây là
  "lời hứa không được backing" (unverified promise), đúng khái niệm đã bàn trước đó.
- Đội nào báo cáo confidence thấp khi không chắc, và sai_số thực tế cũng lớn tương ứng
  → đây là "cam kết trung thực" (honest uncertainty reporting).
```

Đây chính là dữ liệu thực nghiệm đầu tiên kiểm chứng được khái niệm "SLA suy ra từ guarantee, không phải lời hứa" — không cần đợi đến giai đoạn Coordinated Ops multi-team, chỉ cần 1 mùa contest với Ground Truth độc lập là đã có dataset.

---

## 3. SO SÁNH CÁC PHƯƠNG ÁN ĐỊNH VỊ (CẬP NHẬT, MỞ RỘNG)

| Phương án | Độ chính xác | Độ trễ/Tần suất | Drift theo thời gian | Chi phí | Độ phức tạp triển khai (sinh viên) | Vai trò phù hợp |
|---|---|---|---|---|---|---|
| **RTK GPS** | 2–3 cm | Tốt | Không | Trung bình | Thấp | ❌ Không dùng được trong nhà — loại khỏi phạm vi Contest |
| **UWB RTLS** (anchor cố định, TDoA/TWR) | 10–30 cm | Cao (>100Hz khả thi) | Không | Trung bình | Trung bình | ✅ **Baseline chính cho Agent Estimated Position** — đã hợp lệ theo luật chơi |
| **UWB ranging trực tiếp** (tag-to-tag, không cần anchor) | Tương đương UWB anchor cho khoảng cách tương đối | Cao | Không | Thấp hơn (không cần lưới anchor) | Thấp | ✅ **Candidate cho CABP v0.3** — chỉ cho mục đích an toàn (D_MIN check ở Mục 6.3 CABP), không thay thế Estimated Position tuyệt đối |
| **Visual-Inertial Odometry (VIO)** | Tốt ngắn hạn, trôi dần | Cao | **Có, tích lũy theo quãng đường** | Thấp (dùng camera sẵn có) | Cao (khó nhất cho sinh viên) | ⚪ Bổ trợ cho UWB trong EKF fusion, không dùng độc lập |
| **AprilTag/ArUco** | 2–5 cm khi trong tầm nhìn | Cao khi thấy tag | Không (nhưng gián đoạn khi mất tag) | Rất thấp | Thấp | ✅ Hiệu chỉnh cục bộ gần điểm pickup/delivery, bổ trợ tốt cho VIO |
| **Overhead Camera + CV** (trần nhà, ngoài agent) | Phụ thuộc calibration, có thể đạt vài cm | Phụ thuộc xử lý ảnh | Không (đo trực tiếp, không tích lũy) | Trung bình | Trung bình | ✅ **Ứng viên tốt cho Ground Truth System của BOC** — không phải onboard, đúng vai trò trọng tài độc lập |
| **Motion Capture (Vicon/OptiTrack)** | Dưới 1cm | Rất cao | Không | Rất cao (hàng chục-trăm nghìn USD) | Thấp (hệ thương mại đóng gói) | ⚪ Lý tưởng cho Ground Truth nếu ngân sách cho phép, không bắt buộc |

---

## 4. ĐỀ TÀI NGHIÊN CỨU ĐỀ XUẤT: "LOCALIZATION BENCHMARK FOR UAV CONTEST"

### 4.1 Khung nghiên cứu
Không phải đề xuất một phương pháp định vị mới — mà là **đánh giá thực nghiệm có hệ thống** các phương án hiện có, trên cùng một arena thật (chính là arena Contest 2027), theo cùng một bộ tiêu chí. Đây là dạng bài báo "benchmark/dataset paper" — dễ ship, giá trị cao cho cộng đồng, không cần đóng góp lý thuyết mới.

### 4.2 Tiêu chí đánh giá
- **Accuracy:** sai số so với Ground Truth độc lập (Mục 1–2), không phải so sánh chéo giữa các phương pháp ước lượng với nhau.
- **Latency:** độ trễ từ lúc đo đến lúc có ước lượng khả dụng cho vòng điều khiển.
- **Drift:** đặc biệt quan trọng cho VIO — đo tích lũy sai số theo quãng đường/thời gian bay liên tục (khớp với thời lượng trận đấu thật — 5 phút).
- **Cost:** chi phí phần cứng + thời gian lắp đặt/hiệu chuẩn.
- **Complexity:** đo bằng thời gian một nhóm sinh viên cần để triển khai từ số 0 đến hoạt động ổn định — tiêu chí thực dụng, ít bài báo nào đo trực tiếp nhưng rất giá trị cho cộng đồng giáo dục robotics.

### 4.3 Điều kiện Protocol Evolution Policy áp dụng cho việc chọn phương án baseline
Không phải mọi phương án trong Mục 3 đều cần triển khai đầy đủ cho Contest 2027. Áp dụng đúng nguyên tắc đã thống nhất cho CABP: baseline bắt buộc là UWB RTLS (đã hợp lệ, đủ đơn giản, đủ chính xác cho phần lớn nhiệm vụ); VIO/AprilTag là bổ trợ tùy chọn; benchmark đầy đủ 5+ phương pháp là **đề tài nghiên cứu riêng, chạy song song, không chặn tiến độ chuẩn bị Contest**.

---

## 5. RELATIVE LOCALIZATION — PHẠM VI ĐƯỢC CHẤP NHẬN Ở v0.x

Ý tưởng "biết khoảng cách tương đối giữa 2 agent quan trọng hơn biết tọa độ tuyệt đối" là đúng về mặt lý thuyết cho bài toán swarm nói chung. Nhưng áp dụng đúng Protocol Evolution Policy đã đặt ra cho CABP:

| Điều kiện | Absolute Position (đã có) | Relative Localization (đề xuất mới) như một HƯỚNG NGHIÊN CỨU riêng |
|---|---|---|
| Necessary cho Contest 2027 | ✅ Cần cho delivery chính xác vào D1-D5, cần cho scoring | ❌ Chưa cần — D_MIN check (Mục 6.3 CABP) chỉ cần khoảng cách, không cần cả một hướng nghiên cứu riêng |
| Measurable/Testable trong 14 tháng | ✅ | ⚠️ Cần thêm hạ tầng/thí nghiệm riêng, rủi ro tiến độ |
| Implementable bởi sinh viên trong phạm vi hiện tại | ✅ | ⚠️ Đòi hỏi kiến thức chuyên sâu hơn (relative pose estimation, không chỉ ranging đơn giản) |

**Kết luận:** KHÔNG mở một hướng nghiên cứu "Relative Localization" song song ngay bây giờ. CHỈ đưa vào CABP v0.3 một field hẹp — **inter-agent range** (khoảng cách trực tiếp, đo bằng UWB tag-to-tag ranging) — dùng riêng cho mục đích an toàn (D_MIN/D_CRITICAL ở Mục 6.3 CABP), vì nó đạt đủ 4 điều kiện. Khái niệm Relative Localization đầy đủ (relative pose, không chỉ khoảng cách) ghi nhận vào roadmap dài hạn của trụ cột Localization (Mục 6), không phải việc làm ngay.

---

## 6. ĐỊNH VỊ TRONG KHUNG 3 TRỤ CỘT CPAS LAB — VÀ TRÌNH TỰ ƯU TIÊN

Ba trụ cột dài hạn cho CPAS Lab:

1. **CPAS Communication** — CABP và các giao thức phối hợp giữa agent.
2. **CPAS Localization** — định vị tuyệt đối, tương đối, và hợp nhất đa cảm biến trong môi trường GPS-denied.
3. **CPAS Safety** — phát hiện va chạm, xác minh replay, đánh giá an toàn dựa trên dữ liệu từ (1) và (2).

**Đây là khung đúng cho tầm nhìn 5 năm — nhưng KHÔNG nên triển khai như 3 dự án song song ngang hàng ngay từ bây giờ.** Lý do thuần túy là nguồn lực: Safety phụ thuộc trực tiếp vào dữ liệu từ cả Communication và Localization, không thể bắt đầu nghiêm túc trước khi hai cái kia có kết quả sơ bộ. Trình tự gối đầu đề xuất:

```
Tháng 8/2026 ────────────────────────────────────────────────► Tháng 9/2027 (Contest)

Communication (CABP)      [████████████████░░░░░░░░░░░░░░░░]  M1-M6 đã có kế hoạch
Localization (UWB baseline + benchmark)  [░░░░░████████████████░░░░]  bắt đầu chậm hơn ~2 tháng
Safety (collision replay, scoring verification)     [░░░░░░░░░░░░████████████]  bắt đầu khi có dữ liệu thật từ 2 cái trên
```

Mỗi trụ cột có thể là đề tài capstone/luận văn riêng, giao cho nhóm sinh viên khác nhau, nhưng **không nên tuyển quân đồng loạt cho cả 3 cùng lúc** — Localization nên bắt đầu ngay sau khi CABP M1-M2 (schema + bench test) đã ổn định, để nhóm Localization có sẵn giao thức để tích hợp thay vì tự định nghĩa lại từ đầu.

---

## GHI CHÚ CHO NGƯỜI HƯỚNG DẪN

Cũng như CABP, tài liệu này cố tình không chốt cứng số liệu (ngưỡng D_MIN cho ranging, phương án Ground Truth cụ thể — overhead camera hay UWB reference riêng) — đây là các quyết định cần dữ liệu thực nghiệm từ chính sinh viên trước khi chốt. Giá trị học thuật nằm ở việc đo đạc và biện luận, không phải làm theo số cho sẵn.
