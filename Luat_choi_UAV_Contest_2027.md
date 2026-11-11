# LUẬT CHƠI UAV CONTEST 2027
### Kỷ niệm 30 năm thành lập Trường Đại học Tôn Đức Thắng
### Cyber-Physical Asset Systems Laboratory (CPAS Lab) — Khoa Điện – Điện tử

**Phiên bản:** Draft v0.1
**Ngày dự kiến thi đấu:** 24/9/2027
**Tài liệu nền:** CABP Technical Specification v0.2; CPAS Localization Technical Note v0.1

---

> ## GHI CHÚ PHẠM VI — ĐỌC TRƯỚC KHI ÁP DỤNG
>
> Luật chơi này là **draft kỹ thuật**, xây dựng trực tiếp trên hai tài liệu đặc tả đã có của CPAS Lab (CABP v0.2 và Localization Note v0.1). Các ngưỡng số cụ thể trong luật (khoảng cách an toàn, tần suất beacon, băng điểm chính xác…) là **điểm khởi đầu hợp lý, không phải giá trị cuối cùng** — đúng tinh thần mà hai tài liệu nguồn đã nêu rõ ở phần ghi chú cho người hướng dẫn. Các con số này cần được kiểm chứng bằng thực nghiệm (bench-test, mô phỏng, thử nghiệm hiện trường theo kế hoạch M1–M6) và được Hội đồng/Ban tổ chức (BOC) chính thức thông qua trước khi công bố luật chơi bản chính thức.
>
> Mọi trường hành chính chưa có thông tin xác nhận (địa điểm cụ thể, cơ cấu giải thưởng, thành phần Ban giám khảo, hạn đăng ký) được đánh dấu **[CẦN XÁC NHẬN]** và liệt kê lại ở Phụ lục C.
>
> **Track B — Coordinated Ops phụ thuộc hoàn toàn vào giao thức CABP còn đang trong giai đoạn nghiên cứu.** Luật chơi này có sẵn cơ chế dự phòng 3 cấp độ (Mục 14) cho trường hợp CABP gặp sự cố — từ lỗi cục bộ một đội, sự cố hạ tầng chung, đến kịch bản nghiêm trọng nhất là bản thân giao thức chưa đạt đủ độ trưởng thành trước ngày thi. Đề nghị đọc Mục 14 song song với các mục kỹ thuật khác, không chỉ xem như phụ lục.
>
> **Lưu ý về phạm vi giao thức:** CABP v0.2 hiện **chưa có** trường `confidence`/`uncertainty` (trường này được CABP Mục 10 ghi nhận là hướng mở rộng cho v0.3+, chưa đạt đủ 4 điều kiện Protocol Evolution Policy để đưa vào bây giờ). Vì vậy luật chơi 2027 **không** chấm điểm dựa trên confidence tự báo cáo của đội — mọi tiêu chí chấm điểm vị trí đều đối chiếu trực tiếp với Ground Truth khách quan (Mục 8). Dữ liệu Ground Truth thu được trong mùa giải sẽ được CPAS Lab dùng làm dữ liệu nghiên cứu hậu-giải cho hướng Guarantee-Anchored Contract, không phải một tiêu chí chấm điểm chính thức của mùa 2027.

---

## 1. GIỚI THIỆU VÀ MỤC TIÊU

UAV Contest 2027 là sân chơi thực nghiệm dành cho sinh viên/học viên cao học, tổ chức nhân dịp kỷ niệm 30 năm thành lập Trường Đại học Tôn Đức Thắng, với mục tiêu:

1. Tạo môi trường thi đấu thật để kiểm chứng các giao thức và hạ tầng do CPAS Lab phát triển (CABP, UWB Localization baseline) trong điều kiện gần với vận hành thực tế.
2. Khuyến khích các đội thi tự thiết kế, triển khai hệ thống định vị và phối hợp đa-UAV của riêng mình, thay vì cung cấp một nền tảng đóng gói sẵn.
3. Tạo ra dữ liệu thực nghiệm chuẩn hóa (nhiều đội, nhiều loại hardware) phục vụ nghiên cứu về sau tại CPAS Lab.

Cuộc thi gồm **hai track độc lập**, đội có thể đăng ký một hoặc cả hai:

- **Track A — Precision Delivery:** một UAV, chấm điểm theo độ chính xác giao hàng tại các điểm quy định.
- **Track B — Coordinated Ops:** nhiều UAV cùng đội, chấm điểm theo khả năng phối hợp an toàn dựa trên giao thức CABP.

---

## 2. ĐỐI TƯỢNG VÀ THỂ LỆ ĐĂNG KÝ

- Đối tượng: sinh viên đại học và học viên cao học đang theo học tại các cơ sở giáo dục đại học tại Việt Nam. [CẦN XÁC NHẬN: có mở rộng cho đội ngoài TDTU hay giới hạn nội bộ Trường]
- Quy mô đội: [CẦN XÁC NHẬN số lượng thành viên tối đa/tối thiểu mỗi đội]
- Số lượng UAV: Track A tối thiểu 1 UAV/đội; Track B tối thiểu 2 UAV/đội (để có ý nghĩa phối hợp).
- Hạn đăng ký, lệ phí (nếu có), và biểu mẫu đăng ký: [CẦN XÁC NHẬN]
- Mỗi đội được BOC cấp: một mã định danh đội (dùng cho trường `agent_id` của CABP, ví dụ đội 07 → `0x07xx`), một kênh Wi-Fi/SSID riêng cho khu vực thi đấu (theo Mục 5.2), và một khung giờ tập luyện/hiệu chỉnh thiết bị trước ngày thi chính thức.

---

## 3. CẤU TRÚC CUỘC THI

### 3.1 Track A — Precision Delivery

Một UAV của đội thực hiện nhiệm vụ bay từ điểm xuất phát (Depot), lần lượt đi qua và thả hàng (hoặc mô phỏng thả hàng) tại 5 điểm giao hàng quy định D1–D5 trong arena, rồi quay về Depot. Track này không yêu cầu giao thức CABP (không bắt buộc phối hợp đa-agent) nhưng **yêu cầu bắt buộc một hệ thống định vị tự chủ trên UAV** (Estimated Position), vì đây chính là cơ sở để đối chiếu độ chính xác với Ground Truth (Mục 8).

### 3.2 Track B — Coordinated Ops

Từ 2 UAV trở lên **của cùng một đội** hoạt động đồng thời trong arena, thực hiện nhiệm vụ đi qua các điểm quy định trong khi duy trì khoảng cách an toàn với nhau, sử dụng **giao thức CABP** (bắt buộc, xem Mục 5.2) để trao đổi trạng thái và tránh va chạm.

> **Lưu ý phạm vi quan trọng:** Track B ở mùa giải 2027 chỉ áp dụng phối hợp **nội bộ một đội**. Phối hợp liên-đội (UAV của đội A nhận biết UAV của đội B) **không nằm trong phạm vi mùa giải này** — đúng theo phạm vi đã xác định trong CABP v0.2 Mục 1.2, vì cơ chế xác thực định danh chống giả mạo giữa các đội khác nhau chưa được thiết kế. Nếu hai đội bay cùng lúc trong arena vì lý do lịch trình, BOC đảm bảo tách biệt không gian/thời gian bay giữa các đội để không phát sinh tình huống phối hợp liên-đội ngoài kế hoạch.

---

## 4. ĐẤU TRƯỜNG THI ĐẤU (ARENA)

- Kích thước arena tiêu chuẩn: **12 × 24 mét**, không gian trong nhà (indoor), có hệ Ground Truth độc lập lắp đặt sẵn (Mục 8).
- Vị trí Depot (điểm xuất phát/kết thúc) và 5 điểm giao hàng D1–D5: bố trí cố định, công bố cùng bản đồ arena chính thức trước ngày thi ít nhất [CẦN XÁC NHẬN số ngày] để đội chuẩn bị.
- Mỗi đội được cấp một kênh Wi-Fi/SSID riêng do BOC quản lý trong suốt thời gian thi đấu và tập luyện tại arena, nhằm hạn chế nhiễu băng tần 2.4/5GHz khi nhiều đội hoạt động song song (đúng khuyến nghị CABP Mục 5.1).
- Độ cao trần và giới hạn không gian bay an toàn: [CẦN XÁC NHẬN theo khảo sát thực tế địa điểm tổ chức]

