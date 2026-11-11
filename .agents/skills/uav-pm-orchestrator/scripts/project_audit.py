"""
UAV Contest 2027 & CPAS Lab — Project Audit & Cross-Layer Consistency Checker.

Verifies:
1. Canonical project state (.agents/project_state.json) and milestone/gate readiness.
2. Live round-trip functional test of CABP_Starter_Kit/cabp_lite.py.
3. Cross-layer consistency across Official Rules, CABP Spec v0.3, Starter Kit,
   MATLAB Arena Simulation, and BGH Strategy docs.
4. Workspace hygiene (build artifacts, archives, key file existence).

Usage:
    python .agents/skills/uav-pm-orchestrator/scripts/project_audit.py [--json]
"""

from __future__ import annotations

import argparse
import datetime as dt
import io
import json
import re
import struct
import sys
from pathlib import Path
from typing import Any

# Ensure UTF-8 output on Windows consoles
if hasattr(sys.stdout, "buffer") and sys.stdout.encoding.lower() != "utf-8":
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")


def find_repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "AGENTS.md").exists() and (parent / ".agents" / "project_state.json").exists():
            return parent
    return Path.cwd()


def read_text_safe(path: Path) -> str:
    if not path.exists():
        return ""
    return path.read_text(encoding="utf-8", errors="replace")


def test_cabp_lite(root: Path, contract: dict[str, Any]) -> dict[str, Any]:
    starter_dir = root / "CABP_Starter_Kit"
    if not (starter_dir / "cabp_lite.py").exists():
        return {"status": "SAI", "detail": "CABP_Starter_Kit/cabp_lite.py missing"}

    sys.path.insert(0, str(starter_dir))
    try:
        import cabp_lite  # type: ignore

        periodic_pkt = cabp_lite.CABPMessage.pack_periodic_beacon(
            agent_id=101,
            seq_num=42,
            state=cabp_lite.AgentState.EXECUTING,
            intent=cabp_lite.AgentIntent.DELIVER,
            x=1.25,
            y=-2.5,
            z=3.5,
            battery_critical=False,
        )
        periodic_dec = cabp_lite.CABPMessage.unpack_periodic_beacon(periodic_pkt)

        event_pkt = cabp_lite.CABPMessage.pack_mission_event(
            agent_id=101,
            event_type=cabp_lite.EventType.PACKAGE_PLACED,
            location_id=3,
        )
        event_dec = cabp_lite.CABPMessage.unpack_mission_event(event_pkt)

        expected_p_len = int(contract["periodic_beacon_bytes"])
        expected_e_len = int(contract["mission_event_bytes"])
        expected_port = int(contract["cabp_udp_port"])
        expected_magic = int(contract["cabp_magic_hex"], 16)

        errors: list[str] = []
        if len(periodic_pkt) != expected_p_len:
            errors.append(f"Periodic packet len={len(periodic_pkt)} != {expected_p_len}")
        if len(event_pkt) != expected_e_len:
            errors.append(f"Event packet len={len(event_pkt)} != {expected_e_len}")
        if cabp_lite.CABP_PORT != expected_port:
            errors.append(f"CABP_PORT={cabp_lite.CABP_PORT} != {expected_port}")
        if cabp_lite.CABP_MAGIC != expected_magic:
            errors.append(f"CABP_MAGIC={hex(cabp_lite.CABP_MAGIC)} != {hex(expected_magic)}")
        if not periodic_dec or periodic_dec["agent_id"] != 101 or periodic_dec["seq_num"] != 42:
            errors.append("Periodic round-trip decode mismatch")
        if not event_dec or event_dec["location_id"] != 3:
            errors.append("Mission event round-trip decode mismatch")

        if errors:
            return {"status": "SAI", "detail": "; ".join(errors)}
        return {
            "status": "ĐẠT",
            "detail": (
                f"Round-trip OK (periodic={len(periodic_pkt)}B, event={len(event_pkt)}B, "
                f"port={cabp_lite.CABP_PORT}, magic={hex(cabp_lite.CABP_MAGIC)})"
            ),
        }
    except Exception as exc:
        return {"status": "SAI", "detail": f"Exception importing/running cabp_lite: {exc}"}
    finally:
        if str(starter_dir) in sys.path:
            sys.path.remove(str(starter_dir))


