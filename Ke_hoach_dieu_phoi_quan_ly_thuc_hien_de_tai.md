# KẾ HOẠCH ĐIỀU PHỐI, QUẢN LÝ VÀ THỰC HIỆN ĐỀ TÀI

**Đề tài:** Nghiên cứu xây dựng giao thức truyền tải trạng thái và hạ tầng định vị cho phối hợp đa-agent tầm thấp: ứng dụng thử nghiệm trên UAV
**Chủ nhiệm đề tài:** TS. Trí Viễn Vũ
**Thời gian thực hiện:** 08 tháng (01/11/2026 – 30/06/2027)

> Tài liệu này là công cụ quản lý nội bộ của nhóm thực hiện đề tài, bổ trợ cho Thuyết minh đề tài (BM02) đã nộp — không phải một biểu mẫu hành chính của Trường, nên có thể điều chỉnh linh hoạt trong quá trình triển khai.

---

## 1. Mục tiêu của kế hoạch quản lý

Kế hoạch này nhằm trả lời bốn câu hỏi vận hành mà Thuyết minh đề tài không đi sâu: **ai** làm việc gì, **theo nhịp** nào, dùng **công cụ** gì để không bị trôi tiến độ hoặc phình phạm vi, và **rủi ro** nào cần theo dõi chủ động thay vì xử lý khi đã xảy ra.

---

## 2. Cơ cấu tổ chức & phân công vai trò

### 2.1 Sơ đồ trách nhiệm (đề xuất — Chủ nhiệm điều chỉnh theo năng lực thực tế từng thành viên)

| Vai trò | Người phụ trách | Trách nhiệm chính |
|---|---|---|
| **Chủ nhiệm đề tài (CNĐT)** | TS. Trí Viễn Vũ | Định hướng kỹ thuật tổng thể; quyết định cuối cùng khi có xung đột phạm vi (áp dụng Protocol Evolution Policy, Mục 6); phê duyệt báo cáo/milestone; làm việc với Phòng QLKH và BOC UAV Contest |
| **Thư ký khoa học (TK)** | TS. Trần Đức Anh Minh | Điều phối tiến độ hằng tuần; tổng hợp báo cáo milestone; theo dõi ngân sách so với kế hoạch; là đầu mối kỹ thuật thứ hai khi CNĐT vắng mặt |
| **Track A — CABP Protocol (Communication)** | 01 HVCH (đề xuất: Nguyễn Anh Dũng) | M1–M3: schema/serialization, bench-test, time sync & stale detection (xem BM02 Mục 3.5) |
| **Track B — Localization** | 01 HVCH (đề xuất: Lê Tấn Phước) | UWB RTLS baseline, Ground Truth system, benchmark định vị sơ bộ |
| **Track C — Collision logic & tích hợp** | 01 HVCH (đề xuất: Lý Võ Đông Giang) | M4–M6: mô phỏng collision logic, tích hợp lên UAV thật, kiểm thử kịch bản thi đấu |
| **Hỗ trợ kỹ thuật Track A/B** | 02 SV (Nguyễn Ngọc Thiện, Trần Hoàng Linh) | Phân công theo nhu cầu thực tế mỗi giai đoạn — ví dụ: 1 SV hỗ trợ ghi log/bench-test, 1 SV hỗ trợ dựng Ground Truth/CV |

*Phân công theo Track ở trên là đề xuất kỹ thuật dựa trên cấu trúc milestone đã có trong BM02; CNĐT nên xác nhận lại dựa trên thế mạnh thực tế của từng HVCH/SV trước buổi họp khởi động (kickoff).*

### 2.2 Nguyên tắc phân quyền quyết định

Áp dụng đúng tinh thần **Authority Monotonicity** đã dùng trong thiết kế CABP — áp cho cả tổ chức, không chỉ kỹ thuật: mỗi Track Lead có quyền quyết định trong phạm vi kỹ thuật của track mình; bất kỳ thay đổi nào ảnh hưởng đến schema chung, ngưỡng an toàn dùng chung (D_MIN, STALE_THRESHOLD), hoặc phạm vi phiên bản (thêm field mới) đều phải qua CNĐT/TK duyệt theo Protocol Evolution Policy trước khi merge vào nhánh chính.

---