---

## 5. YÊU CẦU KỸ THUẬT BẮT BUỘC

### 5.1 Yêu cầu chung cho UAV (áp dụng cả 2 track)

- UAV phải có flight controller độc lập với vòng điều khiển an toàn (không để logic beacon/định vị có quyền ghi trực tiếp lệnh động cơ) — đúng nguyên tắc Authority Monotonicity trong CABP Mục 6.2.
- UAV phải có cơ chế fail-safe khi mất tín hiệu điều khiển mặt đất, độc lập với cơ chế fail-safe của beacon.
- Kích thước, trọng lượng, loại UAV được phép: [CẦN XÁC NHẬN — tùy hạ tầng arena và quy định an toàn bay trong nhà của địa điểm tổ chức]

### 5.2 Yêu cầu giao thức CABP (bắt buộc riêng cho Track B)

Mọi UAV tham gia Track B phải phát bản tin trạng thái theo đúng schema CABP v0.2 (hoặc phiên bản chính thức tại thời điểm thi đấu), tối thiểu gồm các trường bắt buộc theo 4 nhóm Identity/Mission/State/Safety:

| Nhóm | Trường bắt buộc |
|---|---|
| Identity | `protocol_version`, `agent_id`, `seq_num` |
| Mission | `agent_state`, `intent` |
| State | `timestamp`, `position_x/y/z` |
| Safety | `battery_critical`, `health_flags`, `checksum/crc16` (bắt buộc với biến thể Production) |

Yêu cầu vận hành:
- **Tần suất phát tối thiểu: 5 Hz** (200ms/bản tin). Đội có thể đề xuất tần suất cao hơn nếu hạ tầng cho phép.
- **Biến thể dùng khi chấm điểm chính thức:** Production (binary), để đảm bảo băng thông ổn định khi nhiều UAV hoạt động song song; biến thể Debug (JSON) chỉ dùng cho giai đoạn tập luyện/gỡ lỗi.
- **Đồng bộ thời gian:** tất cả UAV của một đội đồng bộ đồng hồ tương đối tại thời điểm nhận tín hiệu "START" chung từ BOC qua kênh điều khiển mặt đất (đúng CABP Mục 4) — không yêu cầu NTP/PTP.
- **Ngưỡng Stale Beacon:** đội tự thiết kế và công bố ngưỡng của mình (khởi điểm đề xuất tham chiếu: 500ms cấp 1, 2 giây cấp 2 kích hoạt RTH), miễn là chứng minh được bằng demo trước trận đấu chính thức rằng hệ thống chuyển sang chế độ an toàn đúng thiết kế khi mất beacon.

### 5.3 Yêu cầu định vị (Localization)

- Track A và Track B đều yêu cầu UAV có hệ thống định vị tự chủ (Estimated Position) — đội tự lựa chọn công nghệ, nhưng khuyến nghị baseline là **UWB RTLS** (độ chính xác điển hình 10–30cm), đã được xác nhận khả thi trong Localization Note Mục 3.
- Vị trí tự ước lượng của đội **không được dùng trực tiếp làm cơ sở chấm điểm** — điểm số luôn đối chiếu với Ground Truth độc lập của BOC (Mục 8), đúng nguyên tắc bắt buộc trong Localization Note Mục 1.1.
- RTK GPS không được chấp nhận cho các nhiệm vụ trong nhà (không khả thi kỹ thuật, loại khỏi phạm vi theo Localization Note Mục 3).

---

## 6. QUY TRÌNH VẬN HÀNH MỘT TRẬN ĐẤU

### 6.1 Trước trận đấu

1. Đội lắp đặt UAV, kết nối vào kênh Wi-Fi riêng do BOC cấp.
2. BOC xác minh cấu hình `agent_id`, kiểm tra bản tin CABP hợp lệ qua Ground Logger (đối với Track B).
3. Đội xác nhận sẵn sàng; BOC phát tín hiệu "START" chung qua kênh điều khiển mặt đất để đồng bộ đồng hồ tương đối.

### 6.2 Trong trận đấu

