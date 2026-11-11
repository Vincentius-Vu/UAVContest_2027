# Three.js 3D Arena & Mission Simulator — UAV Contest 2027 (CPAS Lab)

Ứng dụng web 3D nhẹ chạy trực tiếp trên trình duyệt (Three.js ES Modules, không cần Node.js/MATLAB) phục vụ mô phỏng sân thi đấu chuẩn **12.0 × 24.0 m**, kiểm tra kịch bản thi đấu và tái hiện log **WS5 Collision Replay** theo đúng [LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md](../Rules/LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md).

---

## 1. Khởi chạy nhanh (Quickstart)

Từ thư mục gốc `02_UAV_Contest_2027`:

```bash
python -m http.server 8087 --directory Web_Arena_Simulation
```

Sau đó mở trình duyệt tại: **http://127.0.0.1:8087**

*(Lưu ý: Cần chạy qua HTTP server thay vì mở trực tiếp `file://` để `fetch('./data/scenarios.json')` và ES Modules hoạt động.)*

---

## 2. Tính năng chính

1. **Mô hình 3D Arena chuẩn Luật 2027 (`arenaBuilder.js`):**
   - Ánh xạ chính xác hệ tọa độ **ENU (MATLAB/Luật)** sang **Three.js (Y-up)**: $X_{\text{3js}} = X_{\text{ENU}},\ Y_{\text{3js}} = Z_{\text{ENU}},\ Z_{\text{3js}} = -Y_{\text{ENU}}$.
   - Đầy đủ Depot (`12×3.5 m`), Pickup (`12×4.5 m`, P1–P3 + kiện `0.3 m`), 4 cổng tròn **ACC1–ACC4** (`Ø1.6 m`, tâm `1.7 m`), 5 điểm **D1–D5** đúng mã màu HEX + **QR `15×15 cm`**, **D2 Mobile Receiver** (`10 cm/s`), trần lưới `5.0 m`, dải bay tự động `3.0–5.0 m`, 4 trụ UWB vành đai ngoài và vùng phủ **6 Camera Overhead (BOC Ground Truth)**.
2. **4 Kịch bản mô phỏng đồng bộ từ `MATLAB_Arena_Simulation/` (`scenarios.json`):**
   - `Pha 1 (180s)`: Gắp kiện hàng `300 g` tại P2 qua ACC1–ACC4 về Depot (`90đ`).
   - `Pha 2 Chung kết (210s)`: Bay tự động `3.0–5.0 m`, thả 5 bóng tennis, bám bắt `D2 Mobile Receiver` `10 cm/s` (`200đ`).
   - `Coordinated Ops — Đường Bonus (240s)`: UAV-A đặt hàng D3 → phát CABP `mission_event` (`0xCB`) → UAV-B nhận trong `0.5s` (`≤ 3.0s`) và lấy hàng (`+60đ` + `+10đ` an toàn `≥ 1.5 m`).
   - `Coordinated Ops — Đường Cơ bản Fallback (265s)`: Mất gói CABP quá `3.0 s` → UAV-B tự động quét QR tập `{D1, D3, D5}` (`+40đ` + `+10đ`).
3. **WS5 Replay & Tách hệ quy chiếu (`logReplay.js`):**
   - Nạp tách biệt 2 file JSONL: `CABP Log` (`Estimated_Position`) và `Ground Truth` (`BOC 6-Cam AprilTag`), hiển thị vector sai số và tự động bắt lỗi `D_MIN < 1.5 m` (có sẵn nút **Nạp mẫu WS5 Replay**).
4. **Live CABP Monitor qua UDP `14555` (`bridge/cabp_ws_bridge.py`):**
   - Chạy cầu nối Python (chỉ dùng thư viện chuẩn + `CABP_Starter_Kit/cabp_lite.py`):
     ```bash
     python Web_Arena_Simulation/bridge/cabp_ws_bridge.py
     ```
   - Nhấn **Kết nối CABP UDP 14555 (WS)** trên giao diện web rồi chạy `CABP_Starter_Kit/mock_uav_a.py` hoặc script phát beacon 5 Hz để xem trực tiếp.
