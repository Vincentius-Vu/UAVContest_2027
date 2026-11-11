# COMPETITION RULES — UAV CONTEST 2027 (DRAFT ĐẦY ĐỦ v0.2)
### The 4th International Competition on Research and Design of Unmanned Aerial Vehicles
### Kỷ niệm 30 năm thành lập Trường Đại học Tôn Đức Thắng — dự kiến quanh mốc 24/9/2027

**Trạng thái:** Draft kỹ thuật đầy đủ, kế thừa cấu trúc và phần lớn thông số kỹ thuật đã kiểm chứng từ Luật UAV Contest 2026 (lần 3), đổi bối cảnh và bổ sung track Coordinated Ops/CABP theo đề xuất đã thống nhất.
**Nguồn kế thừa:** Competition Rules — UAV Contest 2026 (cập nhật 27/2/2026), phần "giữ nguyên cấu trúc" được đánh dấu rõ; phần thay đổi/mới được đánh dấu **[MỚI]** hoặc **[ĐỔI TÊN]**.
**Ngày soạn:** 25/7/2026

---

## GHI CHÚ VỀ PHƯƠNG PHÁP KẾ THỪA

Tài liệu này áp dụng nguyên tắc đã thống nhất: **đổi narrative, không đổi mission skeleton**. Toàn bộ kích thước arena, giá trị vật lý (đường kính, độ cao, trọng lượng, tốc độ), cấu trúc chấm điểm, và khung an toàn được giữ nguyên từ luật lần 3 — chỉ đổi tên gọi ngữ nghĩa (Victim → Package, Fire Zone → Delivery Point...) và bổ sung các mục hoàn toàn mới (Coordinated Ops, CABP). Mọi con số **[CẦN REVIEW]** là chỗ cần hội đồng kỹ thuật xác nhận trước khi công bố chính thức — không phải sai sót, mà là placeholder có chủ đích theo đúng tinh thần "chốt kiến trúc trước, chốt số liệu sau" đã áp dụng xuyên suốt.

---

## CONTENTS

I. PURPOSE AND CONTEXT
II. COMPETITION OBJECTIVES
III. UAV TECHNICAL SPECIFICATIONS
IV. ARENA SPECIFICATIONS
V. MISSION REQUIREMENTS
VI. SCORING CRITERIA
VII. PENALTIES AND VIOLATIONS
VIII. SAFETY REGULATIONS
IX. APPEALS AND DISPUTE RESOLUTION
X. TEAM RESPONSIBILITIES
XI. MATCH DURATION AND TIMING
XII. DETAILED ARENA TECHNICAL SPECIFICATIONS
XIII. **[MỚI]** CPAS AGENT BEACON PROTOCOL (CABP) — COORDINATED OPS TRACK
XIV. **[MỚI]** IMPLEMENTATION TIMELINE

---

## I. PURPOSE AND CONTEXT — **[ĐỔI BỐI CẢNH]**

Nền kinh tế tầm thấp (low-altitude economy) và logistics tự hành đang trở thành một trụ cột hạ tầng số được xác định trong định hướng phát triển khoa học công nghệ quốc gia (Nghị quyết 57-NQ/TW). Khác với kịch bản ứng phó khẩn cấp đơn-agent của các lần thi trước, hạ tầng logistics tầm thấp vận hành trên nguyên tắc căn bản khác: nhiều tác nhân (UAV, robot mặt đất, trạm trung chuyển) chia sẻ cùng một không gian vật lý và phải phối hợp an toàn mà không cần một bộ điều khiển trung tâm duy nhất.

The Autonomous Logistics UAV Competition mô phỏng một Trung tâm phân phối hàng hóa tự động tầm thấp (Autonomous Logistics Hub), yêu cầu UAV thực hiện các nhiệm vụ lấy hàng, vận chuyển, và giao hàng chính xác — kể cả cho một đầu nhận hàng đang di chuyển — với độ tự chủ tăng dần qua các vòng thi.

## II. COMPETITION OBJECTIVES — **[ĐỔI BỐI CẢNH, GIỮ CẤU TRÚC]**

- **Practical Application:** Phát triển và tối ưu hóa việc triển khai UAV cho vận hành logistics tầm thấp, lấy hàng, và giao hàng chính xác trong môi trường mô phỏng thực tế.
- **Innovation and Creativity:** Thúc đẩy tinh thần đổi mới trong thiết kế cơ khí, tích hợp hệ thống, và lập trình điều khiển bay nâng cao.
- **Performance Evaluation:** Đánh giá toàn diện cả kỹ năng điều khiển thủ công và vận hành tự động (AI/Computer Vision), và — lần đầu tiên — năng lực phối hợp đa-agent trong không gian chia sẻ (track Coordinated Ops).