## 3. Nhịp báo cáo & họp

| Loại họp | Tần suất | Thành phần | Nội dung |
|---|---|---|---|
| **Sync kỹ thuật** | Hằng tuần (30–45 phút) | Toàn nhóm | Mỗi Track báo cáo tiến độ/vướng mắc; không giải quyết chi tiết kỹ thuật sâu trong cuộc họp này (đẩy sang kênh chat/issue) |
| **Rà soát milestone** | Khi kết thúc mỗi milestone (M1–M6, xem lịch BM02 Mục 3.5) | CNĐT, TK, Track Lead liên quan | Đối chiếu "Kết quả cần đạt" đã cam kết trong BM02 với thực tế; quyết định go/no-go sang milestone tiếp theo |
| **Steering review** | Hằng tháng | CNĐT + TK | Đối chiếu tiến độ tổng thể với lộ trình 8 tháng; rà soát ngân sách đã chi so với dự toán BM03; áp Protocol Evolution Policy nếu có đề xuất mở rộng phạm vi |
| **Báo cáo với Trường** | Theo quy định của Phòng QLKH TDTU (giữa kỳ/cuối kỳ) | CNĐT | [CẦN XÁC NHẬN mốc báo cáo cụ thể theo quy định hiện hành của Phòng QLKH — chưa có trong tài liệu nguồn] |

---

## 4. Công cụ và quy trình làm việc

- **Quản lý mã nguồn:** một repository Git dùng chung cho thư viện `cpas_beacon` (Python + C++), với nhánh chính (`main`) được bảo vệ — mọi thay đổi vào schema chung phải qua pull request có ít nhất một reviewer khác track duyệt.
- **Theo dõi công việc:** bảng kanban (GitHub Projects hoặc tương đương) với cột theo milestone M1–M6, để cả nhóm nhìn thấy trạng thái mà không cần hỏi trực tiếp.
- **Lưu trữ dữ liệu thực nghiệm:** dữ liệu bench-test, log Ground Logger, và log Ground Truth lưu trên một thư mục dùng chung (Google Drive/NAS lab), có quy ước đặt tên theo ngày + milestone để phục vụ replay và viết báo cáo benchmark.
- **Báo cáo tuần:** mẫu ngắn (Việc đã làm / Việc đang vướng / Việc tuần tới), gửi trước sync kỹ thuật hằng tuần, giúp cuộc họp ngắn gọn và có hồ sơ theo dõi tiến độ cho báo cáo giữa kỳ.

---

## 5. Cơ chế kiểm soát phạm vi (Scope Control)

Áp dụng nguyên văn Protocol Evolution Policy đã thống nhất trong CABP Technical Specification cho **toàn bộ đề tài**, không chỉ riêng giao thức: bất kỳ đề xuất mở rộng nào (thêm tính năng, thêm thiết bị, thêm mục tiêu con) trong quá trình triển khai đều phải trả lời được bốn câu hỏi trước khi CNĐT phê duyệt:

1. **Necessary** — có thật sự cần để hoàn thành mục tiêu đã cam kết trong BM02, hay chỉ "có thể hữu ích sau này"?
2. **Measurable** — có đo được kết quả bằng thí nghiệm cụ thể trong thời gian còn lại không?
3. **Testable** — có viết được test case xác nhận đúng/sai không?
4. **Implementable** — nhóm hiện tại có làm được trong quỹ thời gian còn lại của 8 tháng không?

Nếu không đạt đủ 4 điều kiện, đề xuất được ghi nhận vào mục "Hướng mở rộng" của báo cáo cuối kỳ thay vì đưa vào phạm vi hiện tại — đúng cách CABP Mục 10 đã xử lý các field bị hoãn.

---

## 6. Quản lý rủi ro

