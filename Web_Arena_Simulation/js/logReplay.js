import { distance3D, sampleWaypoints } from "./trajectoryEngine.js";

/**
 * Parses separated JSONL logs for WS5 Post-Match Replay:
 * - CABP log: Estimated_Position & mission_event (Agent Reference Frame)
 * - Ground Truth log: BOC 6-Camera Overhead AprilTag (Ground Reference Frame)
 */
export function parseJsonl(text) {
  return text
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter((line) => line.length > 0 && !line.startsWith("#"))
    .map((line) => JSON.parse(line));
}

export function buildReplaySession(cabpText, gtText) {
  const cabpRecords = parseJsonl(cabpText);
  const gtRecords = gtText ? parseJsonl(gtText) : [];

  const estByAgent = {};
  const gtByAgent = {};
  const events = [];
  let maxT = 0;

  for (const rec of cabpRecords) {
    maxT = Math.max(maxT, Number(rec.t || 0));
    const aid = String(rec.agent_id ?? "101");
    if (rec.source === "CABP_EVENT" || rec.event_type) {
      events.push({
        t: Number(rec.t),
        type: "CABP_TX",
        label: `[CABP EVENT] Agent #${aid}: ${rec.event_type} @ D${rec.location_id}`,
        points: 0,
      });
    } else if (Array.isArray(rec.pos)) {
      if (!estByAgent[aid]) estByAgent[aid] = [];
      estByAgent[aid].push({
        t: Number(rec.t),
        pos: rec.pos.map(Number),
        state: rec.state || "EXECUTING",
        intent: rec.intent || "GO_TO_POINT",
      });
    }
  }

  for (const rec of gtRecords) {
    maxT = Math.max(maxT, Number(rec.t || 0));
    const aid = String(rec.agent_id ?? "101");
    if (Array.isArray(rec.pos)) {
      if (!gtByAgent[aid]) gtByAgent[aid] = [];
      gtByAgent[aid].push({
        t: Number(rec.t),
        pos: rec.pos.map(Number),
        state: "GROUND_TRUTH",
        intent: "BOC_CAM",
      });
    }
  }

  Object.values(estByAgent).forEach((arr) => arr.sort((a, b) => a.t - b.t));
  Object.values(gtByAgent).forEach((arr) => arr.sort((a, b) => a.t - b.t));

  const agentIds = Array.from(new Set([...Object.keys(estByAgent), ...Object.keys(gtByAgent)])).sort();

  return {
    duration: Math.max(maxT, 1.0),
    agentIds,
    estByAgent,
    gtByAgent,
    events,
    evaluateAt(t, dMin = 1.5) {
      const est = {};
      const gt = {};
      const errors = {};
      for (const aid of agentIds) {
        if (estByAgent[aid]) est[aid] = sampleWaypoints(estByAgent[aid], t);
        if (gtByAgent[aid]) gt[aid] = sampleWaypoints(gtByAgent[aid], t);
        if (est[aid] && gt[aid]) {
          errors[aid] = distance3D(est[aid].pos, gt[aid].pos);
        }
      }

      let sepEst = Infinity;
      let sepGt = Infinity;
      if (agentIds.length >= 2) {
        const a = agentIds[0];
        const b = agentIds[1];
        if (est[a] && est[b]) sepEst = distance3D(est[a].pos, est[b].pos);
        if (gt[a] && gt[b]) sepGt = distance3D(gt[a].pos, gt[b].pos);
      }

      const warnings = [];
      if (sepEst < dMin) {
        warnings.push(`CABP Est D_MIN < ${dMin}m (${sepEst.toFixed(2)}m)`);
      }
      if (sepGt < dMin) {
        warnings.push(`BOC Ground Truth D_MIN < ${dMin}m (${sepGt.toFixed(2)}m)`);
      }

      return { est, gt, errors, sepEst, sepGt, warnings };
    },
  };
}
