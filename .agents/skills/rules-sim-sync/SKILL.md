---
name: rules-sim-sync
description: >-
  WS1 and Digital Twin specialist agent for Official UAV Contest 2027 Rules
  (Markdown and bilingual LaTeX PDFs) and MATLAB_Arena_Simulation scripts.
  Use when editing competition rules, scoring, LaTeX templates, or MATLAB
  arena/mission scripts, or when checking Rules-to-Simulation parity.
---

# WS1 & Digital Twin — Rules & MATLAB Arena Sync Agent

You own **`Rules/`** (`LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md`, `uav_contest_2027_rules.tex`, `uav_contest_2027_rules_en.tex`) and **`MATLAB_Arena_Simulation/`** (`build_uav_contest_arena.m`, `mission_*.m`, `simulate_arena_mission.m`, `run_uav_contest_missions.m`).

## Canonical vs. Archived Rules

- **Edit ONLY** files in `Rules/`.
- Never edit or treat root drafts (`Luat_choi_UAV_Contest_2027.md`, `LUAT_THI_UAV_CONTEST_2027*.md`, `26_Sep_26/UAV_Contest_2027_Full_Rules_Draft_v0.2.md`, `Ref/*`) as current official rules; use them strictly as historical reference.

## Shared Parameter Contract (Must Stay Synchronized)

Whenever updating either `Rules/` or `MATLAB_Arena_Simulation/`, verify every parameter below matches across Markdown, VI/EN `.tex`, and `.m` files:

- **Arena:** `12.0 × 24.0 m` (`x ∈ [-12, 12]`, `y ∈ [-6, 6]`, ceiling net `Z = 5.0 m`)
- **Zones:** Depot `12.0 × 3.5 m`, Pickup `12.0 × 4.5 m` (`P1–P3`: `1.0 × 1.0 × 1.0 m`)
- **ACC1–ACC4 Gates:** Inner diameter `1.6 m`, center `Z = 1.7 m`, top `2.6 m`
- **Delivery Points D1–D5 (`Z = 0.1 m`, `15 × 15 cm` QR):**
  - `D1, D2`: Red (`#FC2A1B`), `Ø1000 mm` (`D2` Mobile Receiver `10 cm/s` in Finals)
  - `D3, D4`: Yellow (`#FAFF37`), `Ø600 mm`
  - `D5`: Blue (`#3C00FB`), `Ø400 mm`
- **Autonomous Altitude (Phase 2):** `3.0 m – 5.0 m`
- **Coordinated Ops:** `T1 = 90 s`, `T2 = 120 s`, max match `7 min`, CABP timeout `3.0 s`, `D_MIN >= 1.5 m`, Bonus `+60`, Baseline `+40`

## Verification

1. After rule/LaTeX edits, ensure VI (`uav_contest_2027_rules.tex`) and EN (`uav_contest_2027_rules_en.tex`) match `Rules/LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md`.
2. Run `python .agents/skills/uav-pm-orchestrator/scripts/project_audit.py` to confirm Rules ↔ MATLAB ↔ CABP consistency.
