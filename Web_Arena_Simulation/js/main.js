import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";
import { buildArena, enuToThree } from "./arenaBuilder.js";
import { createUavActor } from "./uavModel.js";
import { evaluateScenarioAtTime } from "./trajectoryEngine.js";
import { buildReplaySession } from "./logReplay.js";

const viewportEl = document.getElementById("viewport");
const pipHostEl = document.getElementById("pipCanvasHost");
const pipContainerEl = document.getElementById("pipContainer");
const scenarioSelect = document.getElementById("scenarioSelect");
const cameraSelect = document.getElementById("cameraSelect");
const speedSelect = document.getElementById("speedSelect");
const timeSlider = document.getElementById("timeSlider");
const btnPlayPause = document.getElementById("btnPlayPause");
const btnRestart = document.getElementById("btnRestart");
const btnResetView = document.getElementById("btnResetView");

const hudTime = document.getElementById("hudTime");
const hudScore = document.getElementById("hudScore");
const hudSafety = document.getElementById("hudSafety");
const hudCabp = document.getElementById("hudCabp");
const scenarioDesc = document.getElementById("scenarioDesc");
const telemetryList = document.getElementById("telemetryList");
const eventLogEl = document.getElementById("eventLog");
const replayStatusEl = document.getElementById("replayStatus");

// Three.js Main Renderer + Scene + Camera
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x060b16);
scene.fog = new THREE.FogExp2(0x060b16, 0.012);

const camera = new THREE.PerspectiveCamera(50, viewportEl.clientWidth / viewportEl.clientHeight, 0.1, 150);
camera.position.set(0, 14.5, 20.5);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
renderer.setSize(viewportEl.clientWidth, viewportEl.clientHeight);
viewportEl.appendChild(renderer.domElement);

// PIP Renderer for Onboard Downward CV Camera
const pipRenderer = new THREE.WebGLRenderer({ antialias: true });
pipRenderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
pipRenderer.setSize(250, 185);
pipHostEl.appendChild(pipRenderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;
controls.dampingFactor = 0.08;
controls.target.set(0, 1.4, 0);
controls.maxPolarAngle = Math.PI / 2 - 0.02;

// Lighting
scene.add(new THREE.AmbientLight(0xcbd5e1, 0.7));
const dirLight = new THREE.DirectionalLight(0xffffff, 1.15);
dirLight.position.set(10, 22, 12);
scene.add(dirLight);
const rimLight = new THREE.DirectionalLight(0x38bdf8, 0.45);
rimLight.position.set(-14, 10, -10);
scene.add(rimLight);

// State
let specData = null;
let arenaHandle = null;
let currentScenario = null;
let replaySession = null;
let liveWs = null;
let liveAgents = {};
let mode = "SCENARIO"; // "SCENARIO" | "REPLAY" | "LIVE"
let simTime = 0;
let playing = false;
let lastFrameTime = performance.now();

const actors = {
  "UAV-A": createUavActor("UAV-A", 0x06b6d4, false),
  "UAV-B": createUavActor("UAV-B", 0xf59e0b, false),
  "GT-A": createUavActor("GT-A", 0xf43f5e, true),
  "GT-B": createUavActor("GT-B", 0xf43f5e, true),
};
Object.values(actors).forEach((a) => {
  a.root.visible = false;
  scene.add(a.root);
});

// Visual overlays for trails, separation line, error lines, relay cargo, dropped balls
const trailGroup = new THREE.Group();
scene.add(trailGroup);

const sepLineGeo = new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]);
const sepLineMat = new THREE.LineBasicMaterial({ color: 0x10b981 });
const sepLine = new THREE.Line(sepLineGeo, sepLineMat);
sepLine.visible = false;
scene.add(sepLine);