- Track A: UAV bay từ Depot, lần lượt qua D1–D5 theo thứ tự [CẦN XÁC NHẬN: có bắt buộc thứ tự hay tự do] rồi về Depot trong thời gian giới hạn [CẦN XÁC NHẬN số phút].
- Track B: các UAV của đội thực hiện nhiệm vụ phối hợp trong thời lượng trận đấu **5 phút** (đúng thời lượng dùng làm cơ sở đo clock drift trong CABP Mục 4), duy trì khoảng cách an toàn theo Mục 7.

### 6.3 Sau trận đấu

- Ground Logger dừng ghi, xuất log thô (CSV/JSON-lines) theo timestamp của Ground Logger (không phải đồng hồ agent).
- BOC replay log để xác minh vi phạm khoảng cách an toàn và tính điểm chính thức (không chấm điểm chỉ dựa trên quan sát trực tiếp trong lúc thi đấu).

---

## 7. LUẬT TRÁNH VA CHẠM VÀ AN TOÀN (TRACK B)

Áp dụng đúng logic 2 cấp đã thiết kế trong CABP Mục 6.3:

**Cấp phản ứng (dựa trên vị trí Ground Truth, không phải vị trí tự báo cáo):**
- Khoảng cách giữa 2 UAV < **D_MIN = 1.0 m**: ghi nhận cảnh báo mức 1.
- Khoảng cách < **D_CRITICAL = 0.5 m**: ghi nhận vi phạm nghiêm trọng (xem xử phạt Mục 10).

**Cấp dự đoán (bonus, không bắt buộc):** đội chứng minh được hệ thống của mình sử dụng trường `intent` để cảnh báo sớm trước khi vi phạm D_MIN xảy ra (đối chiếu qua log replay) được xét điểm thưởng compliance (Mục 9.3).

**An toàn theo mặc định:** UAV mất beacon vượt ngưỡng đã công bố mà không chuyển sang hành vi an toàn đã thiết kế (giảm tốc/hover/RTH) trong vòng [CẦN XÁC NHẬN thời gian ân hạn cho phép] sẽ bị dừng trận đấu và tính là vi phạm an toàn.

---

## 8. HỆ THỐNG GROUND TRUTH VÀ GIÁM SÁT KHÁCH QUAN

- BOC vận hành một hệ thống đo vị trí độc lập hoàn toàn — cả vật lý lẫn tổ chức — với hệ định vị của từng đội thi (overhead camera + CV, hoặc lưới UWB reference riêng của BOC), không đội nào có quyền truy cập dữ liệu Ground Truth trong lúc thi đấu.
- Ground Truth không đi qua CABP và không phải là dữ liệu do đội tự báo cáo.
- Mọi tiêu chí chấm điểm liên quan đến vị trí đối chiếu bắt buộc với Ground Truth, không dựa trên Estimated Position tự báo cáo của đội — đây là nguyên tắc cứng, không có ngoại lệ.
- Toàn bộ chuỗi bản tin CABP thô và dữ liệu Ground Truth được BOC lưu trữ đầy đủ, cho phép replay và phúc tra sau trận đấu (Mục 11).

---

## 9. CÁCH TÍNH ĐIỂM (ĐỀ XUẤT KHỞI ĐIỂM — CẦN HỘI ĐỒNG THÔNG QUA)

### 9.1 Track A — Precision Delivery

Mỗi điểm giao hàng D1–D5 được chấm theo sai số vị trí thả hàng so với Ground Truth (không phải vị trí UAV tự báo cáo):

| Sai số so với Ground Truth | Điểm/điểm giao hàng (đề xuất) |
|---|---|
| ≤ 10 cm | 100% điểm |
| 10–30 cm | 60% điểm |
| 30–50 cm | 30% điểm |
| > 50 cm hoặc không thả hàng | 0 điểm |

Tổng điểm Track A = tổng điểm 5 điểm giao hàng + điểm thời gian hoàn thành (đề xuất: điểm thưởng nếu về đích trong X% thời gian giới hạn) − điểm phạt vi phạm (Mục 10).

### 9.2 Track B — Coordinated Ops

Điểm số gồm 2 thành phần chính:

- **Điểm nhiệm vụ:** hoàn thành các điểm kiểm tra/nhiệm vụ phối hợp theo kịch bản cụ thể của trận đấu — [CẦN XÁC NHẬN: kịch bản nhiệm vụ cụ thể của Track B].
- **Điểm an toàn/tuân thủ (Safety & Compliance):** điểm khởi đầu tối đa, trừ dần theo số lần vi phạm D_MIN/D_CRITICAL (Mục 7) và theo tỷ lệ mất gói/beacon không hợp lệ đo được qua Ground Logger.

### 9.3 Điểm thưởng an toàn (bonus)

Điểm thưởng riêng, cộng thêm ngoài điểm nhiệm vụ, dành cho đội chứng minh được (qua log replay, có phân tích kèm theo):
- Cấp dự đoán dựa trên `intent` thực sự làm giảm số lần vi phạm D_CRITICAL so với chỉ dùng cấp phản ứng.
- Tỷ lệ bản tin CABP hợp lệ (đúng checksum, đúng tần suất cam kết) đạt trên ngưỡng cao trong suốt trận đấu.

Đây chính là cơ sở chấm điểm bonus mà CABP Mục 7 đã dự kiến, dùng dữ liệu log để BOC chạy lại và phân tích sau trận đấu.

---

## 10. VI PHẠM VÀ XỬ LÝ

| Vi phạm | Mức xử lý (đề xuất) |
|---|---|
| Vi phạm D_MIN (Track B) | Trừ điểm nhẹ, cảnh cáo kỹ thuật |
| Vi phạm D_CRITICAL (Track B) | Trừ điểm nặng; vi phạm lặp lại trong cùng trận có thể dừng trận đấu |
| Mất beacon vượt ngưỡng mà không kích hoạt an toàn đúng thiết kế | Dừng trận đấu, tính là vi phạm an toàn |
| Sử dụng vị trí tự báo cáo để "gian lận" chấm điểm (không khớp Ground Truth trong phạm vi công nghệ đã khai báo) | Xem xét loại khỏi vòng thi hiện tại; BOC có quyền yêu cầu giải trình kỹ thuật |
| Module beacon có quyền ghi trực tiếp lệnh động cơ (vi phạm Authority Monotonicity) | Không đủ điều kiện dự thi Track B cho đến khi khắc phục |
| Vi phạm an toàn bay chung (rơi ngoài arena, mất kiểm soát) | [CẦN XÁC NHẬN theo quy định an toàn bay chung của địa điểm tổ chức] |

---

## 11. PHÂN XỬ TRANH CHẤP VÀ KHIẾU NẠI

- Mọi khiếu nại về điểm số phải dựa trên yêu cầu BOC replay lại log Ground Logger + Ground Truth của trận đấu liên quan, không dựa trên quan sát chủ quan.
- Thời hạn khiếu nại: [CẦN XÁC NHẬN, ví dụ trong vòng X giờ sau khi có kết quả]
- Hội đồng phân xử: [CẦN XÁC NHẬN thành phần — đề xuất gồm đại diện BOC, CPAS Lab, và ít nhất một thành viên độc lập không thuộc đội nào tham gia]

---

## 12. BAN TỔ CHỨC VÀ VAI TRÒ

| Vai trò | Trách nhiệm |
|---|---|
| Ban tổ chức (BOC) | Vận hành Ground Logger/Ground Truth, cấp phát kênh Wi-Fi, giám sát an toàn, xác nhận kết quả |
| Hội đồng giám khảo/phân xử | Thông qua luật chơi chính thức, xử lý khiếu nại, quyết định các trường hợp chưa có trong luật |
| CPAS Lab | Cung cấp đặc tả kỹ thuật nền (CABP, Localization), hỗ trợ kỹ thuật cho đội nếu cần, thu thập dữ liệu nghiên cứu sau mùa giải |
| Thành phần cụ thể (họ tên, đơn vị) | [CẦN XÁC NHẬN] |

---

## 13. LỊCH TRÌNH TỔNG THỂ (DỰ KIẾN)

