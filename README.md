# UAV Contest 2027 & CPAS Lab — Ton Duc Thang University (TDTU)

Kho lưu trữ chính thức phục vụ công tác tổ chức **UAV Contest 2027** (*The 4th International Competition on Research and Design of Unmanned Aerial Vehicles*, **20–21/09/2027**, kỷ niệm 30 năm thành lập Trường Đại học Tôn Đức Thắng) và **Đề tài Nghiên cứu Cơ sở CPAS Lab** (`01/11/2026 – 30/06/2027`).

---

## Cấu trúc thư mục chính

| Thư mục / Tệp | Vai trò |
|---|---|
| `Rules/` | **[Canonical WS1]** Luật thi đấu chính thức 2027 (`LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md`, nguồn LaTeX & PDF tiếng Việt/Anh) |
| `CABP_Starter_Kit/` | **[Canonical WS2]** Bộ mã nguồn chuẩn giao thức **CPAS Agent Beacon Protocol (`cabp_lite.py`)** + `mock_uav_a.py` / `mock_uav_b.py` |
| `MATLAB_Arena_Simulation/` | **[Canonical Digital Twin]** Kịch bản mô phỏng 3D MATLAB UAV Toolbox (`12.0×24.0 m`, Pha 1, Pha 2, Coordinated Ops) |
| `Web_Arena_Simulation/` | **[Web 3D Simulator]** Ứng dụng Web **Three.js** mô phỏng sân đấu 3D, 4 kịch bản thi đấu & **WS5 Collision Replay** |
| `26_Sep_26/` | Đặc tả kỹ thuật `CABP_Technical_Specification_v0.3.md` & lộ trình 14 tháng `CPAS_Master_Implementation_Plan_v0.1.md` |
| `AGENTS.md` & `.agents/` | Hệ thống **Agent Orchestration Pipeline** (`uav-pm-orchestrator`, `cabp-protocol-track`, `localization-safety-track`, `rules-sim-sync`, `admin-grant-comms`) |
| `PROJECT_ORCHESTRATION_PIPELINE.md` | Kiến trúc tổng thể pipeline điều phối đa-agent & bảng kiểm toán đồng bộ |
| `Ref/` | Tài liệu luật thi các mùa trước (2024–2026) dùng tham khảo |

> **Lưu ý tệp lớn:** Video `Video Demo/Multi_agent_task.mp4` (`~127 MB`, vượt giới hạn `100 MB` của GitHub) được loại trừ qua `.gitignore` và lưu trữ riêng trên Drive/Releases.

---

## Khởi chạy nhanh các công cụ

### 1. Web-App Mô phỏng 3D Three.js (`Web_Arena_Simulation`)

```bash
python -m http.server 8087 --directory Web_Arena_Simulation
```

Mở trình duyệt tại `http://127.0.0.1:8087`. Để theo dõi gói tin CABP thật qua UDP `14555`, chạy thêm cầu nối WebSocket:

```bash
python Web_Arena_Simulation/bridge/cabp_ws_bridge.py
```

### 2. Kiểm thử Giao thức CABP (`CABP_Starter_Kit`)

Mở 2 terminal độc lập (khởi chạy UAV-B lắng nghe trước, sau đó chạy UAV-A phát bản tin):

```bash
python CABP_Starter_Kit/mock_uav_b.py
python CABP_Starter_Kit/mock_uav_a.py
```

### 3. Kiểm toán Dự án & Đồng bộ Rules ↔ Code ↔ Sim

```bash
python .agents/skills/uav-pm-orchestrator/scripts/project_audit.py
```