const errLines = [0, 1].map(() => {
  const geo = new THREE.BufferGeometry().setFromPoints([new THREE.Vector3(), new THREE.Vector3()]);
  const line = new THREE.Line(geo, new THREE.LineBasicMaterial({ color: 0xf43f5e }));
  line.visible = false;
  scene.add(line);
  return line;
});

const relayCargoMesh = new THREE.Mesh(
  new THREE.BoxGeometry(0.3, 0.3, 0.3),
  new THREE.MeshStandardMaterial({ color: 0xea580c, roughness: 0.45 })
);
relayCargoMesh.position.copy(enuToThree(0, 0, 0.25));
relayCargoMesh.visible = false;
scene.add(relayCargoMesh);

const ballPool = [];
for (let i = 0; i < 6; i++) {
  const ball = new THREE.Mesh(
    new THREE.SphereGeometry(0.045, 12, 12),
    new THREE.MeshStandardMaterial({ color: 0xccff00, emissive: 0x3f6212 })
  );
  ball.visible = false;
  scene.add(ball);
  ballPool.push(ball);
}

function setCameraPreset(preset) {
  if (preset === "overview") {
    controls.enabled = true;
    camera.position.set(0, 14.5, 20.5);
    controls.target.set(0, 1.4, 0);
    controls.update();
  } else if (preset === "top") {
    controls.enabled = true;
    camera.position.set(0, 26, 0.01);
    controls.target.set(0, 0, 0);
    controls.update();
  } else {
    controls.enabled = false;
  }
}

function rebuildPlannedTrails() {
  while (trailGroup.children.length > 0) {
    trailGroup.remove(trailGroup.children[0]);
  }
  if (!currentScenario || mode !== "SCENARIO") return;

  currentScenario.uavs.forEach((u) => {
    const pts = u.waypoints.map((w) => enuToThree(w.pos[0], w.pos[1], w.pos[2]));
    const geo = new THREE.BufferGeometry().setFromPoints(pts);
    const line = new THREE.Line(
      geo,
      new THREE.LineDashedMaterial({ color: u.color, dashSize: 0.35, gapSize: 0.2, transparent: true, opacity: 0.55 })
    );
    line.computeLineDistances();
    trailGroup.add(line);
  });
}

function selectScenario(id) {
  mode = "SCENARIO";
  replaySession = null;
  currentScenario = specData.scenarios.find((s) => s.id === id) || specData.scenarios[0];
  simTime = 0;
  playing = true;
  btnPlayPause.textContent = "⏸ Tạm dừng";
  timeSlider.max = currentScenario.duration;
  timeSlider.value = 0;
  scenarioDesc.textContent = currentScenario.subtitle;
  replayStatusEl.textContent = `Kịch bản MATLAB: ${currentScenario.name}`;
  actors["GT-A"].root.visible = false;
  actors["GT-B"].root.visible = false;
  errLines.forEach((l) => (l.visible = false));
  rebuildPlannedTrails();
}

function updateActiveCamera() {
  const preset = cameraSelect.value;
  if (preset === "follow_a" && actors["UAV-A"].root.visible) {
    const p = actors["UAV-A"].root.position;
    camera.position.set(p.x - 3.6, p.y + 2.2, p.z + 3.6);
    camera.lookAt(p);
  } else if (preset === "follow_b" && actors["UAV-B"].root.visible) {
    const p = actors["UAV-B"].root.position;
    camera.position.set(p.x - 3.6, p.y + 2.2, p.z + 3.6);
    camera.lookAt(p);
  }
}

function renderTelemetryHtml(rows) {
  telemetryList.innerHTML = rows
    .map(
      (r) => `
    <div class="telem-item">
      <div class="telem-head">
        <span style="color:${r.color}">${r.title}</span>
        <span>${r.badge}</span>
      </div>
      <div class="telem-coords">
        X=${r.pos[0].toFixed(2)}m &nbsp; Y=${r.pos[1].toFixed(2)}m &nbsp; Z=${r.pos[2].toFixed(2)}m
      </div>
    </div>`
    )
    .join("");
}