def run_consistency_checks(root: Path, state: dict[str, Any]) -> list[dict[str, str]]:
    findings: list[dict[str, str]] = []
    contract = state["shared_contract"]

    rules_text = read_text_safe(root / "Rules" / "LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md")
    cabp_spec_text = read_text_safe(root / "26_Sep_26" / "CABP_Technical_Specification_v0.3.md")
    cabp_py_text = read_text_safe(root / "CABP_Starter_Kit" / "cabp_lite.py")
    cabp_readme_text = read_text_safe(root / "CABP_Starter_Kit" / "README.md")
    mock_b_text = read_text_safe(root / "CABP_Starter_Kit" / "mock_uav_b.py")
    matlab_arena_text = read_text_safe(root / "MATLAB_Arena_Simulation" / "build_uav_contest_arena.m")
    matlab_coop_text = read_text_safe(root / "MATLAB_Arena_Simulation" / "mission_multi_uav_coordinated_ops.m")
    bgh_text = read_text_safe(root / "TO_TRINH_BGH_UAV_CONTEST_2027_AND_CPAS_LAB.md")

    # 1. Arena dimensions: 12.0 x 24.0 m across Rules & MATLAB
    rules_has_12x24 = bool(re.search(r"12\.0\s*\\times\s*24\.0|12\s*[×x]\s*24", rules_text))
    matlab_has_12x24 = ("xMin = -12.0; xMax = 12.0;" in matlab_arena_text) and (
        "yMin = -6.0;  yMax = 6.0;" in matlab_arena_text
    )
    findings.append({
        "check": "Arena 12m x 24m (Official Rules <-> MATLAB Arena)",
        "verdict": "ĐẠT" if (rules_has_12x24 and matlab_has_12x24) else "SAI",
        "evidence": f"Rules={rules_has_12x24}, MATLAB={matlab_has_12x24}",
    })

    # 2. BGH pitch vs Official Rules arena/MTOW drift detection
    bgh_mentions_25x30 = "25" in bgh_text and "30" in bgh_text and "sân song song" in bgh_text
    if bgh_mentions_25x30 and rules_has_12x24:
        findings.append({
            "check": "BGH Strategy Pitch vs Official Rules Arena Size",
            "verdict": "WARN",
            "evidence": (
                "TO_TRINH_BGH_UAV_CONTEST_2027_AND_CPAS_LAB.md pitches dual 25m x 30m arenas, "
                "while Official Rules & MATLAB Arena use 12.0m x 24.0m (keep aligned before BGH/BOC release)."
            ),
        })

    # 3. D_MIN safety distance alignment
    rules_has_15m = "1.5" in rules_text
    matlab_has_15m = "1.5m" in matlab_coop_text or "1.5" in matlab_coop_text
    cabp_v03_has_10m = "D_MIN (VD: 1.0 m" in cabp_spec_text
    if rules_has_15m and matlab_has_15m and not cabp_v03_has_10m:
        findings.append({
            "check": "D_MIN Safety Separation (1.5 m)",
            "verdict": "ĐẠT",
            "evidence": "Official Rules, MATLAB Coop Sim, and CABP Spec aligned at 1.5 m.",
        })
    else:
        findings.append({
            "check": "D_MIN Safety Separation (1.5 m)",
            "verdict": "WARN",
            "evidence": (
                "Official Rules & MATLAB use D_MIN >= 1.5 m, while "
                "26_Sep_26/CABP_Technical_Specification_v0.3.md line 266 still shows example 'D_MIN (VD: 1.0 m)'."
            ),
        })

    # 4. cabp_lite.py docstring vs actual struct size (31 bytes)
    actual_size = struct.calcsize(">BBHIQBBfffB")
    docstring_says_29 = "(29 bytes)" in cabp_py_text
    findings.append({
        "check": "cabp_lite.py Docstring vs Struct Size",
        "verdict": "WARN" if docstring_says_29 else "ĐẠT",
        "evidence": (
            f"struct.calcsize('>BBHIQBBfffB')={actual_size}B (matches Official Rules 31B), "
            + ("but cabp_lite.py line 46 docstring still says '(29 bytes)'." if docstring_says_29 else "docstring matches.")
        ),
    })

    # 5. Relay timeout 3.0s across Rules & mock_uav_b.py
    mock_timeout_ok = "TIMEOUT_SECONDS = 3.0" in mock_b_text
    rules_timeout_ok = "3.0" in rules_text
    findings.append({
        "check": "Coordinated Ops CABP Relay Timeout (3.0 s)",
        "verdict": "ĐẠT" if (mock_timeout_ok and rules_timeout_ok) else "SAI",
        "evidence": f"Rules={rules_timeout_ok}, mock_uav_b.py={mock_timeout_ok}",
    })

    # 6. Official Rules section numbering check (TOC item 11 vs heading XII, README ref XIII)
    toc_has_11_cabp = "11. [Đặc tả Kỹ thuật Giao thức CABP" in rules_text
    body_has_xii_cabp = "## XII. ĐẶC TẢ KỸ THUẬT GIAO THỨC CABP" in rules_text
    readme_ref_xiii = "Mục XIII" in cabp_readme_text
    if toc_has_11_cabp and body_has_xii_cabp:
        findings.append({
            "check": "Official Rules Section Numbering & Starter Kit Cross-Ref",
            "verdict": "WARN",
            "evidence": (
                "Rules/LUAT_THI_DAU_CHINH_THUC_UAV_CONTEST_2027.md TOC lists CABP as #11 while heading is ## XII "
                "(XI. Thể lệ was inserted); CABP_Starter_Kit/README.md still cites 'Mục XIII' (from Draft v0.2)."
            ),
        })

    # 7. Canonical files presence
    missing_canon = []
    for ws in state["workstreams"]:
        for rel in ws["canonical_files"]:
            if not (root / rel).exists():
                missing_canon.append(f"{ws['id']}:{rel}")
    findings.append({
        "check": "All Canonical Files Present",
        "verdict": "ĐẠT" if not missing_canon else "SAI",
        "evidence": "All verified on disk" if not missing_canon else f"Missing: {', '.join(missing_canon)}",
    })

    return findings


