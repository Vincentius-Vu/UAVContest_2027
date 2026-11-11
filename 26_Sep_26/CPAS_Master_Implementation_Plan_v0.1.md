# KẾ HOẠCH TRIỂN KHAI TỔNG THỂ — CPAS (CYBER-PHYSICAL ASSET SYSTEMS)
### Từ UAV Contest 2027 đến CPAS Lab — Roadmap 14 tháng
### TS. Trí Viễn Vũ — DCAS Lab, Khoa Điện – Điện tử, Trường Đại học Tôn Đức Thắng

**Ngày soạn:** 16/8/2026
**Mốc đích:** Kỷ niệm 30 năm thành lập TDTU — dự kiến quanh 24/9/2027

---

## 0. TÓM TẮT CHƯƠNG TRÌNH

CPAS không phải một dự án đơn lẻ — đây là **năm workstream phụ thuộc lẫn nhau**, cùng hội tụ về một mốc thời gian cố định (24/9/2027) và cùng phục vụ một mục tiêu kép: (a) tổ chức thành công UAV Contest 2027 với track Coordinated Ops, và (b) dùng chính kết quả đó làm nền tảng thực nghiệm cho CPAS Lab và các công bố khoa học tiếp theo.

**Nguyên tắc điều phối xuyên suốt đã thống nhất, áp dụng cho toàn bộ kế hoạch:**
- Đổi narrative, không đổi mission skeleton (rủi ro kỹ thuật thấp cho đội thi).
- Protocol Evolution Policy: mọi thành phần mới phải Necessary/Measurable/Testable/Implementable trong khung thời gian hiện có — không tổng quát hóa sớm.
- Ba trụ cột nghiên cứu (Communication/Localization/Safety) chạy **gối đầu**, không song song ngang hàng.
- Không dùng bất kỳ số liệu/căn cứ pháp lý nào chưa được xác minh trực tiếp từ nguồn gốc.

**Definition of Done cho CPAS giai đoạn 1 (Contest 2027) — tiêu chí nghiệm thu duy nhất, thay cho các mục tiêu rời rạc:**

| # | Việc | Workstream tương ứng |
|---|---|---|
| 1 | **Identify** — biết agent là ai | WS2 (CABP Identity fields) |
| 2 | **Locate** — biết agent ở đâu | WS3 (Localization) |
| 3 | **Observe** — biết agent đang ở trạng thái gì | WS2 (CABP State/Mission/Safety fields) |
| 4 | **Communicate** — chia sẻ state giữa các agent | WS2 (CABP transport) |
| 5 | **Monitor** — BOC quan sát thời gian thực | WS3 (Ground System / dashboard) |
| 6 | **Record** — lưu toàn bộ trajectory/event | WS3 (Ground Logger) |
| 7 | **Replay** — sau trận tái dựng được chuyện gì đã xảy ra | WS5 (Safety/collision replay) |

Nếu cả 7 việc trên chạy được trên ít nhất 1 UAV thật trước Contest 2027 → CPAS có một reference implementation thực sự, không cần AI, không cần blockchain, không cần Digital Twin platform để "đủ" ở giai đoạn này.

**Danh sách KHÔNG làm trong 24 tháng đầu (chặn phạm vi công khai, áp dụng cho toàn chương trình):**
Không xây blockchain platform · không xây UTM quốc gia · không xây swarm intelligence hoàn chỉnh · không xây Digital Twin platform lớn · không thiết kế protocol tổng quát cho mọi loại robot · không làm foundation model · không làm humanoid · không làm "AI platform". Tất cả đều là hướng mở rộng dài hạn (xem tài liệu riêng *CPAS Long-Term Vision*), không phải việc của 14 tháng tới. Danh sách này tồn tại để mọi đề xuất mở rộng phạm vi trong tương lai phải tự chứng minh lý do đi ngược lại nguyên tắc này, thay vì mặc định được chấp nhận.

---

## 1. NĂM WORKSTREAM

| # | Workstream | Trạng thái hiện tại | Đầu ra chính |
|---|---|---|---|
| WS1 | **UAV Contest 2027 Rules** (vai trò Technical Chair) | Draft đầy đủ v0.2 đã có | Luật chơi chính thức công bố Q1/2027 |
| WS2 | **CABP** (CPAS Agent Beacon Protocol) | Spec v0.2 đã có, sẵn sàng giao capstone | Giao thức chạy được, M1–M6 |
| WS3 | **CPAS Localization** | Technical Note v0.1 đã có | UWB baseline + Ground Truth system + benchmark |
| WS4 | **Đề tài cơ sở TDTU** (kinh phí) | Prompt điều phối agent đã có, chờ mẫu thật | Thuyết minh đề tài + kinh phí nộp hồ sơ |
| WS5 | **CPAS Safety** (phụ thuộc WS2+WS3) | Chưa bắt đầu, đúng theo thiết kế | Collision replay, xác minh chấm điểm |

