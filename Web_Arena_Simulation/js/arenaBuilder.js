import * as THREE from "three";

/**
 * ENU (MATLAB / Official Rules) -> Three.js (Y-up right-handed):
 *   X_three = X_enu  (Arena length: -12 .. +12 m)
 *   Y_three = Z_enu  (Altitude: 0 .. 5 m)
 *   Z_three = -Y_enu (Arena width: -6 .. +6 m, negated to preserve right-handed yaw)
 */
export function enuToThree(x, y, z = 0) {
  return new THREE.Vector3(x, z, -y);
}

function createLabelSprite(text, color = "#e2e8f0", bg = "rgba(6, 11, 22, 0.85)", scale = 1.2) {
  const canvas = document.createElement("canvas");
  canvas.width = 256;
  canvas.height = 64;
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = bg;
  ctx.beginPath();
  ctx.roundRect(6, 6, 244, 52, 10);
  ctx.fill();
  ctx.strokeStyle = color;
  ctx.lineWidth = 3;
  ctx.stroke();

  ctx.fillStyle = color;
  ctx.font = "bold 26px Consolas, monospace";
  ctx.textAlign = "center";
  ctx.textBaseline = "middle";
  ctx.fillText(text, 128, 33);

  const texture = new THREE.CanvasTexture(canvas);
  const mat = new THREE.SpriteMaterial({ map: texture, transparent: true, depthTest: false });
  const sprite = new THREE.Sprite(mat);
  sprite.scale.set(scale * 1.4, scale * 0.35, 1);
  return sprite;
}

/**
 * Deterministic high-contrast 15x15cm QR-style marker texture encoding target label ("D1".."D5").
 */
function createQrTexture(label) {
  const canvas = document.createElement("canvas");
  canvas.width = 128;
  canvas.height = 128;
  const ctx = canvas.getContext("2d");
  ctx.fillStyle = "#ffffff";
  ctx.fillRect(0, 0, 128, 128);

  const grid = 13;
  const cell = 8;
  const pad = 12;
  const seed = label.split("").reduce((acc, ch) => acc + ch.charCodeAt(0) * 31, 7);

  const drawFinder = (gx, gy) => {
    ctx.fillStyle = "#000000";
    ctx.fillRect(pad + gx * cell, pad + gy * cell, 3 * cell, 3 * cell);
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(pad + (gx + 0.6) * cell, pad + (gy + 0.6) * cell, 1.8 * cell, 1.8 * cell);
    ctx.fillStyle = "#000000";
    ctx.fillRect(pad + (gx + 1) * cell, pad + (gy + 1) * cell, cell, cell);
  };

  drawFinder(0, 0);
  drawFinder(grid - 3, 0);
  drawFinder(0, grid - 3);

  ctx.fillStyle = "#000000";
  for (let r = 0; r < grid; r++) {
    for (let c = 0; c < grid; c++) {
      const inFinder =
        (r < 4 && c < 4) || (r < 4 && c >= grid - 4) || (r >= grid - 4 && c < 4);
      if (inFinder) continue;
      if (((r * 17 + c * 29 + seed) % 11) < 5) {
        ctx.fillRect(pad + c * cell, pad + r * cell, cell, cell);
      }
    }
  }

  const tex = new THREE.CanvasTexture(canvas);
  tex.magFilter = THREE.NearestFilter;
  return tex;
}