| Mốc | Thời gian dự kiến |
|---|---|
| Công bố luật chơi bản chính thức | [CẦN XÁC NHẬN, đề xuất trước ngày thi đấu ≥ 3 tháng] |
| Hạn đăng ký đội thi | [CẦN XÁC NHẬN] |
| Đợt kiểm tra kỹ thuật/tập luyện tại arena (nếu có) | [CẦN XÁC NHẬN] |
| Ngày thi đấu chính thức | **24/9/2027** |
| Công bố kết quả & trao giải | [CẦN XÁC NHẬN] |

---

## 14. PHƯƠNG ÁN DỰ PHÒNG KHI CABP GẶP SỰ CỐ (CONTINGENCY PLAN)

Track B — Coordinated Ops phụ thuộc hoàn toàn vào giao thức CABP còn đang trong giai đoạn nghiên cứu/phát triển (kế hoạch M1–M6, hoàn tất dự kiến 06/2027, chỉ 3 tháng trước ngày thi 24/9/2027). Đây là một phụ thuộc có rủi ro thật, không phải rủi ro lý thuyết, nên luật chơi quy định rõ phương án dự phòng theo 3 cấp độ sự cố, thay vì để BOC phải ứng biến tại chỗ.

### 14.0 Nguyên tắc nền tảng — an toàn bay không phụ thuộc CABP

Trước khi đi vào từng cấp độ sự cố, cần khẳng định rõ một điểm nền tảng đã có sẵn trong thiết kế: theo yêu cầu bắt buộc ở Mục 5.1 (Authority Monotonicity) và cơ chế fail-safe độc lập của flight controller, **CABP chỉ là lớp advisory/monitoring, không có quyền ghi lệnh động cơ**. Vì vậy, "CABP thất bại" — dù ở cấp độ nào — **không đồng nghĩa với mất an toàn bay**; nó chỉ ảnh hưởng đến khả năng phối hợp/tránh va chạm chủ động và khả năng chấm điểm khách quan dựa trên log beacon. Toàn bộ phương án dự phòng dưới đây xử lý hệ quả về **tổ chức thi đấu và chấm điểm**, không phải hệ quả an toàn — an toàn bay vẫn do flight controller và quy định an toàn bay chung (Mục 10) đảm bảo trong mọi trường hợp.

### 14.1 Cấp độ 1 — Sự cố cục bộ của một đội trong một trận đấu

Áp dụng khi một đội bị lỗi CABP khi đang thi đấu (mất kết nối, checksum lỗi liên tục, packet loss vượt ngưỡng) nhưng lỗi không liên quan đến hạ tầng chung hay bản thân giao thức.

- UAV của đội tự động chuyển sang hành vi an toàn đã công bố (Mục 5.2 — giảm tốc/hover/RTH) khi vượt ngưỡng Stale Beacon; đây là hành vi bắt buộc, không phải tùy chọn.
- Trận đấu được tính là **kết thúc sớm tại thời điểm mất kết nối**; điểm số tính trên phần nhiệm vụ đã hoàn thành hợp lệ trước đó (đối chiếu Ground Truth), không loại toàn bộ kết quả trận, trừ khi lỗi được xác định là vi phạm cố ý (Mục 10).
- Đội được quyền yêu cầu **một (01) lần thi lại (re-run)** trong khung giờ thi đấu của mình nếu chứng minh được lỗi đến từ nguyên nhân khách quan ngoài tầm kiểm soát (ví dụ nhiễu đột biến từ thiết bị ngoài arena) — quyết định thuộc BOC, dựa trên log kỹ thuật, không dựa trên khiếu nại miệng.
- Đội có thể đăng ký thi đấu bằng biến thể Debug (JSON) thay cho Production nếu gặp lỗi triển khai binary sát ngày thi, nhưng **chịu điểm trừ compliance tương ứng** (Mục 9.3) vì đây không phải cấu hình chấm điểm chính thức.

### 14.2 Cấp độ 2 — Sự cố hạ tầng chung ảnh hưởng nhiều đội

Áp dụng khi nguyên nhân đến từ hạ tầng dùng chung tại arena (nhiễu Wi-Fi 2.4/5GHz do nhiều đội hoạt động đồng thời, sự cố Ground Logger, sự cố cấp điện khu vực…), không phải lỗi riêng của một đội.