## III. UAV TECHNICAL SPECIFICATIONS

### 1. Configuration — **[GIỮ NGUYÊN]**
- Maximum Dimensions: 1.0 × 1.0 × 1.0 meters (inclusive of propellers and propeller guards).
- Maximum Takeoff Weight (MTOW): ≤ 5.0 kg (including batteries and all onboard mission equipment).
- Power System: Battery Type LiPo/Li-ion, tối đa cấu hình 6S; ≤ 3 battery packs; Total Energy Capacity ≤ 300 Wh.
- **[ĐỔI TÊN] Payload Capacity:** UAV được phép mang tối đa năm (05) kiện hàng mô phỏng khi cất cánh (thay thế "tennis balls" của luật lần 3 — xem Mục XII về việc giữ nguyên hay đổi vật lý mô phỏng).
- System Integrity: Mọi hệ thống điện/cơ khí phải đảm bảo tiêu chuẩn an toàn cao, không rò rỉ điện, đoản mạch, hay nguy cơ cháy nổ.

### 2. Safety Requirements — **[GIỮ NGUYÊN 100%]**
- Propeller Guards bắt buộc.
- Manual Override: chế độ điều khiển thủ công khẩn cấp có thể kích hoạt ngay lập tức.
- Fail-safe Features: Return-to-Home (RTH) hoặc hạ cánh khẩn cấp tự động khi mất tín hiệu, lỗi điều khiển, hoặc pin yếu.
- Status Indicators: đèn LED trạng thái (khuyến khích).
- Personnel Safety: thiết kế vật lý không gây nguy hiểm cho người vận hành/trọng tài.
- Non-ionizing Radiation (Laser Safety): tuân thủ IEC 60825-1, tối đa Class 2 (2M).
- Ionizing Radiation: cấm hoàn toàn.

### 3. Control Systems — **[ĐỔI TÊN PHA, GIỮ NGUYÊN LOGIC, BỔ SUNG YÊU CẦU CABP]**
- **Phase 1 (Pickup — Lấy hàng):** Điều khiển thủ công hoặc bán tự động.
- **Phase 2 (Delivery — Giao hàng):** Bay tự động hoàn toàn theo waypoint. Không can thiệp thủ công trừ tình huống khẩn cấp.
- **[MỚI] Track Coordinated Ops:** cả 2 UAV của đội phải duy trì phát CPAS Agent Beacon Protocol (CABP) liên tục trong suốt thời gian bay (xem Mục XIII), không phân biệt Phase 1 hay Phase 2.

**RADIO COMMUNICATION AND SIMILAR EQUIPMENT — [GIỮ NGUYÊN 100%, QUAN TRỌNG]**
- Regulatory Compliance: mọi thiết bị truyền phát vô tuyến, định vị vô tuyến, radar phải tuân thủ Luật Tần số Vô tuyến điện và quy định pháp luật hiện hành của Việt Nam.
- Prohibited Placement: cấm đặt thiết bị định vị vô tuyến (anchor định vị, beacon tín hiệu) trực tiếp trên bề mặt thi đấu (Playfield).
- Installation Responsibility: đội tự chịu trách nhiệm lắp đặt thiết bị trong khu vực Perimeter (quanh playfield), đảm bảo an toàn tuyệt đối, không cản trở đội khác/trọng tài.
- Standalone Radar Prohibition: cấm hệ thống radar mặt đất hoạt động như cảm biến độc lập (tự phát/thu/xử lý dữ liệu quét môi trường tại chỗ). **Positioning systems utilizing external anchors (such as UWB RTLS) located outside the playfield remain permitted for use** — đây là cơ sở pháp lý trực tiếp cho phương án định vị UWB RTLS đã đề xuất trong CPAS Localization Technical Note.
- Signal Disclaimer: BOC không chịu trách nhiệm và không đảm bảo chất lượng tín hiệu tại địa điểm thi đấu; đội cần có phương án dự phòng.

### 4. Package Handling Mechanisms — **[ĐỔI TÊN, GIỮ NGUYÊN THÔNG SỐ KỸ THUẬT]**
- **Pickup (Gripping) Mechanism:** không được gây hư hại cấu trúc mô hình kiện hàng lớn; lực nâng tối thiểu ≥ 300g; phải có khóa an toàn chống rơi ngoài ý muốn khi di chuyển.
- **Package Drop (Dispensing) System:** thả từng kiện hàng chính xác, tránh rơi tự do ngoài ý muốn; sức chứa 05 kiện hàng khi cất cánh; điểm thấp nhất của UAV khi thả phải duy trì độ cao tối thiểu ≥ 3.0 mét so với sàn arena.

