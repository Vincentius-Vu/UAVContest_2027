# UAV Contest 2027 & CPAS Lab — Workspace Agent Governance (`AGENTS.md`)

**Mission:** Coordinate research, engineering, simulation, rules governance, and contest operations for **UAV Contest 2027** (20–21/09/2027, TDTU Tân Phong) and the **TDTU Basic Research Project** (01/11/2026 – 30/06/2027, PI: TS. Trí Viễn Vũ, Scientific Secretary: TS. Trần Đức Anh Minh).

---

## 1. Canonical Source of Truth vs. Archive

Always read from **Canonical** files first. Never cite **Superseded/Draft** files as current specification without flagging the version gap.

| Domain | Canonical Source of Truth | Superseded / Reference Only (Do Not Treat as Final) |
|---|---|---|
| **Official Contest Rules (2027)** | `Rules/LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md` (and `Rules/uav_contest_2027_rules.tex`, `_en.tex`, `.pdf`) | `Luat_choi_UAV_Contest_2027.md`, `LUAT_THI_UAV_CONTEST_2027.md`, `LUAT_THI_UAV_CONTEST_2027_V2.md/.pdf`, `Luật thi đấu.pdf`, `26_Sep_26/UAV_Contest_2027_Full_Rules_Draft_v0.2.*`, `Ref/*` |
| **CABP Protocol Spec** | `26_Sep_26/CABP_Technical_Specification_v0.3.md` (adds `mission_event`) | `CPAS_Beacon_Technical_Specification_v0.1.md`, `CABP_Technical_Specification_v0.2.md` |
| **CABP Reference Code** | `CABP_Starter_Kit/cabp_lite.py`, `mock_uav_a.py`, `mock_uav_b.py`, `README.md` | `files.zip` (snapshot archive) |
| **Master Roadmap (14-mo)** | `26_Sep_26/CPAS_Master_Implementation_Plan_v0.1.md` | — |
| **Internal Project Ops (8-mo)** | `Ke_hoach_dieu_phoi_quan_ly_thuc_hien_de_tai.md` | `KE_HOACH_HANH_DONG_VA_TIEN_DO_THI_DAU_2026.md` (2026 countdown template) |
| **Localization & Ground Truth** | `CPAS_Localization_Technical_Note_v0.1.md` (+ AprilTag 6-cam decision in `CPAS_Master_Implementation_Plan_v0.1.md` §3 WS3) | — |
| **Arena Digital Twin** | `MATLAB_Arena_Simulation/` (`build_uav_contest_arena.m`, `mission_*.m`, `uav_contest_2027_arena.mat`) | — |
| **Budget & BGH Strategy** | `UAV_Contest_2027_Du_Toan_Kinh_Phi.xlsx`, `TO_TRINH_BGH_UAV_CONTEST_2027_AND_CPAS_LAB.md`, `CPAS_Lab_Founding_Strategy_UAV2027.md` | Note: BGH strategy pitch mentions 25×30m dual arena & 3.5 kg MTOW; Official Rules & MATLAB Sim use 12×24m & 5.0 kg MTOW. |
| **Pipeline State & Blueprint** | `.agents/project_state.json`, `PROJECT_ORCHESTRATION_PIPELINE.md` | — |

---

## 2. Non-Negotiable Engineering & Governance Rules

1. **Protocol Evolution Policy (Scope Control):**
   Any proposed new CABP field, hardware item, or sub-goal MUST pass all 4 criteria before adoption:
   **Necessary** (required for Contest 2027 / BM02) · **Measurable** (quantifiable by experiment) · **Testable** (pass/fail test case) · **Implementable** (completable inside remaining project timeline).
   Anything failing any criterion goes to *Future Extensions*, never into v0.x scope. Respect the 24-month Do-Not-Build list (no blockchain, national UTM, full swarm intelligence, large Digital Twin platform, generic multi-robot protocol, foundation model, humanoid, or "AI platform").

2. **Authority Monotonicity:**
   - Technical: CABP is **advisory/monitoring only** (`CABP_Starter_Kit`, `Rules/` §XII.3). It must NEVER write directly to flight controller PWM/actuators, and packet loss must never hang companion computers or flight control.
   - Organizational: Track Leads decide within their track; any change to shared schemas (`cabp_lite.py` frame format), shared safety thresholds (`D_MIN = 1.5 m`, `STALE_THRESHOLD = 500 ms`, `CABP_PORT = 14555`, `TIMEOUT = 3.0 s`), or milestone scope requires CNĐT/TK approval.

3. **Reference Frame Separation (Agent vs. Ground System):**
   Never mix `Estimated_Position` (carried by CABP, potentially drifted/noisy) with `Ground_Truth` (BOC independent 6-camera Overhead AprilTag system, never sent over CABP). Store raw CABP logs and Ground Truth logs separately.

4. **Rules ↔ Code ↔ Simulation Sync Contract:**
   Before closing any task touching rules, protocol, or arena coordinates, verify alignment on:
   - Arena: `12.0 × 24.0 m`, Depot `12.0 × 3.5 m`, Pickup `12.0 × 4.5 m`, ACC1–ACC4 (`Ø1.6 m`, center `Z=1.7 m`, top `2.6 m`), D1–D5 (`Z=0.1 m`, `15×15 cm` QR), D2 Mobile Receiver (`10 cm/s`), Phase 2 autonomous altitude `3.0–5.0 m`.
   - CABP Binary: UDP broadcast port `14555`, magic `0xCB`, Periodic Beacon `31 bytes` @ `5 Hz` (`200 ms`, stale `500 ms`), Mission Event `16 bytes` (repeat `3x`, `3.0 s` relay timeout), safety separation `D_MIN = 1.5 m`.

5. **Evidence-First Reporting:**
   Never invent test measurements, hardware readiness, or legal citations. Run `.agents/skills/uav-pm-orchestrator/scripts/project_audit.py` to inspect workspace status and sync checks before reporting project health.

---

## 3. Agent Orchestration Pipeline Routing

Activate the matching skill in `.agents/skills/` based on the request:

| Task Domain | Skill Name | Primary Scope |
|---|---|---|
| Milestone tracking (M1–M6), Gates 1–4, weekly sync, risk/scope audit, multi-agent dispatch | `uav-pm-orchestrator` | `.agents/project_state.json`, `PROJECT_ORCHESTRATION_PIPELINE.md`, cross-track coordination |
| CABP schema, `cabp_lite.py` (Python/C++), bench-test, time sync, stale detection | `cabp-protocol-track` | `CABP_Starter_Kit/`, `26_Sep_26/CABP_Technical_Specification_v0.3.md` |
| UWB RTLS baseline, 6-cam AprilTag Ground Truth, benchmark, collision replay (`D_MIN`) | `localization-safety-track` | `CPAS_Localization_Technical_Note_v0.1.md`, WS3 & WS5 |
| Official Rules (VI/EN), LaTeX builds, MATLAB Arena 3D & mission simulations | `rules-sim-sync` | `Rules/`, `MATLAB_Arena_Simulation/` |
| TDTU grant proposals (WS4), budget (`.xlsx`), BGH strategy, flyers/posters/video, contest countdown | `admin-grant-comms` | `TO_TRINH_BGH_*`, `UAV_Contest_2027_Du_Toan_Kinh_Phi.xlsx`, `*.html`, `add_poster_typography.py`, `KE_HOACH_HANH_DONG_*` |