- BOC có quyền tạm dừng toàn bộ lượt thi Track B đang diễn ra, chuyển sang **lịch thi so le** (mỗi đội thi một khung giờ riêng thay vì nhiều đội song song) nếu nhiễu băng tần là nguyên nhân — đúng khuyến nghị transport layer đã có trong CABP Mục 5.1.
- Nếu sự cố xuất phát từ băng tần Wi-Fi, đội đã chuẩn bị phương án dự phòng bằng ESP-NOW hoặc kênh khác (khuyến khích nhưng không bắt buộc khai báo trước) được ưu tiên tiếp tục thi đấu bằng phương án dự phòng đó, có ghi chú rõ trong biên bản trận đấu.
- Toàn bộ đội bị ảnh hưởng bởi sự cố cấp độ 2 được thi lại miễn phí, không tính vào lượt "01 lần thi lại" ở Mục 14.1 (vì lỗi không do đội gây ra).

### 14.3 Cấp độ 3 — CABP chưa đạt đủ độ trưởng thành trước ngày thi (kịch bản nghiêm trọng nhất)

Đây là kịch bản mà câu hỏi của Chủ nhiệm đề tài hướng tới: nếu đến gần ngày thi, bản thân giao thức CABP (ở tầm nghiên cứu, không phải lỗi của một đội cụ thể) chưa đạt độ ổn định cần thiết — ví dụ M4–M6 (mô phỏng, tích hợp bay thật, kiểm thử kịch bản thi đấu) không hoàn thành đúng hạn theo kế hoạch quản lý đề tài, hoặc số đội có hệ thống CABP hoạt động ổn định qua kiểm tra kỹ thuật quá thấp để tổ chức một track có ý nghĩa.

**Cơ chế Go/No-Go:**
- Mốc quyết định: **T–60 ngày trước ngày thi chính thức** (khoảng cuối tháng 7/2027), dựa trên kết quả Gate 3/Gate 4 đã định nghĩa trong Kế hoạch điều phối và quản lý thực hiện đề tài (Mục 8 của kế hoạch đó).
- Tiêu chí Go (Track B diễn ra như thiết kế): tối thiểu [CẦN XÁC NHẬN số đội tối thiểu, đề xuất tham khảo ≥3 đội] có hệ thống CABP vượt qua bài kiểm tra kỹ thuật bắt buộc trước ngày thi (Mục 6.1) với tỷ lệ bản tin hợp lệ và tuân thủ ngưỡng an toàn ở mức chấp nhận được.
- Người quyết định: CNĐT + Hội đồng giám khảo/phân xử (Mục 12), dựa trên báo cáo kỹ thuật của BOC và CPAS Lab, không phải quyết định đơn phương của một cá nhân.

**Nếu No-Go, áp dụng một trong các phương án sau (BOC công bố cụ thể chậm nhất T–45 ngày):**

| Phương án | Mô tả | Khi nào phù hợp |
|---|---|---|
| **A — Hạ cấp thành Exhibition/Demo** | Track B vẫn diễn ra nhưng **không tính vào bảng xếp hạng chính thức** của cuộc thi; kết quả chỉ mang tính trình diễn/thu thập dữ liệu nghiên cứu cho CPAS Lab | CABP hoạt động được nhưng chưa đủ ổn định để chấm điểm công bằng giữa các đội |
| **B — Hoãn Track B sang mùa giải sau** | Cuộc thi 2027 chỉ tổ chức chính thức Track A (Precision Delivery); Track B dời sang UAV Contest mùa kế tiếp | CABP chưa đạt mức tối thiểu để vận hành an toàn/ổn định ngay cả ở dạng demo |
| **C — Thu hẹp phạm vi Track B** | Track B vẫn tính điểm chính thức nhưng giảm yêu cầu (ví dụ: chỉ bắt buộc cấp phản ứng dựa trên `position`, bỏ yêu cầu cấp dự đoán dựa trên `intent`; giảm số UAV tối thiểu mỗi đội) | CABP core (Identity/Mission/State/Safety cơ bản) ổn định nhưng tính năng nâng cao (dự đoán va chạm) chưa kịp kiểm chứng |