### 5. Competition Materials — **[ĐỔI TÊN, GIỮ NGUYÊN VẬT LÝ — XEM MỤC XII]**
- Kiện hàng mô phỏng nhỏ (Package Simulants): giao vào các Delivery Point D1–D5.
- Mô hình kiện hàng lớn (Package Models): khối cứng 0.3m, trọng lượng 300g, có tay cầm/móc tích hợp để gắp.

## IV. ARENA SPECIFICATIONS — **[GIỮ NGUYÊN KÍCH THƯỚC, ĐỔI TÊN NGỮ NGHĨA]**

- Overall Dimensions: 12.0 × 24.0 meters.
- **Depot (Safe Zone):** 12.0 × 3.5 meters.
- **Air Corridor Checkpoints (Transition Gates, ACC1–ACC4):** Inner Diameter 1.6m; Center Height 1.7m; Total Structure Height 2.6m.
- **Delivery Points (Fire Zones, D1–D5):** vị trí 0.1m trên sàn arena; hệ thống cảm biến tích hợp tự động ghi điểm khi kiện hàng thả thành công.
- **Pickup Area (Victim Rescue Area):** 12.0 × 4.5 meters.
- **Pickup Stations (Victim Platforms, P1–P3):** kích thước 1.0 × 1.0m; độ cao 1.0m so với sàn arena.
- **Operational Altitude Limits [GIỮ NGUYÊN]:** Manual Flight ≤ 5.0m; Autonomous Flight 3.0–5.0m.
- **[MỚI, CHỈ FINAL ROUND] Mobile Receiver:** thay thế bệ F2 di chuyển của luật lần 3 — cùng cơ chế vật lý (di chuyển tuyến tính 10 cm/s dọc theo đường dẫn cố định trên sàn), đổi hình thức thể hiện thành mô hình robot/AGV mini.

*(Sơ đồ arena — Figure 1 — kế thừa trực tiếp layout hình học của luật lần 3, chỉ đổi nhãn: Safe Zone→Depot, TZ1-4→ACC1-4, V1-3→P1-3, F1-5→D1-5.)*

## V. MISSION REQUIREMENTS

### A. PRELIMINARY ROUND (QUALIFYING PHASE)

**PHASE 1: PICKUP (Manual or Semi-autonomous Control) — [GIỮ NGUYÊN CẤU TRÚC]**

1. **Takeoff and Approach:** UAV xuất phát từ vị trí đỗ trong Depot. Khi có tín hiệu trọng tài, UAV cất cánh và phải bay qua tâm của Air Corridor Checkpoint ACC1 và ACC2 — toàn bộ khung UAV phải đi qua hoàn toàn mặt phẳng khung cổng để được công nhận vượt chướng ngại vật thành công.
2. **Pickup Execution:** UAV tiếp cận khu vực và dùng cơ cấu nhiệm vụ (gripper, nam châm điện, hút chân không...) để lấy mô hình kiện hàng lớn từ một trong ba vị trí P1, P2, P3. Chỉ được lấy một (01) kiện hàng mỗi lượt bay.
3. **Transport and Return:** UAV vận chuyển kiện hàng về Depot, phải bay qua tâm ACC3 và ACC4 khi quay về trong khi vẫn giữ chắc kiện hàng. Kiện hàng phải được đặt vào Depot; chỉ sau khi giao thành công UAV mới được quay lại lấy kiện tiếp theo.
4. **Landing:** UAV kết thúc pha bằng cách hạ cánh có kiểm soát tại bệ đáp quy định.

**PHASE 2: DELIVERY (Autonomous Flight) — [GIỮ NGUYÊN CẤU TRÚC]**

- **Mission 1 — Autonomous Takeoff:** UAV đặt tại tâm khu vực cất cánh; khi có tín hiệu, đội kích hoạt chế độ bay tự động; UAV phải đạt độ cao an toàn tối thiểu (>3.0m) không cần can thiệp thủ công.
- **Mission 2 — Package Delivery:** UAV điều hướng đến tọa độ D1–D5 và thả kiện hàng mô phỏng vào đúng vòng tròn mục tiêu. Mỗi điểm D1–D5 chỉ được tính điểm một (01) lần khi kiện hàng đáp trúng vòng tròn; đội tự quyết định thứ tự giao hàng; ở vòng loại, tọa độ D1–D5 cố định theo layout đã cung cấp.
- **Mission 3 — Autonomous Return and Precision Landing:** Sau khi hoàn thành/hết kiện hàng, UAV tự tính đường bay quay về Depot và hạ cánh chính xác tại vị trí cất cánh ban đầu. Đồng hồ chính thức dừng khi UAV đã hạ cánh an toàn và động cơ tắt hoàn toàn.