export function buildArena(scene, arenaSpec) {
  const groups = {
    root: new THREE.Group(),
    netting: new THREE.Group(),
    altitudeBand: new THREE.Group(),
    cameras: new THREE.Group(),
    uwb: new THREE.Group(),
    cargoOnPedestals: {},
    dynamicObjects: new THREE.Group(),
  };

  // 1. Floor (24m x 12m) + Grid
  const floorGeo = new THREE.BoxGeometry(arenaSpec.length_x_m, 0.06, arenaSpec.width_y_m);
  const floorMat = new THREE.MeshStandardMaterial({ color: 0x161f30, roughness: 0.88, metalness: 0.1 });
  const floor = new THREE.Mesh(floorGeo, floorMat);
  floor.position.set(0, -0.03, 0);
  floor.receiveShadow = true;
  groups.root.add(floor);

  const grid = new THREE.GridHelper(24, 24, 0x263b5e, 0x1a2842);
  grid.position.y = 0.002;
  groups.root.add(grid);

  // 2. Zone overlays (Depot, Pickup, Relay)
  const addZone = (zSpec, colorHex, labelText) => {
    const wX = zSpec.x_max - zSpec.x_min;
    const wY = zSpec.y_max - zSpec.y_min;
    const cx = (zSpec.x_min + zSpec.x_max) / 2;
    const cy = (zSpec.y_min + zSpec.y_max) / 2;
    const mesh = new THREE.Mesh(
      new THREE.PlaneGeometry(wX, wY),
      new THREE.MeshStandardMaterial({ color: colorHex, transparent: true, opacity: 0.42, roughness: 0.9 })
    );
    mesh.rotation.x = -Math.PI / 2;
    mesh.position.copy(enuToThree(cx, cy, 0.006));
    groups.root.add(mesh);

    const lbl = createLabelSprite(labelText, "#ffffff", "rgba(10,18,34,0.8)", 1.3);
    lbl.position.copy(enuToThree(cx, cy, 0.25));
    groups.root.add(lbl);
  };

  addZone(arenaSpec.depot, 0x1d4ed8, "DEPOT (12×3.5m)");
  addZone(arenaSpec.pickup, 0x7e22ce, "PICKUP (12×4.5m)");
  addZone(arenaSpec.relay, 0x047857, "RELAY ZONE");

  // Depot Pads (Pad A at Y=-2.5, Pad B at Y=+2.5, Center Pad at Y=0)
  [
    { name: "PAD-A", x: -10.0, y: -2.5, color: 0x06b6d4 },
    { name: "PAD-0", x: -10.0, y: 0.0, color: 0x64748b },
    { name: "PAD-B", x: -10.0, y: 2.5, color: 0xf59e0b },
  ].forEach((p) => {
    const pad = new THREE.Mesh(
      new THREE.CylinderGeometry(0.48, 0.52, 0.04, 24),
      new THREE.MeshStandardMaterial({ color: p.color, roughness: 0.5 })
    );
    pad.position.copy(enuToThree(p.x, p.y, 0.02));
    groups.root.add(pad);
  });

  // 3. Pickup Pedestals P1-P3 (1.0 x 1.0 x 1.0m) + 0.3m Cargo Cubes
  const pedMat = new THREE.MeshStandardMaterial({ color: 0x64748b, roughness: 0.65 });
  const cargoMat = new THREE.MeshStandardMaterial({ color: 0xea580c, roughness: 0.45 });
  arenaSpec.pedestals.forEach((ped) => {
    const mesh = new THREE.Mesh(new THREE.BoxGeometry(1.0, 1.0, 1.0), pedMat);
    mesh.position.copy(enuToThree(ped.x, ped.y, 0.5));
    groups.root.add(mesh);

    const cargo = new THREE.Mesh(new THREE.BoxGeometry(0.3, 0.3, 0.3), cargoMat);
    cargo.position.copy(enuToThree(ped.x, ped.y, 1.15));
    groups.root.add(cargo);
    groups.cargoOnPedestals[ped.id] = cargo;

    const lbl = createLabelSprite(ped.id, "#fbbf24", "rgba(15,23,42,0.85)", 0.75);
    lbl.position.copy(enuToThree(ped.x, ped.y, 1.55));
    groups.root.add(lbl);
  });

  // 4. ACC1-ACC4 Circular Gates (Inner diam 1.6m -> r=0.8m, center Z=1.7m, top 2.6m)
  const gateRingMat = new THREE.MeshStandardMaterial({
    color: 0x06b6d4,
    emissive: 0x083344,
    roughness: 0.3,
    metalness: 0.4,
  });
  const postMat = new THREE.MeshStandardMaterial({ color: 0x475569, metalness: 0.5, roughness: 0.5 });

  arenaSpec.acc_gates.forEach((gate) => {
    const gGroup = new THREE.Group();
    const rInner = gate.inner_diameter / 2; // 0.8 m
    const tubeR = 0.05;
    const torus = new THREE.Mesh(new THREE.TorusGeometry(rInner + tubeR, tubeR, 14, 36), gateRingMat);
    // Gate plane is normal to X axis (flights along X)
    torus.rotation.y = Math.PI / 2;
    torus.position.copy(enuToThree(gate.x, gate.y, gate.z));
    gGroup.add(torus);

    // Two vertical supporting legs from floor to gate sides
    [-rInner - 0.08, rInner + 0.08].forEach((dy) => {
      const leg = new THREE.Mesh(new THREE.CylinderGeometry(0.035, 0.035, gate.top_z, 10), postMat);
      leg.position.copy(enuToThree(gate.x, gate.y + dy, gate.top_z / 2));
      gGroup.add(leg);
    });

    const lbl = createLabelSprite(`${gate.id} (Ø${gate.inner_diameter}m)`, "#22d3ee", "rgba(6,11,22,0.85)", 0.9);
    lbl.position.copy(enuToThree(gate.x, gate.y, gate.top_z + 0.3));
    gGroup.add(lbl);

    groups.root.add(gGroup);
  });

  // 5. Delivery Points D1-D5 (with QR 15x15cm) + Mobile Receiver Cart
  let mobileCartGroup = null;
  arenaSpec.delivery_points.forEach((dp) => {
    const r = dp.diameter / 2;
    const disc = new THREE.Mesh(
      new THREE.CylinderGeometry(r, r, 0.04, 32),
      new THREE.MeshStandardMaterial({ color: dp.color, roughness: 0.45 })
    );
    const qrMesh = new THREE.Mesh(
      new THREE.PlaneGeometry(0.15, 0.15),
      new THREE.MeshBasicMaterial({ map: createQrTexture(dp.label) })
    );
    qrMesh.rotation.x = -Math.PI / 2;
    qrMesh.position.y = 0.022;

    if (dp.mobile) {
      mobileCartGroup = new THREE.Group();
      const cartBody = new THREE.Mesh(
        new THREE.BoxGeometry(1.0, 0.16, 1.0),
        new THREE.MeshStandardMaterial({ color: 0xf97316, roughness: 0.5 })
      );
      cartBody.position.y = 0.08;
      mobileCartGroup.add(cartBody);

      disc.position.y = 0.17;
      qrMesh.position.y = 0.192;
      mobileCartGroup.add(disc);
      mobileCartGroup.add(qrMesh);

      const lbl = createLabelSprite("D2 MOBILE (10 cm/s)", "#fb923c", "rgba(15,23,42,0.9)", 1.0);
      lbl.position.set(0, 0.52, 0);
      mobileCartGroup.add(lbl);

      mobileCartGroup.position.copy(enuToThree(dp.x, dp.y, 0));
      groups.root.add(mobileCartGroup);

      // Linear guide rail (X = -3..3 at Y=1.8)
      const rail = new THREE.Mesh(
        new THREE.BoxGeometry(6.4, 0.02, 0.12),
        new THREE.MeshStandardMaterial({ color: 0x94a3b8 })
      );
      rail.position.copy(enuToThree(0, dp.y, 0.01));
      groups.root.add(rail);
    } else {
      const targetGroup = new THREE.Group();
      targetGroup.add(disc);
      targetGroup.add(qrMesh);
      const lbl = createLabelSprite(`${dp.id} (Ø${dp.diameter}m)`, dp.color, "rgba(15,23,42,0.85)", 0.72);
      lbl.position.set(0, 0.35, 0);
      targetGroup.add(lbl);
      targetGroup.position.copy(enuToThree(dp.x, dp.y, dp.z));
      groups.root.add(targetGroup);
    }
  });

  // 6. Safety Netting Perimeter & Ceiling (Z = 5.0m)
  const netMat = new THREE.MeshBasicMaterial({
    color: 0x0ea5e9,
    transparent: true,
    opacity: 0.06,
    side: THREE.DoubleSide,
    depthWrite: false,
  });
  const halfX = arenaSpec.length_x_m / 2;
  const halfY = arenaSpec.width_y_m / 2;
  const H = arenaSpec.ceiling_z_m;

  // 4 perimeter posts & corner frames
  [
    [-halfX, -halfY],
    [-halfX, 0],
    [-halfX, halfY],
    [0, -halfY],
    [0, halfY],
    [halfX, -halfY],
    [halfX, 0],
    [halfX, halfY],
  ].forEach(([px, py]) => {
    const post = new THREE.Mesh(new THREE.CylinderGeometry(0.05, 0.05, H, 8), postMat);
    post.position.copy(enuToThree(px, py, H / 2));
    groups.netting.add(post);
  });

  // 4 translucent walls + ceiling frame
  const addWall = (w, h, pos, rotY = 0) => {
    const wall = new THREE.Mesh(new THREE.PlaneGeometry(w, h), netMat);
    wall.position.copy(pos);
    wall.rotation.y = rotY;
    groups.netting.add(wall);
  };
  addWall(arenaSpec.length_x_m, H, enuToThree(0, -halfY, H / 2), 0);
  addWall(arenaSpec.length_x_m, H, enuToThree(0, halfY, H / 2), 0);
  addWall(arenaSpec.width_y_m, H, enuToThree(-halfX, 0, H / 2), Math.PI / 2);
  addWall(arenaSpec.width_y_m, H, enuToThree(halfX, 0, H / 2), Math.PI / 2);

  const ceilingEdges = new THREE.EdgesGeometry(new THREE.BoxGeometry(arenaSpec.length_x_m, 0.02, arenaSpec.width_y_m));
  const ceilingWire = new THREE.LineSegments(
    ceilingEdges,
    new THREE.LineBasicMaterial({ color: 0x38bdf8, transparent: true, opacity: 0.45 })
  );
  ceilingWire.position.set(0, H, 0);
  groups.netting.add(ceilingWire);
  groups.root.add(groups.netting);

  // 7. Phase 2 Mandatory Altitude Band (3.0m - 5.0m)
  const altFloor = new THREE.Mesh(
    new THREE.PlaneGeometry(arenaSpec.length_x_m, arenaSpec.width_y_m),
    new THREE.MeshBasicMaterial({ color: 0x10b981, transparent: true, opacity: 0.06, side: THREE.DoubleSide, depthWrite: false })
  );
  altFloor.rotation.x = -Math.PI / 2;
  altFloor.position.y = arenaSpec.phase2_min_z_m;
  groups.altitudeBand.add(altFloor);

  const altWire = new THREE.LineSegments(
    new THREE.EdgesGeometry(new THREE.BoxGeometry(arenaSpec.length_x_m, 0.01, arenaSpec.width_y_m)),
    new THREE.LineBasicMaterial({ color: 0x10b981, transparent: true, opacity: 0.45 })
  );
  altWire.position.y = arenaSpec.phase2_min_z_m;
  groups.altitudeBand.add(altWire);
  groups.root.add(groups.altitudeBand);

  // 8. 4 Perimeter UWB Anchors
  const uwbMat = new THREE.MeshStandardMaterial({ color: 0x10b981, emissive: 0x064e3b });
  arenaSpec.uwb_anchors.forEach((anc) => {
    const pole = new THREE.Mesh(new THREE.CylinderGeometry(0.08, 0.1, anc.z_top, 12), uwbMat);
    pole.position.copy(enuToThree(anc.x, anc.y, anc.z_top / 2));
    groups.uwb.add(pole);
    const lbl = createLabelSprite(anc.id, "#34d399", "rgba(6,11,22,0.85)", 0.7);
    lbl.position.copy(enuToThree(anc.x, anc.y, anc.z_top + 0.35));
    groups.uwb.add(lbl);
  });
  groups.root.add(groups.uwb);

  // 9. 6 Overhead AprilTag Ground Truth Cameras (BOC Independent System)
  const camBodyMat = new THREE.MeshStandardMaterial({ color: 0xf43f5e });
  const fovMat = new THREE.MeshBasicMaterial({
    color: 0xf43f5e,
    transparent: true,
    opacity: 0.08,
    side: THREE.DoubleSide,
    depthWrite: false,
  });
  arenaSpec.overhead_cameras.forEach((cam) => {
    const body = new THREE.Mesh(new THREE.BoxGeometry(0.24, 0.14, 0.24), camBodyMat);
    body.position.copy(enuToThree(cam.x, cam.y, cam.z));
    groups.cameras.add(body);

    const cone = new THREE.Mesh(new THREE.ConeGeometry(2.4, cam.z, 4, 1, true), fovMat);
    cone.position.copy(enuToThree(cam.x, cam.y, cam.z / 2));
    cone.rotation.y = Math.PI / 4;
    groups.cameras.add(cone);

    const lbl = createLabelSprite(`${cam.id} (GT)`, "#fb7185", "rgba(6,11,22,0.85)", 0.72);
    lbl.position.copy(enuToThree(cam.x, cam.y, cam.z + 0.3));
    groups.cameras.add(lbl);
  });
  groups.cameras.visible = false;
  groups.root.add(groups.cameras);

  groups.root.add(groups.dynamicObjects);
  scene.add(groups.root);

  return {
    groups,
    mobileCartGroup,
  };
}