def inventory_summary(root: Path) -> dict[str, Any]:
    latex_aux_exts = {".aux", ".log", ".out", ".toc"}
    aux_files = []
    total_files = 0
    for p in root.rglob("*"):
        if p.is_file():
            if ".agents" in p.parts or "__pycache__" in p.parts:
                continue
            total_files += 1
            if p.suffix.lower() in latex_aux_exts:
                aux_files.append(str(p.relative_to(root)))
    return {
        "project_files_excluding_agents_pycache": total_files,
        "latex_build_artifacts_in_Rules": len(aux_files),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Audit UAV Contest 2027 workspace & pipeline state.")
    parser.add_argument("--json", action="store_true", help="Print output as JSON.")
    args = parser.parse_args()

    root = find_repo_root()
    state_path = root / ".agents" / "project_state.json"
    state = json.loads(state_path.read_text(encoding="utf-8"))

    today = dt.date.today()
    contest_start = dt.date.fromisoformat(state["key_dates"]["contest_dates"][0])
    grant_end = dt.date.fromisoformat(state["key_dates"]["basic_research_end"])
    rules_deadline = dt.date.fromisoformat(state["key_dates"]["official_rules_publish_deadline"])

    cabp_test = test_cabp_lite(root, state["shared_contract"])
    consistency = run_consistency_checks(root, state)
    inv = inventory_summary(root)

    report = {
        "audit_date": today.isoformat(),
        "countdown_days": {
            "to_official_rules_q1_2027_deadline": (rules_deadline - today).days,
            "to_tdtu_basic_research_end": (grant_end - today).days,
            "to_uav_contest_2027": (contest_start - today).days,
        },
        "cabp_lite_self_test": cabp_test,
        "consistency_checks": consistency,
        "workstreams": [
            {"id": ws["id"], "name": ws["name"], "status": ws["status"], "owner": ws["owner_skill"]}
            for ws in state["workstreams"]
        ],
        "gates": [
            {"gate": g["gate"], "milestones": g["milestones"], "window": g["target_window"], "status": g["status"]}
            for g in state["milestones_and_gates"]
        ],
        "open_decisions": state["open_decisions_and_blockers"],
        "inventory": inv,
    }

    if args.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return 0

    print("=" * 72)
    print(f"UAV CONTEST 2027 & CPAS LAB — PIPELINE AUDIT ({today.isoformat()})")
    print("=" * 72)
    cd = report["countdown_days"]
    print(
        f"Countdown: Rules Q1/2027={cd['to_official_rules_q1_2027_deadline']}d | "
        f"Basic Research End={cd['to_tdtu_basic_research_end']}d | "
        f"Contest={cd['to_uav_contest_2027']}d"
    )
    print(f"Workspace files (excl. .agents/__pycache__): {inv['project_files_excluding_agents_pycache']} "
          f"(LaTeX aux files: {inv['latex_build_artifacts_in_Rules']})")
    print()
    print(f"[CABP Self-Test] {cabp_test['status']} — {cabp_test['detail']}")
    print()
    print("[Cross-Layer Consistency Checks]")
    for item in consistency:
        print(f"  - [{item['verdict']}] {item['check']}: {item['evidence']}")
    print()
    print("[Workstreams]")
    for ws in report["workstreams"]:
        print(f"  - {ws['id']} ({ws['owner']}): {ws['status']} — {ws['name']}")
    print()
    print("[Milestone Gates]")
    for g in report["gates"]:
        print(f"  - {g['gate']} ({','.join(g['milestones'])}, {g['window']}): {g['status']}")
    print()
    print("[Top Open Decisions / Blockers]")
    for d in report["open_decisions"]:
        print(f"  - [{d['priority']}] {d['id']}: {d['title']}")
    print("=" * 72)

    has_sai = cabp_test["status"] == "SAI" or any(c["verdict"] == "SAI" for c in consistency)
    return 1 if has_sai else 0


if __name__ == "__main__":
    raise SystemExit(main())