### B. SEMI-FINAL ROUND — **[GIỮ NGUYÊN]**
Yêu cầu linh hoạt thuật toán tăng đáng kể — UAV không còn dựa vào tọa độ lập trình sẵn mà phải "nhận thức" môi trường bằng Computer Vision (CV).
- Phase 1 — Pickup: giữ nguyên như vòng loại.
- Phase 2 — Delivery: vị trí D1–D5 không còn cố định; BOC bốc thăm ngẫu nhiên tọa độ từ ma trận vị trí trước mỗi trận.

### C. FINAL ROUND — **[GIỮ NGUYÊN, ĐỔI NGỮ NGHĨA MỤC TIÊU ĐỘNG]**
Thách thức cao nhất về lập trình điều khiển bay và Computer Vision thời gian thực.
- Phase 1 — Pickup: giữ nguyên như vòng loại.
- Phase 2 — Delivery: tọa độ D1–D5 bốc thăm ngẫu nhiên ngay trước trận. **D2 được gắn trên Mobile Receiver**, di chuyển với tốc độ không đổi 10 cm/s theo quỹ đạo tuyến tính (tới-lui) dọc theo đường dẫn màu cam trên sàn arena — đội thi phải giao hàng chính xác cho một "phương tiện đang di chuyển", đúng bài toán rendezvous thật của logistics tầm thấp.

### D. **[MỚI, SỬA LẠI 16/8/2026]** TRACK TỰ NGUYỆN: COORDINATED OPS — CƠ CHẾ "ĐẶT HÀNG — CHUYỂN TIẾP — LẤY HÀNG"

Áp dụng cho đội đăng ký vận hành 2 UAV: **UAV-A (điều khiển tay/bán tự động)** và **UAV-B (tự động hoàn toàn)**. Đây không phải hai nhiệm vụ song song độc lập (thiết kế cũ) mà là **một chuỗi nhiệm vụ nối tiếp có ràng buộc thời gian**, mô phỏng đúng bài toán logistics relay thật.

**Nguyên tắc thiết kế bắt buộc:** toàn bộ chuỗi phải chạy được kể cả khi CABP thất bại — CABP chỉ mang lại lợi thế tốc độ, không phải điều kiện để hoàn thành nhiệm vụ. Đây là ứng dụng trực tiếp nguyên tắc Authority Monotonicity đã có trong CABP.

**Thiết lập trước trận:**
- BOC bốc thăm ngẫu nhiên xác định **tập vị trí ứng viên hợp lệ** cho trận này (một tập con của D1–D5) — **[CẦN REVIEW]** đề xuất 3/5 điểm để có biến thiên nhưng không quá rộng.
- UAV-B phải được nạp mã nhiệm vụ **trước** khi biết kết quả bốc thăm — chỉ biết "kiện hàng sẽ ở một trong các D thuộc tập ứng viên", không biết trước điểm cụ thể. Đội nộp checksum mã nguồn/firmware cho BOC trước giờ bốc thăm để đối chiếu sau trận — **[CẦN REVIEW]** quy trình xác minh cụ thể.
- Mỗi điểm D được gắn thêm một **mã QR** (bổ sung, không thay thế vòng tròn màu D1–D5 đã chuẩn hóa cho CV) — mã hóa ID vị trí, dùng riêng cho UAV-B xác nhận vị trí độc lập với CABP. Đây là hệ tách biệt hoàn toàn với AprilTag của Ground Truth camera (BOC dùng để giám sát/chấm điểm) — không dùng chung.

**Giai đoạn 1 — Đặt hàng (UAV-A), cửa sổ thời gian T1 [CẦN REVIEW: đề xuất 90 giây]:**
Phi công điều khiển UAV-A cất cánh, mang 1 kiện hàng, tự chọn và đặt chính xác tại MỘT trong các điểm D thuộc tập ứng viên. Đặt hàng phải hoàn thành trong T1 — quá thời hạn, nhiệm vụ phối hợp của trận tính thất bại (0 điểm phần Coordinated Ops, track chuẩn của đội không bị ảnh hưởng).
- **[Tùy chọn]** Ngay sau khi đặt hàng thành công, UAV-A phát bản tin CABP `mission_event` (Mục XIII.4, mới) báo vị trí đã dùng cho UAV-B.

