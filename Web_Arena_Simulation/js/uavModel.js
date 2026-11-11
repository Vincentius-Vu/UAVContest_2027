import * as THREE from "three";

/**
 * Creates a compliant UAV Contest 2027 quadrotor (<= 1.0m footprint, 100% prop guards)
 * plus optional 1.5m D_MIN safety sphere and downward CV camera.
 */
export function createUavActor(id, colorHex, isGroundTruthGhost = false) {
  const root = new THREE.Group();
  const opacity = isGroundTruthGhost ? 0.35 : 1.0;
  const transparent = isGroundTruthGhost;

  const bodyMat = new THREE.MeshStandardMaterial({
    color: colorHex,
    roughness: 0.35,
    metalness: 0.4,
    transparent,
    opacity,
  });
  const frameMat = new THREE.MeshStandardMaterial({
    color: isGroundTruthGhost ? colorHex : 0x1e293b,
    roughness: 0.5,
    transparent,
    opacity,
  });
  const guardMat = new THREE.MeshStandardMaterial({
    color: colorHex,
    emissive: isGroundTruthGhost ? 0x000000 : colorHex,
    emissiveIntensity: 0.15,
    transparent,
    opacity: isGroundTruthGhost ? 0.3 : 0.85,
  });

  // Central hub
  const hub = new THREE.Mesh(new THREE.BoxGeometry(0.28, 0.1, 0.28), bodyMat);
  root.add(hub);

  // X-arms (within 0.9m total bounding diameter <= 1.0m rule)
  [Math.PI / 4, -Math.PI / 4].forEach((angle) => {
    const arm = new THREE.Mesh(new THREE.BoxGeometry(0.76, 0.035, 0.04), frameMat);
    arm.rotation.y = angle;
    root.add(arm);
  });

  // 4 rotors + mandatory propeller guards
  const rotors = [];
  const motorOffsets = [
    [0.27, 0.03, 0.27],
    [-0.27, 0.03, 0.27],
    [-0.27, 0.03, -0.27],
    [0.27, 0.03, -0.27],
  ];
  motorOffsets.forEach(([mx, my, mz]) => {
    const guard = new THREE.Mesh(new THREE.TorusGeometry(0.18, 0.015, 8, 20), guardMat);
    guard.rotation.x = Math.PI / 2;
    guard.position.set(mx, my, mz);
    root.add(guard);

    const blade = new THREE.Mesh(
      new THREE.BoxGeometry(0.28, 0.008, 0.028),
      new THREE.MeshBasicMaterial({ color: 0xe2e8f0, transparent: true, opacity: isGroundTruthGhost ? 0.25 : 0.7 })
    );
    blade.position.set(mx, my + 0.015, mz);
    root.add(blade);
    rotors.push(blade);
  });

  // Carried cargo slot underneath UAV
  const carriedCargo = new THREE.Mesh(
    new THREE.BoxGeometry(0.3, 0.3, 0.3),
    new THREE.MeshStandardMaterial({ color: 0xea580c, roughness: 0.45 })
  );
  carriedCargo.position.set(0, -0.2, 0);
  carriedCargo.visible = false;
  root.add(carriedCargo);

  // Safety Halo (radius = 0.75 m -> two drones touch halos at 1.5 m D_MIN)
  const haloRing = new THREE.Mesh(
    new THREE.RingGeometry(0.72, 0.76, 36),
    new THREE.MeshBasicMaterial({
      color: 0x10b981,
      side: THREE.DoubleSide,
      transparent: true,
      opacity: isGroundTruthGhost ? 0.0 : 0.55,
    })
  );
  haloRing.rotation.x = -Math.PI / 2;
  haloRing.position.y = -0.02;
  root.add(haloRing);

  // Downward onboard camera looking straight down (-Y in Three.js)
  const downwardCam = new THREE.PerspectiveCamera(62, 250 / 185, 0.05, 15);
  downwardCam.position.set(0, -0.06, 0);
  downwardCam.lookAt(0, -5, 0);
  root.add(downwardCam);

  return {
    id,
    root,
    rotors,
    carriedCargo,
    haloRing,
    downwardCam,
    spinRotors(dt, spinning) {
      if (!spinning) return;
      for (let i = 0; i < rotors.length; i++) {
        rotors[i].rotation.y += (i % 2 === 0 ? 1 : -1) * dt * 28;
      }
    },
    setHaloAlert(alertLevel) {
      // alertLevel: "ok" | "warn" | "danger"
      const mat = haloRing.material;
      if (alertLevel === "danger") {
        mat.color.setHex(0xef4444);
        mat.opacity = 0.9;
      } else if (alertLevel === "warn") {
        mat.color.setHex(0xf59e0b);
        mat.opacity = 0.75;
      } else {
        mat.color.setHex(0x10b981);
        mat.opacity = 0.45;
      }
    },
  };
}