function renderEventsHtml(events, warnings) {
  const items = [
    ...warnings.map((w) => `<li class="danger">⚠ ${w}</li>`),
    ...events.slice(-8).reverse().map((ev) => {
      const cls = ev.type?.includes("TIMEOUT_EXPIRED") ? "warn" : ev.points > 0 ? "ok" : "";
      return `<li class="${cls}"><strong>[${ev.t.toFixed(1)}s]</strong> ${ev.label}${ev.points ? ` (+${ev.points}đ)` : ""}</li>`;
    }),
  ];
  eventLogEl.innerHTML = items.join("") || `<li class="muted">Chưa có sự kiện...</li>`;
}

function stepSimulation(dt) {
  const speed = Number(speedSelect.value || 1);

  if (mode === "SCENARIO" && currentScenario) {
    if (playing) {
      simTime += dt * speed;
      if (simTime >= currentScenario.duration) {
        simTime = currentScenario.duration;
        playing = false;
        btnPlayPause.textContent = "▶ Chạy";
      }
      timeSlider.value = simTime.toFixed(1);
    }

    const res = evaluateScenarioAtTime(currentScenario, specData.arena, simTime);
    const activeIds = Object.keys(res.uavStates);
    actors["UAV-A"].root.visible = Boolean(res.uavStates["UAV-A"]);
    actors["UAV-B"].root.visible = Boolean(res.uavStates["UAV-B"]);

    const telemRows = [];
    for (const id of activeIds) {
      const st = res.uavStates[id];
      const actor = actors[id];
      actor.root.position.copy(enuToThree(st.pos[0], st.pos[1], st.pos[2]));
      actor.root.rotation.y = st.yaw;
      actor.spinRotors(dt, st.moving);
      actor.carriedCargo.visible = res.cargoCarriedBy === id;
      actor.haloRing.visible = document.getElementById("chkSafetyHalo").checked;

      const hasDanger = res.warnings.some((w) => w.includes("D_MIN") || w.includes(id));
      actor.setHaloAlert(hasDanger ? "danger" : "ok");

      telemRows.push({
        title: st.label,
        color: st.color,
        badge: `${st.state} / ${st.intent}`,
        pos: st.pos,
      });
    }

    // Pedestal cargo visibility & D3 relay cargo
    Object.entries(arenaHandle.groups.cargoOnPedestals).forEach(([pedId, mesh]) => {
      mesh.visible = !res.pickedPedestals.has(pedId);
    });
    relayCargoMesh.visible = res.relayCargoAtD3;

    // Dropped tennis balls in Phase 2
    ballPool.forEach((b, idx) => {
      const ev = res.droppedBalls[idx];
      if (ev) {
        b.visible = true;
        b.position.copy(enuToThree(ev.pos[0], ev.pos[1], ev.pos[2]));
      } else {
        b.visible = false;
      }
    });

    // Mobile Receiver D2
    if (arenaHandle.mobileCartGroup) {
      arenaHandle.mobileCartGroup.position.copy(enuToThree(res.cartPos[0], res.cartPos[1], 0));
    }

    // Separation line between UAV-A and UAV-B
    if (activeIds.length >= 2) {
      sepLine.visible = true;
      const pA = actors["UAV-A"].root.position;
      const pB = actors["UAV-B"].root.position;
      sepLine.geometry.setFromPoints([pA, pB]);
      sepLineMat.color.setHex(res.minSeparation < specData.arena.d_min_m ? 0xef4444 : 0x10b981);
    } else {
      sepLine.visible = false;
    }

    // HUD updates
    hudTime.textContent = `${simTime.toFixed(1)} / ${currentScenario.duration.toFixed(1)} s`;
    hudScore.textContent = `${res.score} / ${currentScenario.max_score} đ`;
    hudCabp.textContent = res.cabpStatus;

    if (res.warnings.length > 0) {
      hudSafety.className = "hud-value danger mono";
      hudSafety.textContent = res.warnings[0];
    } else if (Number.isFinite(res.minSeparation)) {
      hudSafety.className = "hud-value ok mono";
      hudSafety.textContent = `ĐẠT • d = ${res.minSeparation.toFixed(2)} m (≥ 1.5m)`;
    } else {
      hudSafety.className = "hud-value ok mono";
      hudSafety.textContent = "ĐẠT • Trong vùng an toàn";
    }

    renderTelemetryHtml(telemRows);
    renderEventsHtml(res.triggeredEvents, res.warnings);
  } else if (mode === "REPLAY" && replaySession) {
    if (playing) {
      simTime += dt * speed;
      if (simTime >= replaySession.duration) {
        simTime = replaySession.duration;
        playing = false;
        btnPlayPause.textContent = "▶ Chạy";
      }
      timeSlider.value = simTime.toFixed(1);
    }

    const r = replaySession.evaluateAt(simTime, specData.arena.d_min_m);
    const telemRows = [];
    const estKeys = ["UAV-A", "UAV-B"];
    const gtKeys = ["GT-A", "GT-B"];
    const colors = ["#06b6d4", "#f59e0b"];

    replaySession.agentIds.slice(0, 2).forEach((aid, idx) => {
      const aEst = actors[estKeys[idx]];
      const aGt = actors[gtKeys[idx]];
      const stEst = r.est[aid];
      const stGt = r.gt[aid];

      if (stEst) {
        aEst.root.visible = true;
        aEst.root.position.copy(enuToThree(stEst.pos[0], stEst.pos[1], stEst.pos[2]));
        aEst.spinRotors(dt, stEst.moving);
        aEst.setHaloAlert(r.sepEst < specData.arena.d_min_m ? "danger" : "ok");
        telemRows.push({
          title: `CABP Est #${aid}`,
          color: colors[idx],
          badge: r.errors[aid] !== undefined ? `err=${r.errors[aid].toFixed(2)}m` : stEst.state,
          pos: stEst.pos,
        });
      }
      if (stGt) {
        aGt.root.visible = true;
        aGt.root.position.copy(enuToThree(stGt.pos[0], stGt.pos[1], stGt.pos[2]));
        telemRows.push({
          title: `BOC GT #${aid}`,
          color: "#fb7185",
          badge: "6-Cam AprilTag",
          pos: stGt.pos,
        });
      }
      if (stEst && stGt) {
        errLines[idx].visible = true;
        errLines[idx].geometry.setFromPoints([aEst.root.position, aGt.root.position]);
      } else {
        errLines[idx].visible = false;
      }
    });

    if (replaySession.agentIds.length >= 2 && actors["UAV-A"].root.visible && actors["UAV-B"].root.visible) {
      sepLine.visible = true;
      sepLine.geometry.setFromPoints([actors["UAV-A"].root.position, actors["UAV-B"].root.position]);
      sepLineMat.color.setHex(r.sepEst < specData.arena.d_min_m || r.sepGt < specData.arena.d_min_m ? 0xef4444 : 0x10b981);
    }

    hudTime.textContent = `${simTime.toFixed(1)} / ${replaySession.duration.toFixed(1)} s`;
    hudScore.textContent = "WS5 REPLAY";
    hudCabp.textContent = "SEPARATED FRAMES";
    if (r.warnings.length > 0) {
      hudSafety.className = "hud-value danger mono";
      hudSafety.textContent = r.warnings[0];
    } else {
      hudSafety.className = "hud-value ok mono";
      hudSafety.textContent = `Est=${r.sepEst.toFixed(2)}m | GT=${r.sepGt.toFixed(2)}m`;
    }
    renderTelemetryHtml(telemRows);
    renderEventsHtml(replaySession.events.filter((e) => e.t <= simTime), r.warnings);
  } else if (mode === "LIVE") {
    const keys = Object.keys(liveAgents).slice(0, 2);
    const slotNames = ["UAV-A", "UAV-B"];
    const telemRows = [];
    keys.forEach((aid, idx) => {
      const rec = liveAgents[aid];
      const actor = actors[slotNames[idx]];
      actor.root.visible = true;
      actor.root.position.copy(enuToThree(rec.pos[0], rec.pos[1], rec.pos[2]));
      actor.spinRotors(dt, rec.pos[2] > 0.2);
      telemRows.push({
        title: `LIVE CABP #${aid}`,
        color: idx === 0 ? "#06b6d4" : "#f59e0b",
        badge: `${rec.state || "?"} / ${rec.intent || "?"}`,
        pos: rec.pos,
      });
    });
    renderTelemetryHtml(telemRows);
  }
}