**Giai đoạn 2 — Lấy hàng (UAV-B), cửa sổ thời gian T2 [CẦN REVIEW: đề xuất 120 giây], tính từ khi Giai đoạn 1 hoàn thành:**
- **Đường Cơ bản (mặc định, luôn khả dụng):** UAV-B tự hành trình quét tuần tự các điểm ứng viên theo thứ tự đã lập trình sẵn từ trước, dùng CV đọc QR + xác nhận sự hiện diện vật lý kiện hàng, rồi gắp và mang về Depot.
- **Đường Bonus (nếu CABP thành công):** nếu UAV-B nhận `mission_event` hợp lệ trong ngưỡng chờ timeout **[CẦN REVIEW: đề xuất 3 giây]** kể từ khi Giai đoạn 1 hoàn thành, bỏ qua bước quét, bay thẳng đến đúng điểm.
- **Fallback tự động, không cần can thiệp:** hết timeout không nhận được bản tin hợp lệ → UAV-B tự chuyển sang Đường Cơ bản, không có bước nào yêu cầu con người can thiệp giữa chừng.

**Tổng thời gian trận cho track này:** **[CẦN REVIEW]** có thể cần kéo dài hơn 5 phút chuẩn (do 2 giai đoạn nối tiếp) — đề xuất 7 phút, cần thống nhất với Mục XI.

Đội không đăng ký track này thi đấu hoàn toàn bình thường theo format 1-UAV, không bị thiệt điểm.

## VI. SCORING CRITERIA

### A. PRELIMINARY AND SEMI-FINAL ROUNDS — **[GIỮ NGUYÊN GIÁ TRỊ ĐIỂM, ĐỔI TÊN]**

| Category | Mission Details | Scoring Criteria | Maximum Score |
|---|---|---|---|
| Phase 1: Pickup | Vượt qua Air Corridor Checkpoints | 5 điểm/cổng (ACC1–ACC4) | 60 |
| | Lấy và giao kiện hàng thành công về Depot | 20 điểm/kiện (P1–P3) | 60 |
| | Hạ cánh chính xác | 10 điểm | 10 |
| **TỔNG** | | | **130** |
| Phase 2: Delivery | Cất cánh tự động (độ cao ≥3.0m) | 20 điểm | 20 |
| | Giao thành công D1, D2 (Đỏ, D=1.0m) | 20 điểm × 2 | 40 |
| | Giao thành công D3, D4 (Vàng, D=0.6m) | 30 điểm × 2 | 60 |
| | Giao thành công D5 (Xanh, D=0.4m) | 50 điểm | 50 |
| | Hạ cánh chính xác tự động | 30 điểm | 30 |
| **TỔNG** | | | **200** |

### B. FINAL ROUND — **[GIỮ NGUYÊN GIÁ TRỊ ĐIỂM]**

| Category | Mission Details | Scoring Criteria | Maximum Score |
|---|---|---|---|
| Phase 1: Pickup | (như trên) | | 130 |
| Phase 2: Delivery | Cất cánh tự động | 10 điểm | 10 |
| | Giao D1 cố định (Đỏ, D=1.0m) | 10 điểm | 10 |
| | Giao D2 động — Mobile Receiver (Đỏ, D=1.0m) | 50 điểm | 50 |
| | Giao D3, D4 (Vàng, D=0.6m) | 30 điểm × 2 | 60 |
| | Giao D5 (Xanh, D=0.4m) | 50 điểm | 50 |
| | Hạ cánh chính xác tự động | 20 điểm | 20 |
| **TỔNG** | | | **200** |

### C. **[MỚI, SỬA LẠI]** BONUS — COORDINATED OPS TRACK

| Tiêu chí | Điểm thưởng |
|---|---|
| Hoàn thành chuỗi Đặt hàng → Lấy hàng qua Đường Cơ bản (không cần CABP), trong T1+T2 | **[CẦN REVIEW]** đề xuất +40 điểm — đây là điểm nền, chứng minh chuỗi vận hành được ngay cả khi CABP thất bại |
| Hoàn thành qua Đường Bonus (CABP thành công, bỏ qua bước quét) | **[CẦN REVIEW]** đề xuất +60 điểm (cao hơn Đường Cơ bản) — khuyến khích đội đầu tư CABP thật, không phạt đội chưa làm được |
| Đặt hàng đúng hạn T1 nhưng UAV-B không hoàn thành lấy hàng trong T2 | **[CẦN REVIEW]** đề xuất +10 điểm (ghi nhận một phần, không 0 tuyệt đối) |
| Duy trì khoảng cách an toàn tối thiểu giữa 2 UAV, chứng minh qua log beacon hợp lệ | **[CẦN REVIEW]** đề xuất +10 điểm cố định |

