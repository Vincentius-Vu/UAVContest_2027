# KẾ HOẠCH HÀNH ĐỘNG VÀ TIẾN ĐỘ THI CÔNG — UAV CONTEST 2026
### Mốc đích: Ngày thi đấu chính thức 20 & 21 tháng 09 năm 2026
### Đơn vị điều phối: CPAS Lab & Khoa Điện – Điện tử, Trường Đại học Tôn Đức Thắng (TDTU)

---

## 1. TỔNG QUAN PHÂN KỲ TRIỂN KHAI

Để đảm bảo ngày thi đấu chính thức **20 và 21/9/2026** diễn ra an toàn, đúng chuẩn chuyên môn quốc tế và tạo điều kiện tối đa cho các đội thi thích ứng, kế hoạch được chia làm 4 giai đoạn trọng tâm:

```
[GIAI ĐOẠN 1]           [GIAI ĐOẠN 2]             [GIAI ĐOẠN 3]            [GIAI ĐOẠN 4]
Ban hành Luật &          Phát hành Starter Kit &   Kiểm tra Kỹ thuật &      THI ĐẤU CHÍNH THỨC
Mở cổng Đăng ký          Tập huấn Webinar          Thử nghiệm Sân đấu       (20 - 21/9/2026)
(T-120 đến T-90 ngày)    (T-90 đến T-45 ngày)      (T-30 đến T-7 ngày)      (T-0 ngày)
```

---

## 2. MA TRẬN MỐC TIẾN ĐỘ CHI TIẾT (MILESTONE COUNTDOWN)

| Mốc thời gian | Tên nhiệm vụ / Hoạt động | Đơn vị chủ trì | Sản phẩm đầu ra cụ thể |
|---|---|---|---|
| **Mốc 1** | **Ban hành Luật thi đấu Chính thức** | CPAS Lab & Ban Tổ chức | Văn bản `LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2026.md` |
| **Mốc 2** | **Phát hành CABP Lite Starter Kit** | Đội ngũ R&D CPAS Lab | Repository mã nguồn mở Python/C++ kèm hướng dẫn tích hợp |
| **Mốc 3** | **Webinar Hướng dẫn Kỹ thuật & Q&A** | Ban Trọng tài Kỹ thuật (BOJ) | Giải đáp trực tiếp về chuẩn QR Code, CABP UDP và luật bốc thăm |
| **Mốc 4** | **Chốt danh sách Đội thi & Cấp mã Agent** | Ban Thư ký Giải | Cấp mã định danh `agent_id` và dải tần Wi-Fi riêng cho từng đội |
| **Mốc 5** | **Hoàn thiện Sa bàn & Thiết bị Sân đấu** | Bộ phận Hậu cần & Kỹ thuật | Hoàn tất khung ACC, cảm biến D1–D5, ray trượt Mobile Receiver |
| **Mốc 6** | **Chạy thử nghiệm (Dry-Run) Toàn diện** | CPAS Lab & Đội Mocking | Bắn thử bóng, chạy kịch bản Coordinated Ops mẫu kiểm tra mạng |
| **Mốc 7 (T-1)** | **Kiểm tra Kỹ thuật tiền bay & Chốt Checksum** | Ban Trọng tài Kỹ thuật | Đo kiểm cân nặng MTOW, khung bảo vệ, lưu SHA-256 mã UAV-B |
| **Mốc 8** | **NGÀY THI ĐẤU 1: Vòng Loại (20/9/2026)** | Hội đồng Trọng tài | Thi đấu Pha 1 + Pha 2 (D1–D5 cố định) chọn Top 12 vào Bán kết |
| **Mốc 9** | **NGÀY THI ĐẤU 2: Bán kết, Chung kết & Coordinated Ops (21/9/2026)** | Hội đồng Trọng tài | Bán kết (D ngẫu nhiên), Chung kết (D2 di động $10\text{cm/s}$) & Trao giải |

---

## 3. CÁC NỘI DUNG ĐÃ CHỐT DỨT ĐIỂM (RESOLVED DECISIONS)

1. **Phân cấp thi đấu linh hoạt (Tiered Phasing):**
   * *Track Chuẩn (Single-UAV):* Căn cứ xét các giải Vô địch, Nhất, Nhì, Ba, Khuyến khích.
   * *Track Coordinated Ops (2 UAVs):* Hạng mục tự nguyện, cộng điểm thưởng trực tiếp (+40đ hoặc +60đ) hoặc xét Giải thưởng Chuyên đề Công nghệ Xuất sắc nhất (*Best Innovation Award*). Tuyệt đối không trừ điểm vòng chuẩn nếu thất bại.
2. **Cửa sổ thời gian nhiệm vụ Coordinated Ops:**
   * $T_1$ (Đặt hàng - UAV-A): **90 giây**.
   * $T_2$ (Lấy hàng - UAV-B): **120 giây**.
   * Timeout chờ bản tin `mission_event`: **3.0 giây**.
   * Tổng thời lượng trận đấu Coordinated Ops: **7 phút** (so với 5 phút vòng chuẩn).
3. **Quy chuẩn mã QR & Vật liệu:**
   * Mã QR dán tại các điểm D1–D5: In phẳng độ tương phản cao, kích thước **$15 \times 15\text{ cm}$**.
   * Kiện hàng nhỏ: Dùng **bóng tennis tiêu chuẩn** ($\varnothing 65.41$–$68.58\text{ mm}$, nặng $56.0$–$59.4\text{ g}$).
4. **Quy trình chống gian lận mã nguồn UAV-B:**
   * Đội thi tạo mã hash **SHA-256** của toàn bộ script bay/binary nhiệm vụ trên UAV-B và nộp cho Ban Trọng tài kèm file trên USB trước giờ bốc thăm 30 phút. Trọng tài có quyền yêu cầu xuất checksum trên Companion Computer để đối chiếu bất kỳ lúc nào.

---

## 4. PHƯƠNG ÁN DỰ PHÒNG TẠI CHỖ (CONTINGENCY PLANS)

* **Sự cố nghẽn mạng Wi-Fi tại Nhà thi đấu:**
  * Ban Tổ chức cấp phát Access Point riêng cho từng đội với kênh sóng (Channel) tách biệt hoàn toàn ($5\text{ GHz}$).
  * Trong trường hợp can nhiễu nghiêm trọng, UAV-B tự động kích hoạt **Đường Cơ bản** quét QR tuần tự, không để việc mất kết nối mạng làm gián đoạn lượt thi.
* **Sự cố kẹt ray Mobile Receiver ở Vòng Chung kết:**
  * Có sẵn cụm AGV mini dự phòng; thời gian thay thế $\le 3\text{ phút}$. Nếu không thể khắc phục kịp thời, điểm D2 sẽ được cố định và tính điểm theo hệ số dự phòng đã định trước.