function animate(now) {
  requestAnimationFrame(animate);
  const dt = Math.min((now - lastFrameTime) / 1000, 0.1);
  lastFrameTime = now;

  stepSimulation(dt);
  updateActiveCamera();
  controls.update();

  // Choose active main camera
  const camPreset = cameraSelect.value;
  let activeCam = camera;
  if (camPreset === "downward_a" && actors["UAV-A"].root.visible) {
    activeCam = actors["UAV-A"].downwardCam;
  } else if (camPreset === "downward_b" && actors["UAV-B"].root.visible) {
    activeCam = actors["UAV-B"].downwardCam;
  }
  renderer.render(scene, activeCam);

  // PIP Downward CV Camera
  if (!pipContainerEl.classList.contains("hidden")) {
    const pipActor = actors["UAV-B"].root.visible && currentScenario?.id?.startsWith("coop")
      ? actors["UAV-B"]
      : actors["UAV-A"];
    document.getElementById("pipTargetLabel").textContent = pipActor.id;
    pipRenderer.render(scene, pipActor.downwardCam);
  }
}

async function init() {
  const resp = await fetch("./data/scenarios.json");
  specData = await resp.json();
  arenaHandle = buildArena(scene, specData.arena);

  specData.scenarios.forEach((sc) => {
    const opt = document.createElement("option");
    opt.value = sc.id;
    opt.textContent = sc.name;
    scenarioSelect.appendChild(opt);
  });

  selectScenario(specData.scenarios[0].id);

  // UI Listeners
  scenarioSelect.addEventListener("change", (e) => selectScenario(e.target.value));
  cameraSelect.addEventListener("change", (e) => setCameraPreset(e.target.value));
  btnResetView.addEventListener("click", () => {
    cameraSelect.value = "overview";
    setCameraPreset("overview");
  });

  btnPlayPause.addEventListener("click", () => {
    playing = !playing;
    btnPlayPause.textContent = playing ? "⏸ Tạm dừng" : "▶ Chạy";
  });
  btnRestart.addEventListener("click", () => {
    simTime = 0;
    timeSlider.value = 0;
    playing = true;
    btnPlayPause.textContent = "⏸ Tạm dừng";
  });
  timeSlider.addEventListener("input", (e) => {
    simTime = Number(e.target.value);
  });

  // Technical layer toggles
  document.getElementById("chkNetting").addEventListener("change", (e) => {
    arenaHandle.groups.netting.visible = e.target.checked;
  });
  document.getElementById("chkAltBand").addEventListener("change", (e) => {
    arenaHandle.groups.altitudeBand.visible = e.target.checked;
  });
  document.getElementById("chkCameras").addEventListener("change", (e) => {
    arenaHandle.groups.cameras.visible = e.target.checked;
  });
  document.getElementById("chkUwb").addEventListener("change", (e) => {
    arenaHandle.groups.uwb.visible = e.target.checked;
  });
  document.getElementById("chkTrails").addEventListener("change", (e) => {
    trailGroup.visible = e.target.checked;
  });
  document.getElementById("chkPipCam").addEventListener("change", (e) => {
    pipContainerEl.classList.toggle("hidden", !e.target.checked);
  });

  // WS5 Replay Uploaders
  let uploadedCabpText = "";
  let uploadedGtText = "";

  const startReplay = (cabpTxt, gtTxt, label) => {
    replaySession = buildReplaySession(cabpTxt, gtTxt);
    mode = "REPLAY";
    simTime = 0;
    playing = true;
    btnPlayPause.textContent = "⏸ Tạm dừng";
    timeSlider.max = replaySession.duration;
    timeSlider.value = 0;
    scenarioDesc.textContent = label;
    replayStatusEl.textContent = label;
    trailGroup.visible = false;
  };

  document.getElementById("fileCabpLog").addEventListener("change", async (e) => {
    const f = e.target.files?.[0];
    if (!f) return;
    uploadedCabpText = await f.text();
    startReplay(uploadedCabpText, uploadedGtText, `WS5 Replay: ${f.name}`);
  });

  document.getElementById("fileGtLog").addEventListener("change", async (e) => {
    const f = e.target.files?.[0];
    if (!f) return;
    uploadedGtText = await f.text();
    if (uploadedCabpText) {
      startReplay(uploadedCabpText, uploadedGtText, `WS5 Replay (CABP + Ground Truth: ${f.name})`);
    } else {
      replayStatusEl.textContent = `Đã nạp GT (${f.name}), chờ file CABP Log...`;
    }
  });

  document.getElementById("btnLoadSampleReplay").addEventListener("click", async () => {
    const [rCabp, rGt] = await Promise.all([
      fetch("./data/sample_cabp_log.jsonl"),
      fetch("./data/sample_ground_truth.jsonl"),
    ]);
    uploadedCabpText = await rCabp.text();
    uploadedGtText = await rGt.text();
    startReplay(
      uploadedCabpText,
      uploadedGtText,
      "Mẫu WS5 Replay: CABP Estimated vs BOC Ground Truth (Phát hiện vi phạm D_MIN tại t≈8s)"
    );
  });

  document.getElementById("btnLiveBridge").addEventListener("click", () => {
    if (liveWs && liveWs.readyState === WebSocket.OPEN) {
      liveWs.close();
      return;
    }
    try {
      liveWs = new WebSocket("ws://127.0.0.1:8765");
      liveWs.onopen = () => {
        mode = "LIVE";
        playing = false;
        liveAgents = {};
        replayStatusEl.textContent = "Đã kết nối Live CABP Bridge (ws://127.0.0.1:8765)";
        hudCabp.textContent = "LIVE UDP 14555";
      };
      liveWs.onmessage = (msg) => {
        const payload = JSON.parse(msg.data);
        if (payload.msg_type === "PERIODIC_BEACON") {
          liveAgents[payload.agent_id] = {
            pos: payload.position,
            state: payload.state_name || String(payload.state),
            intent: payload.intent_name || String(payload.intent),
          };
        } else if (payload.msg_type === "MISSION_EVENT") {
          hudCabp.textContent = `EVENT: ${payload.event_name} @ D${payload.location_id}`;
        }
      };
      liveWs.onerror = () => {
        replayStatusEl.textContent = "Không kết nối được bridge (chạy python bridge/cabp_ws_bridge.py trước).";
      };
      liveWs.onclose = () => {
        if (mode === "LIVE") replayStatusEl.textContent = "Đã ngắt kết nối Live CABP Bridge.";
      };
    } catch (err) {
      replayStatusEl.textContent = `Lỗi WebSocket: ${err.message}`;
    }
  });

  window.addEventListener("resize", () => {
    camera.aspect = viewportEl.clientWidth / viewportEl.clientHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(viewportEl.clientWidth, viewportEl.clientHeight);
  });

  requestAnimationFrame(animate);
}

init();