## VII. PENALTIES AND VIOLATIONS — **[GIỮ NGUYÊN, BỔ SUNG COORDINATED OPS]**

**1. Point Deductions (Penalties):**
- Va chạm với khung Air Corridor Checkpoint: -5 điểm/lần.
- Vi phạm ranh giới arena (>5 giây): -5 điểm/lần.
- Vi phạm độ cao khi tự động (<3.0m, >5 giây): -5 điểm/lần.
- **[MỚI]** Va chạm giữa 2 UAV cùng đội (Coordinated Ops): **[CẦN REVIEW]** trừ điểm nghiêm trọng + có thể dừng lượt thi.

**2. Invalid Mission Attempts (Non-Scoring):**
- Kiện hàng rơi trước khi chạm Depot: 0 điểm cho kiện đó.
- Kiện hàng thả ngoài vòng tròn mục tiêu, hoặc thả kiện thứ hai vào điểm đã hoàn thành: 0 điểm cho lần thả đó.

**3. Retry Protocol and Early Termination — [GIỮ NGUYÊN]:**
- Tối đa một (01) lần retry/vòng thi đấu.
- Đồng hồ không dừng trong khi retry; đội tự đưa UAV về vị trí xuất phát.
- Toàn bộ điểm trước khi retry bị hủy, tính lại từ 0.

## VIII. SAFETY REGULATIONS — **[GIỮ NGUYÊN 100%]**

1. **Pre-flight Technical Inspection:** trình diện khu vực kỹ thuật 15 phút trước giờ thi; kiểm tra cấu trúc khung/cánh quạt/cơ cấu nhiệm vụ, tình trạng pin; chỉ cất cánh sau khi có "Safety Clearance" từ BOC.
2. **Flight Space Limitations (Geofencing):** UAV phải ở trong ranh giới arena kể cả không phận trên khu kỹ thuật; vi phạm >5 giây bị phạt theo Mục VII; mất kiểm soát/bay về phía khán giả → BOC kích hoạt quy trình khẩn cấp ngay lập tức.
3. **Autonomous Safety Mechanisms (Fail-safe & RTH):** cấu hình Fail-safe bắt buộc — mất tín hiệu >3 giây phải tự kích hoạt RTH về Depot hoặc hạ cánh khẩn cấp; GCS phải có nút dừng khẩn cấp (emergency stop) rõ ràng.
4. **Personal Protective Equipment (PPE):** kính bảo hộ và mũ bảo hộ bắt buộc cho phi công/kỹ thuật viên khi vào arena; đồng phục đội và giày kín mũi khuyến khích, cấm dép hở ngón.
5. **Authorities of the Organizing Committee:** trọng tài/cán bộ an toàn bay có toàn quyền ra lệnh "Stop Mission" ngay khi phát hiện yếu tố nguy hiểm; BOC có quyền loại đội vi phạm an toàn nhiều lần hoặc không tuân thủ hướng dẫn trọng tài.

## IX. APPEALS AND DISPUTE RESOLUTION — **[GIỮ NGUYÊN 100%]**

- Cửa sổ khiếu nại: trong vòng 05 phút ngay sau khi trận đấu kết thúc.
- Chỉ Đội trưởng (đã đăng ký chính thức với BOC) được phép khiếu nại.
- Khiếu nại phải trình bày chuyên nghiệp, có bằng chứng rõ ràng; BOC đối chiếu camera giám sát (CCTV) và log trọng tài.
- Quyết định của Hội đồng Trọng tài (BOJ) là quyết định cuối cùng và có hiệu lực ngay lập tức.

## X. TEAM RESPONSIBILITIES — **[GIỮ NGUYÊN, GHI CHÚ ĐIỀU CHỈNH COORDINATED OPS]**

- Punctuality: có mặt khu kỹ thuật tối thiểu 15 phút trước giờ thi.
- Equipment Preparedness: đội tự chịu trách nhiệm toàn bộ trang thiết bị (UAV, pin dự phòng, sạc, điều khiển, phần cứng CV).
- Operational Compliance & Professionalism: tuân thủ hướng dẫn BOC/trọng tài/an ninh; giữ gìn khu kỹ thuật sạch sẽ; tinh thần fair-play.
- Quota thành viên: PhD tối đa 01; Thạc sĩ tối đa 02; Đại học tối đa 06; tổng tối đa 06 người/đội.
- **[CẦN REVIEW]** Đội đăng ký Coordinated Ops: cần xác nhận lại quota vận hành đồng thời 2 UAV có đòi hỏi điều chỉnh số lượng phi công/kỹ thuật viên vận hành cùng lúc hay không.