---

## 2. ROADMAP TỔNG HỢP — TÍNH NGƯỢC TỪ 24/9/2027

```
                2026                                    2027                          2027
   T8    T9    T10   T11   T12   T1    T2    T3    T4    T5    T6    T7    T8    T9(Contest)
   │     │     │     │     │     │     │     │     │     │     │     │     │     │
WS4├──────────►│                                                                    Đề tài cơ sở:
   │  Nộp hồ sơ│ Chờ duyệt/giải ngân (giả định ~1-2 tháng xử lý hành chính)
   │     │     │     │
WS1├─────┼─────►     │                                                              Rule:
   │ Review │ Đề xuất │                                                             công bố
   │ nội bộ │ Chair+  │                                                             chính thức
   │        │ CPAS Lab│
   │        │         ├─────────────────────────►│
   │        │         │   Hoàn thiện rule chi tiết│ (đến hết Q1/2027)
   │        │         │
WS2├────────────────────────────────►│
   │   M1: Schema/Serialize            M2: Bench test (2 board)
   │              (T8-T10/2026)              (T10-T11/2026)
   │                                          │
   │                                          ├──────►│
   │                                    M3: Time sync/stale (T11/2026-T1/2027)
   │                                                   │
   │                                                   ├──────►│
   │                                             M4: Collision logic mô phỏng (T1-T2/2027)
   │
WS3│              ├─────────────────────────►│
   │        (bắt đầu ~2 tháng sau WS2, khi CABP M1-M2 ổn định)
   │              UWB baseline + Ground Truth system (T10/2026-T2/2027)
   │                                          │
   │                                          ├──────────►│
   │                                    Benchmark thực nghiệm (T2-T4/2027)
   │
   │                                                              ├───────►│
WS2/3                                                    M5: Tích hợp bay thật (T3-T5/2027)
   │                                                                       │
   │                                                                       ├───────►│
   │                                                            M6: Test theo kịch bản thi đấu (T5-T7/2027)
   │
   │                                                                                ├────►│
WS5│                                                                    Bắt đầu khi có dữ liệu thật từ WS2+WS3
   │                                                                    Collision replay/scoring verification
   │                                                                    (T5-T8/2027)
   │
                                                                                                    ▼
                                                                                          UAV CONTEST 2027
                                                                                          (~24/9/2027)
```

**Mốc phần cứng quan trọng nằm ngoài luồng trên:** đặt hàng linh kiện (UWB anchor, companion computer, overhead camera nếu chọn) phải hoàn tất **chậm nhất đầu T10/2026** — lead time linh kiện dài (16–24 tuần đã ghi nhận cho một số dòng chip) khiến đây là nút thắt cứng, không co giãn được.

---

## 3. CHI TIẾT TỪNG WORKSTREAM

### WS1 — UAV Contest 2027 Rules
- **Việc cần làm ngay (T8-T9/2026):** gửi draft v0.2 cho hội đồng kỹ thuật độc lập review — đặc biệt các mục **[CẦN REVIEW]** đã liệt kê (điểm thưởng Coordinated Ops, ngưỡng phạt va chạm, quyết định vật liệu mô phỏng).
- **T9-T10/2026:** nộp đề xuất chính thức nhận vai trò Technical Chair, gộp chung hồ sơ với đề xuất CPAS Lab (đã thống nhất từ đầu).
- **Chậm nhất Q1/2027:** công bố luật chính thức — để đội thi có 6-9 tháng chuẩn bị.
- **Rủi ro chính:** xung đột vai trò nếu vô tình thiên vị TDTU — đã có phương án giảm thiểu (không kiêm team leader, review công khai với hội đồng độc lập).

### WS2 — CABP (Giao thức truyền thông)
- Sáu milestone M1–M6 đã định nghĩa đầy đủ trong CABP Technical Specification v0.3 (nâng từ v0.2 ngày 16/8/2026 — thêm `mission_event`, bản tin sự kiện rời rạc cho cơ chế relay Mục V.D luật chơi).
- M1–M3 (schema, bench test, time sync) **không phụ thuộc phần cứng UAV thật** — có thể giao ngay làm đồ án tốt nghiệp độc lập, bắt đầu sớm nhất có thể.
- M4 (collision logic) chạy mô phỏng thuần túy trước khi tích hợp bay thật — giảm rủi ro.
- M5–M6 cần phối hợp phần cứng — đây là điểm nối tự nhiên với năng lực companion computer/BSP đã có trong lab (hướng NCS Quang), cần xác nhận mức độ tham gia.

