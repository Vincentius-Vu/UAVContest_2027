# LUẬT THI ĐẤU CHÍNH THỨC — UAV CONTEST 2026
### The 3rd/4th International Competition on Research and Design of Unmanned Aerial Vehicles
### Đơn vị đăng cai: Trường Đại học Tôn Đức Thắng (TDTU) — Khoa Điện – Điện tử & CPAS Lab
### Ngày thi đấu chính thức: **20 và 21 tháng 09 năm 2026**
### Địa điểm: Nhà thi đấu đa năng Cơ sở chính Tân Phong, Trường Đại học Tôn Đức Thắng, TP. Hồ Chí Minh

---

**Chủ đề thi đấu:**  
**HỆ SINH THÁI LOGISTICS TỰ HÀNH TẦM THẤP (AUTONOMOUS LOW-ALTITUDE LOGISTICS ECOSYSTEM)**  
*Mô phỏng Trung tâm Phân phối & Tiếp vận Hàng hóa Tự động Tầm thấp (Autonomous Logistics Hub)*

**Trạng thái pháp lý:** Văn bản chính thức ban hành (Official Rules). Đã hoàn tất phê duyệt toàn bộ thông số kỹ thuật, áp dụng chính thức cho các đội thi tranh tài ngày 20 và 21/9/2026.

---