## XI. MATCH DURATION AND TIMING — **[GIỮ NGUYÊN 100%]**

- Tổng thời gian: tối đa 05 phút/vòng thi cho toàn bộ nhiệm vụ; tất cả đội thi hoàn thành Phase 1 tuần tự trước khi chuyển sang Phase 2.
- Đồng hồ bắt đầu khi trọng tài ra tín hiệu, dừng khi UAV hạ cánh an toàn và động cơ tắt hoàn toàn.
- Hết giờ: đội phải lệnh UAV hạ cánh ngay; nhiệm vụ hoàn thành sau mốc 05 phút không được tính điểm.
- Thời gian chuẩn bị: 60 giây để thiết lập trạm mặt đất và nạp mã nhiệm vụ trước khi đồng hồ chính thức bắt đầu.

## XII. DETAILED ARENA TECHNICAL SPECIFICATIONS — **[GIỮ NGUYÊN VẬT LÝ, ĐỔI NHÃN]**

- Sơ đồ mặt cắt đứng, layout arena, cấu trúc Air Corridor Checkpoint, khu vực Pickup: kế thừa nguyên vẹn Figure 2–5 của luật lần 3.
- **Package Model Specifications (thay Victim Model):** khối cứng 0.3m ± 0.5mm, tổng cao 450mm ± 0.5mm tính cả tay cầm, trọng lượng 300g.
- **Delivery Point Standardization cho CV (thay Fire Zone):**
  - D1, D2 (Đỏ): đường kính 1000mm, HEX #FC2A1B.
  - D3, D4 (Vàng): đường kính 600mm, HEX #FAFF37.
  - D5 (Xanh): đường kính 400mm, HEX #3C00FB.
- **[CẦN REVIEW]** Package Simulant (thay Tennis Ball): giữ nguyên bóng tennis tiêu chuẩn (đường kính 65.41–68.58mm, khối lượng 56.0–59.4g) để tái sử dụng CV đã chuẩn hóa, hoặc thiết kế lại hình khối "gói hàng" — quyết định cần cân đối chi phí re-tooling/re-training CV.
- Takeoff/Landing Zone: kế thừa nguyên Figure 8.
- Depot (thay Victim Assembly Area/Safe Zone): kế thừa nguyên Figure 9.

## XIII. **[MỚI]** CPAS AGENT BEACON PROTOCOL (CABP) — YÊU CẦU KỸ THUẬT CHO TRACK COORDINATED OPS

*(Tóm tắt cho mục đích luật chơi — đặc tả kỹ thuật đầy đủ tham chiếu tài liệu riêng: CABP Technical Specification v0.2.)*

### 13.1 Mục đích
Cho phép (a) hai UAV cùng đội tránh va chạm lẫn nhau mà không cần bộ điều khiển trung tâm, và (b) BOC giám sát/chấm điểm an toàn dựa trên dữ liệu khách quan.

### 13.2 Yêu cầu bắt buộc đối với đội đăng ký Coordinated Ops
- Phát bản tin trạng thái chuẩn hóa (CABP) tối thiểu **[CẦN REVIEW]** 5 Hz trong suốt thời gian bay.
- Bản tin tối thiểu gồm: `agent_id`, `timestamp`, `position (x,y,z)`, `agent_state`, `intent`, `battery_critical`, `health_flags` — chi tiết định dạng xem CABP Technical Specification v0.2, Mục 3.
- Kênh truyền không giới hạn công nghệ cụ thể (Wi-Fi, LoRa, hoặc telemetry sẵn có) — chỉ chuẩn hóa định dạng bản tin, không chuẩn hóa hạ tầng truyền dẫn.
- BOC thu thập log beacon đầy đủ của mọi UAV thuộc track này để phục vụ chấm điểm và (nếu đội đồng ý) nghiên cứu ẩn danh sau cuộc thi.
- Mất tín hiệu beacon giữa 2 UAV cùng đội quá ngưỡng **[CẦN REVIEW]** 500ms phải kích hoạt hành vi an toàn định trước (giảm tốc/hover/RTH) theo đúng nguyên tắc Authority Monotonicity — logic beacon chỉ đề xuất, không có quyền ghi trực tiếp lên actuator.

### 13.3 Định vị (Localization) hỗ trợ CABP
Khuyến khích đội sử dụng UWB RTLS (anchor đặt ngoài playfield, đã hợp lệ theo Mục III.3 — Radio Communication) làm nguồn tham chiếu chính cho `position`, kết hợp EKF/UKF fusion với IMU/VIO để tăng độ mượt và có được ước lượng độ tin cậy. Tham chiếu chi tiết: CPAS Localization Technical Note v0.1.