Phương án cụ thể được chọn (A, B, hay C) do Hội đồng quyết định dựa trên báo cáo kỹ thuật thực tế tại thời điểm T–60 ngày, không cố định trước trong luật chơi này — vì mức độ trưởng thành của CABP tại thời điểm đó là điều chưa thể biết trước ở giai đoạn draft luật chơi.

### 14.4 Truyền thông quyết định

- Quyết định Go/No-Go và phương án dự phòng được chọn (nếu No-Go) phải công bố công khai cho toàn bộ đội đã đăng ký chậm nhất **T–45 ngày trước ngày thi**, kèm lý do kỹ thuật tóm tắt, để các đội có thời gian điều chỉnh kế hoạch chuẩn bị.
- Trường hợp Track B bị hoãn/hạ cấp, các đội đã đầu tư công sức phát triển hệ thống CABP vẫn được ghi nhận kết quả kỹ thuật (báo cáo/demo) như một hạng mục riêng, không để công sức của đội "biến mất" khỏi cuộc thi chỉ vì track bị điều chỉnh.

---

## PHỤ LỤC A — BẢNG THAM SỐ KỸ THUẬT THAM CHIẾU (từ CABP v0.2)

| Tham số | Giá trị khởi điểm | Ghi chú |
|---|---|---|
| Kích thước arena | 12 × 24 m | |
| Tần suất beacon tối thiểu | 5 Hz | Cần kiểm chứng lại theo tốc độ bay tối đa cho phép |
| D_MIN | 1.0 m | Cần thống nhất với luật chơi chính thức |
| D_CRITICAL | 0.5 m | |
| STALE_THRESHOLD cấp 1 | 500 ms | |
| STALE_THRESHOLD cấp 2 (kích hoạt RTH) | 2 giây | |
| Thời lượng trận đấu Track B | 5 phút | |
| Kích thước bản tin Production | ~26–38 byte | |

## PHỤ LỤC B — BẢNG THAM SỐ ĐỊNH VỊ THAM CHIẾU (từ Localization Note v0.1)

| Phương án | Độ chính xác điển hình | Vai trò trong luật chơi |
|---|---|---|
| UWB RTLS | 10–30 cm | Baseline khuyến nghị cho Estimated Position |
| Overhead Camera + CV | Vài cm (tùy hiệu chuẩn) | Ứng viên cho hệ Ground Truth của BOC |
| VIO/AprilTag | Tốt ngắn hạn, có drift | Bổ trợ, không dùng độc lập làm cơ sở chấm điểm |
| RTK GPS | 2–3 cm | Không áp dụng (không khả thi trong nhà) |

## PHỤ LỤC C — DANH SÁCH TOÀN BỘ PLACEHOLDER CẦN XÁC NHẬN

1. Phạm vi đối tượng tham gia (chỉ TDTU hay mở rộng liên trường)
2. Quy mô đội (số thành viên tối đa/tối thiểu)
3. Hạn đăng ký, lệ phí, biểu mẫu đăng ký
4. Kích thước/trọng lượng/loại UAV được phép, giới hạn không gian bay theo khảo sát địa điểm thực tế
5. Số ngày công bố bản đồ arena trước ngày thi
6. Thứ tự bắt buộc hay tự do khi qua các điểm D1–D5 (Track A), thời gian giới hạn mỗi trận
7. Kịch bản nhiệm vụ cụ thể của Track B
8. Thời gian ân hạn cho phép trước khi tính vi phạm mất beacon
9. Mức xử lý cho vi phạm an toàn bay chung (rơi ngoài arena, mất kiểm soát)
10. Thời hạn khiếu nại và thành phần Hội đồng phân xử
11. Thành phần cụ thể Ban tổ chức/Hội đồng giám khảo (họ tên, đơn vị)
12. Mốc thời gian cụ thể: công bố luật chính thức, hạn đăng ký, đợt tập luyện, công bố kết quả/trao giải
13. Cơ cấu giải thưởng (nếu có)
14. Số đội tối thiểu để Track B đạt tiêu chí "Go" tại mốc T–60 ngày (Mục 14.3, đề xuất khởi điểm ≥3 đội — cần Hội đồng thống nhất)
15. Hình thức ghi nhận kết quả kỹ thuật cho đội bị ảnh hưởng nếu Track B bị hoãn/hạ cấp (Mục 14.4)