## MỤC LỤC
1. [Mục đích và Bối cảnh](#i-mục-đích-và-bối-cảnh)
2. [Mục tiêu Cuộc thi](#ii-mục-tiêu-cuộc-thi)
3. [Thông số Kỹ thuật UAV](#iii-thông-số-kỹ-thuật-uav)
4. [Thông số và Mặt bằng Sân thi đấu](#iv-thông-số-và-mặt-bằng-sân-thi-đấu)
5. [Quy định Nhiệm vụ Thi đấu các Vòng](#v-quy-định-nhiệm-vụ-thi-đấu-các-vòng)
6. [Hạng mục Tự nguyện: Coordinated Ops (Đa Tác tử)](#vi-hạng-mục-tự-nguyện-coordinated-ops-đa-tác-tử)
7. [Tiêu chí và Thang điểm Chấm](#vii-tiêu-chí-và-thang-điểm-chấm)
8. [Quy định Phạt lỗi và Vi phạm](#viii-quy-định-phạt-lỗi-và-vi-phạm)
9. [Quy chuẩn An toàn Bắt buộc](#ix-quy-chuẩn-an-toàn-bắt-buộc)
10. [Khiếu nại và Trọng tài](#x-khiếu-nại-và-trọng-tài)
11. [Đặc tả Kỹ thuật Giao thức CABP (Chuẩn hóa)](#xi-đặc-tả-kỹ-thuật-giao-thức-cabp-chuẩn-hóa)

---

## I. MỤC ĐÍCH VÀ BỐI CẢNH
Nền kinh tế tầm thấp (*low-altitude economy*) và logistics tự hành đang là trụ cột quan trọng được định hướng phát triển quốc gia theo tinh thần Quyết định 808/QĐ-TTg của Thủ tướng Chính phủ và các định hướng KH&CN trọng điểm. Khác với các mô hình bay đơn lẻ truyền thống, hạ tầng logistics tương lai đòi hỏi nhiều tác nhân không người lái (UAV, AMR) cùng vận hành an toàn trong không gian chia sẻ mà không phụ thuộc vào một bộ điều khiển tập trung.

Cuộc thi mô phỏng quy trình tự động hóa tiếp vận: lấy hàng nguồn, vận chuyển qua hành lang bay an toàn, giao hàng chính xác cho các trạm tiếp nhận tĩnh và di động, và phối hợp chuyển tiếp giữa các thiết bị bay tự trị.

---

## II. MỤC TIÊU CUỘC THI
* **Ứng dụng thực tiễn:** Làm chủ công nghệ bay trong môi trường không GPS (*GPS-denied*), định vị vật lý chính xác và tự động hóa chuỗi cung ứng.
* **Đổi mới sáng tạo:** Tích hợp thị giác máy tính tại biên (Edge AI/CV), bám bắt mục tiêu động và định vị cảm biến hỗn hợp (UWB/VIO).
* **Đánh giá toàn diện:** Kết hợp kỹ năng điều khiển cơ học, năng lực tự chủ hoàn toàn của thuật toán và năng lực giao tiếp máy - máy (M2M / Swarm) thông qua giao thức mở CABP.

---

## III. THÔNG SỐ KỸ THUẬT UAV

### 1. Cấu hình phần cứng
* **Kích thước bao ngoài:** Tối đa $1.0 \times 1.0 \times 1.0\text{ m}$ (tính cả cánh quạt và khung bảo vệ cánh quạt).
* **Trọng lượng cất cánh tối đa (MTOW):** $\le 5.0\text{ kg}$ (bao gồm toàn bộ pin, máy tính nhúng, cơ cấu tải).
* **Hệ thống nguồn:** Pin LiPo/Li-ion, cấu hình tối đa **6S**, tối đa 3 pack pin gắn trên thân, tổng năng lượng tích trữ $\le 300\text{ Wh}$.
* **Cơ cấu tải nhiệm vụ:**
  * *Cơ cấu lấy hàng (Gripper/Magnet/Vacuum):* Nâng tối thiểu $\ge 300\text{g}$, có khóa chống rơi tự do khi bay.
  * *Cơ cấu thả hàng (Dispenser):* Chứa sẵn tối đa 05 kiện hàng mô phỏng khi cất cánh ở Pha 2.
* **Vật liệu kiện hàng chuẩn hóa:**
  * *Kiện hàng lớn (Pha 1):* Khối cứng hình lập phương $0.3\text{ m}$, trọng lượng $300\text{ g}$, có tay nắm móc gắp.
  * *Kiện hàng nhỏ (Pha 2):* Sử dụng **bóng tennis tiêu chuẩn** (đường kính $65.41$–$68.58\text{ mm}$, trọng lượng $56.0$–$59.4\text{ g}$) nhằm tái sử dụng $100\%$ hệ thống nhận diện quang học và cơ cấu nhả đã kiểm chứng.

### 2. Thiết bị vô tuyến và định vị
* **Tuân thủ pháp luật:** Tần số RC ($2.4\text{ GHz} / 5.8\text{ GHz}$) và Wi-Fi tuân thủ quy định quản lý tần số vô tuyến điện Việt Nam.
* **Hạ tầng định vị vô tuyến:** Nghiêm cấm đặt bất kỳ thiết bị/cọc mốc định vị vô tuyến nào trực tiếp trên bề mặt sân thi đấu (Playfield). **Các hệ thống UWB RTLS với Anchor đặt tại khu vực vành đai ngoài (Perimeter) được phép sử dụng hoàn toàn hợp lệ.**

---

## IV. THÔNG SỐ VÀ MẶT BẰNG SÂN THI ĐẤU

* **Kích thước tổng thể:** $12.0 \times 24.0\text{ m}$.
* **Khu Trạm xuất phát (Depot):** $12.0 \times 3.5\text{ m}$ (chứa bệ cất/hạ cánh quy chuẩn).
* **Hành lang bay kiểm soát (ACC1–ACC4):** Khung tròn đường kính trong $1.6\text{ m}$, tâm cao $1.7\text{ m}$ so với sàn, chiều cao đỉnh khung $2.6\text{ m}$.
  * Hành trình đi (Depot $\to$ Lấy hàng): Bắt buộc chui qua tâm ACC1 và ACC2.
  * Hành trình về (Lấy hàng $\to$ Depot): Bắt buộc chui qua tâm ACC3 và ACC4.
* **Khu Lấy hàng (Pickup Area):** $12.0 \times 4.5\text{ m}$, chứa 3 trạm lấy hàng P1, P2, P3 (bệ $1.0 \times 1.0\text{ m}$, cao $1.0\text{ m}$).
* **Khu Điểm Giao hàng (Delivery Points D1–D5):** Đặt tại độ cao $0.1\text{ m}$ so với sàn:
  * **D1, D2 (Màu Đỏ, HEX `#FC2A1B`):** Đường kính $\varnothing 1000\text{ mm}$.
  * **D3, D4 (Màu Vàng, HEX `#FAFF37`):** Đường kính $\varnothing 600\text{ mm}$.
  * **D5 (Màu Xanh, HEX `#3C00FB`):** Đường kính $\varnothing 400\text{ mm}$.
  * **Mã QR định danh:** Mỗi điểm D1–D5 được dán **mã QR kích thước tiêu chuẩn $15 \times 15\text{ cm}$** ngay tại tâm điểm, mã hóa chuỗi ký tự định danh (ví dụ `"D1"`, `"D2"`,...).
* **Trạm Nhận hàng Di động (Mobile Receiver — Áp dụng Vòng Chung kết):** Điểm D2 gắn trên phương tiện di chuyển tuyến tính tới–lui với vận tốc không đổi **$10\text{ cm/s}$** dọc theo ray dẫn hướng cố định.
* **Giới hạn trần bay:** Bay thủ công $\le 5.0\text{ m}$; Bay tự động bắt buộc duy trì trong khoảng **$3.0\text{ m} - 5.0\text{ m}$**.

---

## V. QUY ĐỊNH NHIỆM VỤ THI ĐẤU CÁC VÒNG

### A. VÒNG LOẠI (PRELIMINARY ROUND)
* **Tổng thời gian thi đấu:** **05 phút** (300 giây).
* **Pha 1 — Lấy hàng (Thủ công / Bán tự động):**
  1. Cất cánh từ Depot, bay chui qua ACC1 và ACC2.
  2. Tiếp cận khu vực lấy hàng, dùng cơ cấu gắp 01 kiện hàng lớn từ P1, P2 hoặc P3.
  3. Vận chuyển kiện hàng quay về qua ACC3 và ACC4, đặt an toàn trong Depot.
  4. Hạ cánh có kiểm soát trên bệ đáp.
* **Pha 2 — Giao hàng (Tự động hoàn toàn 100%):**
  1. Cất cánh tự động đạt độ cao an toàn $\ge 3.0\text{ m}$ không chạm tay điều khiển.
  2. Điều hướng thả 5 bóng tennis vào các điểm D1–D5. **Ở Vòng Loại, tọa độ D1–D5 là CỐ ĐỊNH** theo sơ đồ công bố. Mỗi điểm chỉ tính điểm lần đầu tiên thả trúng.
  3. Tự động quay về hạ cánh chính xác tại Depot và ngắt động cơ.

### B. VÒNG BÁN KẾT (SEMI-FINAL ROUND)
* Pha 1 giữ nguyên.
* Pha 2: **Tọa độ D1–D5 KHÔNG CỐ ĐỊNH**. Trước mỗi trận đấu, Ban Trọng tài bốc thăm ngẫu nhiên tọa độ từ ma trận vị trí quy định. UAV bắt buộc phải dùng Computer Vision nhận diện vòng tròn màu và tâm điểm để thả hàng.

### C. VÒNG CHUNG KẾT (FINAL ROUND)
* Pha 1 giữ nguyên.
* Pha 2: Tọa độ D1–D5 bốc thăm ngẫu nhiên. Điểm **D2 được gắn trên Mobile Receiver di chuyển $10\text{ cm/s}$**, yêu cầu UAV giải bài toán bám bắt và tính toán điểm rơi động.

---

## VI. HẠNG MỤC TỰ NGUYỆN: COORDINATED OPS (ĐA TÁC TỬ)

Đây là hạng mục khuyến khích công nghệ cao, thi đấu theo cơ chế **"Đặt hàng — Chuyển tiếp — Lấy hàng"** giữa 2 UAV trong cùng một đội:

1. **Phân cấp thi đấu:** Hoàn toàn độc lập với Track chuẩn. Điểm thi Coordinated Ops tính vào điểm thưởng Bonus hoặc giải chuyên đề *"Best Multi-Agent Innovation Award"*. Đội không tham gia hoặc thực hiện thất bại vẫn bảo toàn $100\%$ điểm vòng chuẩn.
2. **Quy tắc bốc thăm:** Trước trận, Ban Trọng tài bốc thăm xác định **03 trong 05 điểm D** làm tập ứng viên hợp lệ (ví dụ: tập `{D1, D3, D5}`).
3. **Quy trình xác minh mã nguồn:** Đội thi nộp mã băm **SHA-256** của phần mềm nạp trên UAV-B cho Trọng tài Kỹ thuật trước giờ bốc thăm 30 phút để đảm bảo UAV-B hoàn toàn không được lập trình sẵn điểm đích cụ thể trước trận.
4. **Giai đoạn 1 — Đặt hàng (UAV-A):** Thời gian tối đa **$T_1 = 90\text{ giây}$**. Phi công điều khiển UAV-A mang 1 kiện hàng đặt vào 01 trong 3 điểm thuộc tập ứng viên. Khi đặt thành công, UAV-A phát bản tin `mission_event` qua giao thức CABP.
5. **Giai đoạn 2 — Lấy hàng (UAV-B):** Thời gian tối đa **$T_2 = 120\text{ giây}$**.
   * **Đường Bonus (CABP thành công):** Nhận được bản tin `mission_event` hợp lệ trong **ngưỡng chờ $3.0\text{ giây}$** $\to$ UAV-B bay thẳng tới điểm đích, gắp hàng mang về Depot (Bỏ qua bước quét).
   * **Đường Cơ bản (Fallback tự động):** Sau $3.0\text{ giây}$ không có tín hiệu CABP $\to$ UAV-B tự động chuyển sang bay tuần tự quét mã QR tại các điểm ứng viên, xác nhận kiện hàng và gắp về.
6. **Thời lượng trận đấu Coordinated Ops:** Chốt tối đa **07 phút** (420 giây).
7. **Nhân sự vận hành:** Tối đa **02 người** trong sân (01 phi công lái UAV-A, 01 kỹ sư giám sát trạm mặt đất UAV-B giữ nút dừng khẩn cấp E-Stop).

---

## VII. TIÊU CHÍ VÀ THANG ĐIỂM CHẤM

### 1. Bảng điểm Track Chuẩn (Vòng Loại, Bán kết, Chung kết)

| Pha thi | Nội dung nhiệm vụ | Tiêu chí chi tiết | Điểm tối đa |
|---|---|---|:---:|
| **Pha 1: Lấy hàng** | Vượt qua cổng hành lang | Bay qua ACC1–ACC4 ($5\text{ điểm/cổng}$) | 20 |
| | Lấy & giao kiện hàng lớn | Đặt kiện hàng an toàn về Depot | 60 |
| | Hạ cánh chính xác | Đỗ an toàn trên bệ đáp | 10 |
| **Tổng Pha 1** | | | **90** |
| **Pha 2: Giao hàng** | Cất cánh tự động | Tự nâng độ cao $\ge 3.0\text{ m}$ không chạm RC | 20 (CK: 10) |
| | Giao hàng D1, D2 (Đỏ $\varnothing 1.0\text{ m}$) | Thả trúng vòng tròn ($20\text{đ} \times 2$, CK: D1 $10\text{đ}$, D2 động $50\text{đ}$) | 40 (CK: 60) |
| | Giao hàng D3, D4 (Vàng $\varnothing 0.6\text{ m}$) | Thả trúng vòng tròn ($30\text{đ} \times 2$) | 60 |
| | Giao hàng D5 (Xanh $\varnothing 0.4\text{ m}$) | Thả trúng vòng tròn nhỏ nhất | 50 |
| | Hạ cánh tự động chính xác | Đỗ tự động trong tâm Depot | 30 (CK: 20) |
| **Tổng Pha 2** | | | **200** |
| **TỔNG ĐIỂM CHUẨN** | | | **290 điểm** |

### 2. Điểm thưởng Hạng mục Coordinated Ops

| Tiêu chí nhiệm vụ Coordinated Ops | Điểm thưởng chính thức |
|---|:---:|
| Hoàn thành chuỗi qua **Đường Bonus** (Nhận CABP thành công trong 3s, bay thẳng lấy hàng) | **+60 điểm** |
| Hoàn thành chuỗi qua **Đường Cơ bản** (Fallback tự động quét QR, lấy hàng thành công) | **+40 điểm** |
| UAV-A đặt hàng hợp lệ trong $T_1$, UAV-B cất cánh nhưng chưa hoàn tất trong $T_2$ | **+10 điểm** |
| Duy trì khoảng cách an toàn giữa 2 UAV suốt trận ($\ge 1.5\text{ m}$ theo log CABP) | **+10 điểm** |

---

## VIII. QUY ĐỊNH PHẠT LỖI VÀ VI PHẠM

1. **Trừ điểm vi phạm vận hành:**
   * Va chạm với khung cổng ACC: **-5 điểm/lần**.
   * Bay ra ngoài ranh giới sân thi đấu quá 5 giây: **-5 điểm/lần**.
   * Bay dưới độ cao quy định ($<3.0\text{ m}$) trong Pha 2 tự động quá 5 giây: **-5 điểm/lần**.
   * **Va chạm giữa 2 UAV trong Coordinated Ops:** **Trừ 20 điểm và dừng ngay trận đấu** để đảm bảo an toàn.
2. **Nhiệm vụ không hợp lệ:**
   * Kiện hàng rơi trước khi tới Depot: **0 điểm** cho lượt gắp đó.
   * Thả bóng ra ngoài vòng tròn hoặc thả bóng thứ 2 vào điểm đã có bóng: **0 điểm** cho quả bóng đó.
3. **Quy định Retry:** Mỗi đội được phép yêu cầu Thử lại (Retry) tối đa **01 lần/trận**. Đồng hồ trận đấu **KHÔNG DỪNG**. Toàn bộ điểm trước khi Retry bị hủy để tính lại từ đầu.

---

## IX. QUY CHUẨN AN TOÀN BẮT BUỘC
* **Khung bảo vệ cánh quạt (Propeller Guards):** Bắt buộc $100\%$ cho mọi thiết bị.
* **Cơ chế Fail-safe & Emergency Stop:** Mất kết nối RC/Telemetry quá 3 giây phải tự động kích hoạt RTH hoặc hạ cánh khẩn cấp. Trạm điều khiển mặt đất bắt buộc có nút E-Stop ngắt động cơ tức thì.
* **Kiểm tra kỹ thuật tiền bay:** Đội thi trình diện UAV trước giờ đấu 15 phút. Pin phồng, rò rỉ điện hoặc nứt khung sườn bị từ chối thi đấu ngay lập tức.
* **Trang bị bảo hộ (PPE):** Mọi thành viên vào sân bắt buộc đeo kính bảo hộ và giày kín mũi.

---

## X. KHIẾU NẠI VÀ TRỌNG TÀI
* Thời hạn gửi khiếu nại bằng văn bản: Trong vòng **05 phút** sau khi trận đấu kết thúc.
* Chỉ Đội trưởng đăng ký chính thức mới có quyền khiếu nại.
* Quyết định của Hội đồng Trọng tài (BOJ) dựa trên video CCTV và nhật ký cảm biến là quyết định cuối cùng.

---

## XI. ĐẶC TẢ KỸ THUẬT GIAO THỨC CABP (CHUẨN HÓA)

Giao thức **CPAS Agent Beacon Protocol (CABP)** chạy trên tầng mạng UDP Broadcast (cổng mặc định `14555`):

1. **Bản tin Định kỳ (Periodic Beacon — 5 Hz):**  
   Kích thước 31 bytes nhị phân, phát liên tục chu kỳ $200\text{ ms}$:
   * `magic` (uint8, `0xCB`), `msg_type` (uint8, `0x01`).
   * `agent_id` (uint16), `seq_num` (uint32), `timestamp` (uint64, ms).
   * `agent_state` (uint8: 0=IDLE, 1=EXECUTING, 2=RETURNING, 3=LANDING, 4=EMERGENCY).
   * `intent` (uint8: 0=HOVER, 1=GO_TO_POINT, 2=PICKUP, 3=DELIVER, 4=RETURN_HOME, 5=LAND).
   * `x, y, z` (float32 $\times$ 3, tọa độ mét).
   * `battery_critical` (uint8, 0/1).
   * *Ngưỡng phát hiện mất kết nối định kỳ:* **$500\text{ ms}$**.

2. **Bản tin Sự kiện (Mission Event — Bất đồng bộ):**  
   Kích thước 16 bytes nhị phân, phát lặp 3 lần khi UAV-A đặt kiện hàng:
   * `magic` (`0xCB`), `msg_type` (`0x02`).
   * `agent_id` (uint16).
   * `event_type` (uint8: 1=`PACKAGE_PLACED`).
   * `location_id` (uint8: 1=D1, 2=D2, 3=D3, 4=D4, 5=D5).
   * `timestamp` (uint64).

3. **Nguyên tắc Authority Monotonicity:**  
   CABP chỉ mang tính chất thông báo và đề xuất tọa độ đích. Thuật toán điều khiển trên Companion Computer / Flight Controller giữ quyền kiểm soát cao nhất, tuyệt đối không để mất gói tin mạng làm treo hệ thống điều khiển bay.

---
*Ban Tổ chức UAV Contest 2026 — CPAS Lab, Trường Đại học Tôn Đức Thắng.*