### WS3 — CPAS Localization
- **Cố tình bắt đầu chậm hơn WS2 khoảng 2 tháng** — để nhóm Localization có sẵn CABP schema ổn định (M1-M2) làm nền tích hợp, không phải tự định nghĩa lại từ đầu.
- Ưu tiên: UWB RTLS baseline (đã hợp lệ theo luật chơi Mục III.3) + xây dựng Ground System (Ground Truth) độc lập của BOC.
- **✅ Đã chốt nguyên tắc (16/8/2026), thiết kế đã sửa sau đánh giá rủi ro khả thi:** Ground Truth dùng Overhead Camera + AprilTag (không dùng UWB reference riêng — lý do độc lập nguyên lý vật lý), nhưng chuyển từ phủ toàn arena (4 camera) sang **phủ theo điểm trọng yếu** (6 camera Global Shutter, tách capture/compute) do rủi ro tầm phát hiện AprilTag không đủ ở khoảng cách/diện tích lớn. Chi phí ước tính ~49,5 triệu VND (Mục A4.1-A4.7, UAV_Contest_2027_Du_Toan_Kinh_Phi.xlsx). Chi tiết kiến trúc: CPAS Localization Technical Note Mục 1.2.
- **[MỚI, CẦN LÀM]** Khảo sát độ cao trần thực tế của venue thi đấu trước khi chốt số lượng/vị trí camera cuối cùng và giải ngân Mục A4.7 (dự phòng giàn treo, hiện để 10 triệu, có thể giảm về 0).
- Benchmark đầy đủ (so sánh UWB/VIO/AprilTag) là đề tài nghiên cứu chạy song song, không chặn tiến độ chuẩn bị Contest.

### WS4 — Đề tài cơ sở TDTU (kinh phí)
- **Ưu tiên đề tài cơ sở, định hướng ứng dụng** — trọng điểm chưa có biểu mẫu, không phải lựa chọn khả thi lúc này.
- Prompt điều phối agent đã sẵn sàng — chỉ chờ file mẫu thật (docx) từ TDTU để chạy.
- Phần "Tính cấp thiết" đã có căn cứ pháp lý xác minh đầy đủ: Nghị định 288/2025/NĐ-CP (05/11/2025) và Thông tư 39/2025/TT-BQP (05/6/2025) với các mốc lộ trình đã xác nhận trực tiếp từ Phụ lục I — UAAN (ISO/IEC 4005-2/3/4) hiệu lực 01/7/2026, Remote ID (ISO 23629-8) và UTM service provider (ISO 23629-12) hiệu lực 01/7/2028.
- **Việc cần làm ngay:** xin file mẫu Thuyết minh đề tài + Thuyết minh kinh phí từ phòng KH-CN TDTU; xác nhận hạn mức kinh phí đề tài cơ sở năm nay; xác định nhân sự tham gia chính thức (sinh viên/NCS).
- Sau khi có kết quả 1 năm (dữ liệu thật từ Contest 2027) → dùng làm track record để nộp đề tài trọng điểm khi có biểu mẫu.

### WS5 — CPAS Safety
- **Cố tình để bắt đầu sau cùng** — phụ thuộc trực tiếp dữ liệu thật từ WS2 (log beacon) và WS3 (Ground Truth).
- Nội dung: collision replay (dùng log CABP để tái hiện và kiểm chứng vi phạm khoảng cách an toàn sau trận), xác minh độ chính xác chấm điểm dựa trên đối chiếu Estimated Position vs Ground Truth (Mục 2, CPAS Localization Technical Note).
- Đây cũng là nơi sinh ra dữ liệu thực nghiệm đầu tiên cho hướng Guarantee-Anchored Contract — không cần chờ đến giai đoạn liên-đội nhiều năm sau.

---

## 4. PHÂN CÔNG NHÂN SỰ ĐỀ XUẤT (CẦN ANH XÁC NHẬN)

