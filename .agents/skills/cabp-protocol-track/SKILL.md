---
name: cabp-protocol-track
description: >-
  Track A / WS2 specialist agent for the CPAS Agent Beacon Protocol (CABP v0.3)
  and CABP_Starter_Kit. Use when modifying cabp_lite.py, building the C++ port,
  implementing M1-M3 (serialization, 2-board bench-test, time sync, stale detection),
  or reviewing any protocol field proposal.
---

# Track A / WS2 — CABP Protocol Agent

You own **CABP Technical Specification v0.3** (`26_Sep_26/CABP_Technical_Specification_v0.3.md`) and **`CABP_Starter_Kit/`** (`cabp_lite.py`, `mock_uav_a.py`, `mock_uav_b.py`, `README.md`), covering Milestones **M1–M3** (`Gate 1` & `Gate 2`).

## Mandatory Guardrails

1. **Protocol Evolution Policy Gate:** Before adding any field or message type to CABP v0.x, document explicit pass/fail answers for all 4 conditions (*Necessary, Measurable, Testable, Implementable*). Anything failing goes to Section 10 (*Future Extensions*).
2. **Authority Monotonicity:** CABP code is strictly **advisory/monitoring**. It must never write to flight controller PWM/actuators, and socket timeouts/packet drops must never block or crash the flight control loop.
3. **Locked Binary Contract:**
   - Transport: UDP Broadcast, port `14555`, magic `0xCB`
   - Periodic Beacon (`0x01`): `31 bytes` (`>BBHIQBBfffB`), `5 Hz` (`200 ms`), `STALE_THRESHOLD = 500 ms`
   - Mission Event (`0x02`): `16 bytes` (`>BBHBBQH`), sent `3x` on `PACKAGE_PLACED`, receiver timeout `3.0 s`

## Workflow

1. **Inspect & Test Before Editing:**
   Run the starter kit round-trip check via:
   ```bash
   python .agents/skills/uav-pm-orchestrator/scripts/project_audit.py
   ```
2. **When Running End-to-End Relay Demo:**
   Start `mock_uav_b.py` first (listener, `3.0 s` window), then `mock_uav_a.py` (broadcaster), or test timeout fallback when `mock_uav_a.py` is not run.
3. **Sync Rules & C++ Parity:**
   Any change to enums (`AgentState`, `AgentIntent`, `EventType`) or packet struct must be reflected identically in Python, C++ (`cpas_beacon`), `26_Sep_26/CABP_Technical_Specification_v0.3.md`, and `Rules/LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md` §XII, and approved by CNĐT/TK.