| Rủi ro | Khả năng xảy ra | Tác động | Biện pháp phòng ngừa/ứng phó |
|---|---|---|---|
| Chậm trễ mua sắm thiết bị (UWB, companion computer) do quy trình phê duyệt kinh phí của Trường | Trung bình–Cao | Trễ M2–M3 | Gửi yêu cầu báo giá và đề xuất mua sắm ngay sau khi đề tài được phê duyệt, không đợi đến sát mốc M2 |
| Nhiễu Wi-Fi khi nhiều đội test song song trong arena (M6) | Trung bình | Sai lệch đo latency/loss, ảnh hưởng benchmark | Đặt lịch test độc lập với BOC trước khi vào giai đoạn thi đấu chính thức; có phương án ESP-NOW dự phòng |
| Độ trôi đồng hồ (clock drift) giữa companion computer vượt ngưỡng chấp nhận được | Thấp–Trung bình | Sai lệch logic tránh va chạm dựa trên `intent`/T_PREDICT | Đo thực nghiệm sớm ở M3 (đúng như đã thiết kế); có phương án fallback dùng tín hiệu START chung nếu NTP không khả thi |
| Thành viên HVCH/SV có ràng buộc thời gian khác (học phần, thi cử) làm chậm track phụ trách | Trung bình | Trễ milestone liên quan | Rà soát lịch học của từng thành viên ngay từ họp khởi động; phân bổ track dự phòng (cross-training tối thiểu giữa Track A và B) |
| Arena thi đấu chưa sẵn sàng/chưa cấp phép test trước M6 | Trung bình | Không đủ dữ liệu thực nghiệm hiện trường thật | Làm việc sớm với Ban tổ chức UAV Contest 2027 để đặt lịch test thử nghiệm hiện trường trước mốc chính thức |
| Phạm vi bị phình to ngoài kế hoạch (scope creep) | Trung bình | Không hoàn thành đúng hạn 8 tháng | Áp dụng cơ chế kiểm soát phạm vi ở Mục 5 cho mọi đề xuất mở rộng |

---

## 7. Quản lý dữ liệu & tài liệu

- Toàn bộ log bản tin CABP thô (không chỉ tóm tắt) và log Ground Truth độc lập được lưu trữ tách biệt theo đúng nguyên tắc phân tách hai hệ quy chiếu (Agent vs. Ground System) đã nêu trong Localization Note Mục 1 — tránh để dữ liệu ước lượng và dữ liệu đối chiếu lẫn lộn trong cùng một kho, gây khó khăn khi kiểm chứng độc lập.
- Mỗi milestone kết thúc kèm một báo cáo ngắn (theo mẫu Mục 3 ở trên) được lưu vào thư mục dùng chung, làm cơ sở tổng hợp báo cáo giữa kỳ/cuối kỳ nộp Trường.

---

## 8. Mốc kiểm tra tổng thể (gắn với lịch BM02 Mục 3.5)

| Giai đoạn | Cổng kiểm tra (gate) | Điều kiện qua cổng |
|---|---|---|
| Sau M1–M2 (12/2026 – 01/2027) | Gate 1 | Thư viện `cpas_beacon` chạy được cả 2 biến thể, có test coverage; báo cáo latency/loss đã có số liệu thực đo |
| Sau M3 (02/2027) | Gate 2 | Demo chuyển safety mode đúng ngưỡng thiết kế; số liệu clock drift đã đo được |
| Sau M4–M5 (04/2027 – 05/2027) | Gate 3 | Demo mô phỏng + video bay thật trên 2 UAV, log thực tế đầy đủ |
| Sau M6 (06/2027) | Gate 4 (nghiệm thu nội bộ) | Báo cáo benchmark định vị sơ bộ hoàn chỉnh; báo cáo tổng kết đề tài sẵn sàng nộp Trường |

Nếu một track không qua được gate đúng hạn, Steering review (Mục 3) là nơi quyết định: gia hạn nội bộ trong quỹ thời gian còn lại, điều chuyển nhân lực giữa các track, hoặc thu hẹp phạm vi theo đúng cơ chế Mục 5 — không để việc trễ một track kéo lùi toàn bộ đề tài mà không có quyết định rõ ràng.

---

## Placeholder cần Chủ nhiệm đề tài xác nhận

- Mốc báo cáo giữa kỳ/cuối kỳ cụ thể theo quy định hiện hành của Phòng Quản lý Khoa học TDTU (Mục 3).
- Phân công Track cụ thể cho từng HVCH dựa trên thế mạnh thực tế (Mục 2.1 chỉ là đề xuất).
- Đầu mối liên hệ và lịch làm việc với Ban tổ chức UAV Contest 2027 để đặt lịch test hiện trường sớm (Mục 6).