| Vai trò | Workstream | Người đề xuất | Ghi chú |
|---|---|---|---|
| PI / Technical Chair | WS1, WS4, điều phối chung | TS. Trí Viễn Vũ | Không kiêm team leader (đã thống nhất) |
| Capstone 1 | WS2 — **CABP protocol thuần túy** (schema, encoder/decoder, benchmark, M1–M3) | **[CẦN XÁC NHẬN]** sinh viên/nhóm mới | Không phụ thuộc phần cứng UAV, bắt đầu ngay T8/2026 |
| Capstone 2 | WS2 — **CPAS Edge Node hardware** (OS, interface, MAVLink, logging, tích hợp companion computer) | **[CẦN XÁC NHẬN]** liên kết NCS Quang? | Tách riêng khỏi Capstone 1 theo đúng phân chia công việc rõ ràng — mỗi sinh viên có đề tài hoàn thành được, ghép lại thành hệ thống |
| Capstone 3 | WS3 — UWB baseline + Ground Truth/Monitor (Ground System, dashboard, live map) | **[CẦN XÁC NHẬN]** sinh viên/nhóm mới | Bắt đầu ~T10/2026 (gối đầu 2 tháng sau WS2) |
| Capstone 4 | WS3 — Benchmark nghiên cứu (UWB/VIO/AprilTag) | **[CẦN XÁC NHẬN]** | Có thể là đề tài bài báo riêng |
| Capstone 5 | WS5 — Blackbox/Replay (khi đến giai đoạn) | **[CẦN XÁC NHẬN]** | Chưa cần chốt ngay, phụ thuộc dữ liệu thật từ Capstone 1–4 |

---

## 5. DANH SÁCH QUYẾT ĐỊNH CẦN CHỐT TRONG 4-6 TUẦN TỚI (ƯU TIÊN CAO NHẤT)

Đây là các quyết định **nghẽn cổ chai thật** — chậm trễ ở đây sẽ trễ toàn bộ chuỗi phía sau:

1. ~~Ground Truth system — overhead camera hay UWB reference riêng?~~ **✅ ĐÃ CHỐT (16/8/2026): Overhead Camera + AprilTag.**
2. **[MỚI]** **Khảo sát độ cao trần thực tế venue thi đấu** — quyết định số lượng/vị trí camera Ground Truth cuối cùng và có cần giải ngân Mục A4.7 (dự phòng giàn treo, 10 triệu) hay không.
3. **Nhân sự capstone** cho từng workstream — cần xác nhận trước khi giao đề tài chính thức.
4. **File mẫu Thuyết minh đề tài/kinh phí thật** — cần xin ngay từ phòng KH-CN để chạy agent đã chuẩn bị.
5. **Hạn mức kinh phí đề tài cơ sở** năm nay của TDTU — cần biết trước khi lập dự trù chi tiết.
6. **Đặt hàng linh kiện phần cứng** — deadline cứng đầu T10/2026 do lead time.
7. **Review hội đồng kỹ thuật độc lập** cho Rule draft v0.2 — cần lên lịch càng sớm càng tốt để kịp công bố Q1/2027.

---

## 6. RỦI RO TỔNG THỂ VÀ PHƯƠNG ÁN GIẢM THIỂU

| Rủi ro | Mức độ | Phương án giảm thiểu |
|---|---|---|
| Lead time linh kiện trễ → không kịp demo trước khi công bố rule | Cao | Đặt hàng chậm nhất đầu T10/2026 (đã đưa vào roadmap) |
| Nhân sự capstone không đủ/không kịp tuyển | Trung bình | Ưu tiên M1-M3 (không cần phần cứng) làm trước, tuyển dần |
| Hồ sơ đề tài cơ sở bị chậm duyệt | Trung bình | Nộp sớm nhất có thể (T9-T10/2026), không chờ CABP hoàn thiện mới nộp |
| Xung đột vai trò Technical Chair vs TDTU thiên vị | Thấp (đã giảm thiểu) | Không kiêm team leader, review công khai |
| Track Coordinated Ops không đủ đội đăng ký tham gia | Trung bình | Thiết kế tự nguyện + điểm thưởng, không bắt buộc — đã có trong luật |
| WS5 (Safety) không đủ thời gian trước Contest | Trung bình-Cao | Chấp nhận WS5 có thể chỉ đạt mức tối thiểu (collision replay cơ bản) cho Contest 2027; phần phân tích sâu (Guarantee-Anchored Contract) có thể hoàn thiện sau Contest, dùng dữ liệu thu được |

---

## GHI CHÚ

Tài liệu này là **bản đồ điều phối**, không thay thế các tài liệu kỹ thuật chi tiết đã có (CABP Technical Specification v0.2, CPAS Localization Technical Note v0.1, UAV Contest 2027 Full Rules Draft v0.2, Prompt điều phối agent Thuyết minh đề tài). Nên cập nhật định kỳ (đề xuất: hàng tháng) khi các quyết định ở Mục 5 được chốt.