### 13.4 **[MỚI, CANDIDATE CABP v0.3]** Bản tin sự kiện — `mission_event`
Khác với bản tin trạng thái định kỳ (periodic beacon, phát liên tục theo Mục 3 CABP spec), cơ chế "Đặt hàng — Chuyển tiếp — Lấy hàng" (Mục V.D) cần một **bản tin sự kiện rời rạc**, phát một lần khi có sự kiện xảy ra, không phát định kỳ:
- Trường tối thiểu: `agent_id` (nguồn phát), `event_type` (VD: `PACKAGE_PLACED`), `location_id` (ID điểm D theo QR), `timestamp`.
- Đây là ứng cử viên bổ sung cho CABP v0.3 — cần kiểm tra qua Protocol Evolution Policy trước khi đưa vào spec chính thức: Necessary (có — chính là cơ chế truyền tin cho relay task), Measurable/Testable (có — đo được tỷ lệ nhận đúng/timeout), Implementable (có — chỉ là một bản tin nhỏ, độ phức tạp thấp hơn cả periodic beacon).
- **Việc cần làm:** cập nhật CABP Technical Specification v0.2 → v0.3 để chính thức hóa `mission_event` như một message type riêng, tách biệt khỏi Mission layer hiện có (vốn chỉ có `agent_state`/`intent` dạng trạng thái liên tục, chưa có cơ chế sự kiện rời rạc).

## XIV. **[MỚI]** IMPLEMENTATION TIMELINE (tính ngược từ mốc kỷ niệm 30 năm)

| Mốc | Thời gian | Việc cần hoàn thành |
|---|---|---|
| Draft rule đầy đủ (tài liệu này) | 25/7/2026 | ✅ Hoàn thành |
| Review nội bộ + góp ý hội đồng kỹ thuật độc lập | 8–10/2026 | Đặc biệt feedback tính khả thi phần cứng CABP/UWB |
| Đề xuất chính thức vai trò Technical Chair + CPAS Lab | 9–10/2026 | Gộp chung hồ sơ |
| Đặt hàng linh kiện phần cứng (nếu cần cho Coordinated Ops) | Chậm nhất đầu Q4/2026 | Lead time linh kiện 16–24 tuần |
| Hoàn thiện + công bố luật chính thức | Chậm nhất Q1/2027 | Để đội có 6–9 tháng chuẩn bị |
| Contest 2027 | ~9/2027 | — |

---

## DANH SÁCH TỔNG HỢP CÁC MỤC **[CẦN REVIEW]** TRƯỚC KHI CÔNG BỐ CHÍNH THỨC

1. Điểm thưởng cụ thể cho track Coordinated Ops (Mục VI.C).
2. Mức phạt cụ thể khi va chạm giữa 2 UAV cùng đội (Mục VII.1).
3. Quy định số lượng phi công/kỹ thuật viên vận hành đồng thời cho Coordinated Ops (Mục X).
4. Quyết định giữ nguyên bóng tennis hay thiết kế lại "gói hàng" vật lý (Mục XII).
5. Tần suất phát beacon tối thiểu (Mục XIII.2) — cần xác nhận khả thi phần cứng với các đội.
6. Ngưỡng timeout phát hiện mất beacon (Mục XIII.2).
7. **[MỚI]** Số lượng điểm D trong tập ứng viên bốc thăm cho cơ chế relay (Mục V.D) — đề xuất 3/5.
8. **[MỚI]** Quy trình xác minh checksum mã nguồn UAV-B nộp trước bốc thăm (Mục V.D).
9. **[MỚI]** Độ dài cửa sổ thời gian T1 (đặt hàng, đề xuất 90s), T2 (lấy hàng, đề xuất 120s), và timeout chờ mission_event (đề xuất 3s) (Mục V.D).
10. **[MỚI]** Tổng thời gian trận cho track Coordinated Ops — đề xuất 7 phút thay vì 5 phút chuẩn (Mục V.D, cần đồng bộ Mục XI).
11. **[MỚI]** Nâng CABP Technical Specification lên v0.3 để chính thức hóa `mission_event` (Mục XIII.4).

*Ghi chú: Đây là danh sách các quyết định cần hội đồng kỹ thuật xác nhận — không phải thiếu sót của bản draft. Mục tiêu của tài liệu này là chốt kiến trúc và nội dung nhiệm vụ đầy đủ, làm cơ sở để hội đồng kỹ thuật và BOC quyết định các con số cuối cùng trước khi công bố chính thức (chậm nhất Q1/2027).*
