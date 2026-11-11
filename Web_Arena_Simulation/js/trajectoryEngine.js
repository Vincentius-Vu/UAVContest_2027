/**
 * Interpolates ENU positions, velocity vectors, yaw headings, and evaluates
 * UAV Contest 2027 safety & scoring rules at simulation time `t`.
 */

export function sampleWaypoints(waypoints, t) {
  if (!waypoints || waypoints.length === 0) {
    return { pos: [0, 0, 0], vel: [0, 0, 0], yaw: 0, state: "IDLE", intent: "HOVER", moving: false };
  }
  if (t <= waypoints[0].t) {
    const wp = waypoints[0];
    return { pos: [...wp.pos], vel: [0, 0, 0], yaw: 0, state: wp.state || "IDLE", intent: wp.intent || "HOVER", moving: false };
  }
  const last = waypoints[waypoints.length - 1];
  if (t >= last.t) {
    return { pos: [...last.pos], vel: [0, 0, 0], yaw: 0, state: last.state || "IDLE", intent: last.intent || "HOVER", moving: false };
  }

  for (let i = 0; i < waypoints.length - 1; i++) {
    const a = waypoints[i];
    const b = waypoints[i + 1];
    if (t >= a.t && t <= b.t) {
      const dt = Math.max(b.t - a.t, 1e-4);
      const u = (t - a.t) / dt;
      const pos = [
        a.pos[0] + (b.pos[0] - a.pos[0]) * u,
        a.pos[1] + (b.pos[1] - a.pos[1]) * u,
        a.pos[2] + (b.pos[2] - a.pos[2]) * u,
      ];
      const vel = [
        (b.pos[0] - a.pos[0]) / dt,
        (b.pos[1] - a.pos[1]) / dt,
        (b.pos[2] - a.pos[2]) / dt,
      ];
      const horizSpeed = Math.hypot(vel[0], vel[1]);
      const yaw = horizSpeed > 0.05 ? Math.atan2(vel[1], vel[0]) : 0;
      const moving = pos[2] > 0.2 || Math.hypot(vel[0], vel[1], vel[2]) > 0.02;
      return {
        pos,
        vel,
        yaw,
        state: b.state || a.state || "EXECUTING",
        intent: b.intent || a.intent || "GO_TO_POINT",
        moving,
      };
    }
  }
  return { pos: [...last.pos], vel: [0, 0, 0], yaw: 0, state: "IDLE", intent: "HOVER", moving: false };
}

export function distance3D(p1, p2) {
  return Math.hypot(p1[0] - p2[0], p1[1] - p2[1], p1[2] - p2[2]);
}

export function evaluateScenarioAtTime(scenario, arenaSpec, t) {
  const uavStates = {};
  scenario.uavs.forEach((u) => {
    uavStates[u.id] = {
      ...sampleWaypoints(u.waypoints, t),
      id: u.id,
      label: u.label,
      color: u.color,
    };
  });

  // Mobile Receiver position
  let cartPos = [-3.0, 1.8, 0.08];
  if (scenario.mobile_receiver_active && scenario.mobile_cart) {
    cartPos = sampleWaypoints(scenario.mobile_cart, t).pos;
  }

  // Score & Event State
  let score = 0;
  const triggeredEvents = [];
  let cargoCarriedBy = null;
  const pickedPedestals = new Set();
  const droppedBalls = [];
  let relayCargoAtD3 = false;
  let cabpStatus = "STANDBY (5 Hz)";

  for (const ev of scenario.events || []) {
    if (ev.t <= t) {
      triggeredEvents.push(ev);
      if (ev.points) score += ev.points;
      if (ev.type === "CARGO_PICKUP") {
        cargoCarriedBy = ev.uav;
        if (ev.pedestal && ev.pedestal !== "D3") pickedPedestals.add(ev.pedestal);
        if (ev.pedestal === "D3") relayCargoAtD3 = false;
      } else if (ev.type === "CARGO_DROP") {
        cargoCarriedBy = null;
      } else if (ev.type === "CABP_TX") {
        cargoCarriedBy = null;
        relayCargoAtD3 = true;
        cabpStatus = "TX mission_event (D3)";
      } else if (ev.type === "CABP_RX") {
        cabpStatus = "RX OK (<3.0s) • BONUS";
      } else if (ev.type === "CABP_TIMEOUT_START") {
        cargoCarriedBy = null;
        relayCargoAtD3 = true;
        const rem = Math.max(0, 3.0 - (t - ev.t)).toFixed(1);
        cabpStatus = `WAITING CABP (${rem}s)`;
      } else if (ev.type === "CABP_TIMEOUT_EXPIRED") {
        cabpStatus = "TIMEOUT >3.0s • FALLBACK QR";
      } else if (ev.type === "BALL_DROP") {
        droppedBalls.push(ev);
      }
    }
  }

  // Safety checks
  const warnings = [];
  let minSeparation = Infinity;

  const ids = Object.keys(uavStates);
  if (ids.length >= 2) {
    minSeparation = distance3D(uavStates[ids[0]].pos, uavStates[ids[1]].pos);
    if (minSeparation < arenaSpec.d_min_m) {
      warnings.push(`VI PHẠM D_MIN: ${minSeparation.toFixed(2)} m < ${arenaSpec.d_min_m} m (-20đ & Dừng trận)`);
    }
  }

  for (const id of ids) {
    const st = uavStates[id];
    const [x, y, z] = st.pos;
    if (Math.abs(x) > arenaSpec.length_x_m / 2 || Math.abs(y) > arenaSpec.width_y_m / 2) {
      warnings.push(`${id}: Ra ngoài ranh giới sân 12×24 m`);
    }
    if (z > arenaSpec.ceiling_z_m) {
      warnings.push(`${id}: Vượt trần lưới ${arenaSpec.ceiling_z_m} m`);
    }
    if (scenario.enforce_altitude_band && st.state === "EXECUTING" && z < arenaSpec.phase2_min_z_m) {
      warnings.push(`${id}: Bay dưới trần tự động Pha 2 (${z.toFixed(2)} m < 3.0 m)`);
    }
  }

  return {
    uavStates,
    cartPos,
    score,
    triggeredEvents,
    cargoCarriedBy,
    pickedPedestals,
    droppedBalls,
    relayCargoAtD3,
    cabpStatus,
    minSeparation,
    warnings,
  };
}
