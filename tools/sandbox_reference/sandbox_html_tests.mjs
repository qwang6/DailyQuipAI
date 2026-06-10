// Correctness tests for the particle fluid engine embedded in docs/sandbox.html.
// Extracts the engine portion of the page's script and verifies the SPH
// dynamics. Run: node sandbox_html_tests.mjs

import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";
import assert from "node:assert/strict";

const here = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(join(here, "../../docs/sandbox.html"), "utf8");

const start = html.indexOf('"use strict"');
const end = html.indexOf("// ============================================================================\n// Rendering & interaction");
assert.ok(start !== -1 && end !== -1, "could not locate engine script in sandbox.html");
const engineSource = html.slice(start, end);

const { FluidEngine, WATER, SAND, WORLD_W, WORLD_H, MAX_PARTICLES, MAX_SPEED } =
  new Function(engineSource +
    "\nreturn { FluidEngine, WATER, SAND, WORLD_W, WORLD_H, MAX_PARTICLES, MAX_SPEED };")();

const countType = (e, t) => {
  let n = 0;
  for (let i = 0; i < e.count; i++) if (e.type[i] === t) n++;
  return n;
};

const assertAllInsideAndFinite = (e, label) => {
  for (let i = 0; i < e.count; i++) {
    assert.ok(Number.isFinite(e.px[i]) && Number.isFinite(e.py[i]), `${label}: NaN position`);
    assert.ok(e.px[i] >= 0 && e.px[i] <= WORLD_W && e.py[i] >= 0 && e.py[i] <= WORLD_H,
      `${label}: particle escaped to (${e.px[i].toFixed(1)}, ${e.py[i].toFixed(1)})`);
  }
};

const tests = {};

// --- Water behaviour ---------------------------------------------------------

tests.waterComesToRestAndLevels = () => {
  const e = new FluidEngine(1);
  for (let y = 0; y < 20; y++)
    for (let x = 0; x < 20; x++)
      e.spawn(WATER, 8 + x * 1.4, 120 + y * 1.4, 1, 0.2);
  assert.equal(e.count, 400);
  for (let t = 0; t < 1800; t++) e.step();
  assert.equal(e.count, 400, "water particles were created or destroyed");
  // Viscosity must dissipate the energy of the collapse.
  assert.ok(e.kineticEnergy() / e.count < 5e-4,
    `water never came to rest, ke/p = ${e.kineticEnergy() / e.count}`);
  // A liquid finds its level: surface height must match across the basin.
  const bins = 8, top = Array(bins).fill(WORLD_H);
  for (let i = 0; i < e.count; i++) {
    const b = Math.min(bins - 1, Math.floor(e.px[i] / WORLD_W * bins));
    top[b] = Math.min(top[b], e.py[i]);
  }
  const spread = Math.max(...top) - Math.min(...top);
  assert.ok(spread <= 2.5, `water surface not level, spread = ${spread.toFixed(2)}`);
  assertAllInsideAndFinite(e, "water");
};

// --- Sand behaviour -----------------------------------------------------------

tests.sandFormsPersistentPile = () => {
  const e = new FluidEngine(2);
  for (let y = 0; y < 16; y++)
    for (let x = 0; x < 12; x++)
      e.spawn(SAND, 52 + x * 1.4, 140 + y * 1.4, 1, 0.2);
  const total = e.count;
  for (let t = 0; t < 1500; t++) e.step();
  assert.equal(e.count, total);
  let minY = WORLD_H, minX = WORLD_W, maxX = 0;
  for (let i = 0; i < e.count; i++) {
    minY = Math.min(minY, e.py[i]);
    minX = Math.min(minX, e.px[i]);
    maxX = Math.max(maxX, e.px[i]);
  }
  const height = WORLD_H - 1 - minY;
  const width = maxX - minX;
  // Granular material must heap up, not pancake like a liquid.
  assert.ok(height >= 6, `pile too flat: height ${height.toFixed(1)}`);
  assert.ok(width <= 45, `pile spread like a liquid: width ${width.toFixed(1)}`);
  assert.ok(e.kineticEnergy() / e.count < 2e-3,
    `pile never settled, ke/p = ${e.kineticEnergy() / e.count}`);
  // ...and must hold its shape over time instead of slowly creeping flat.
  for (let t = 0; t < 600; t++) e.step();
  let minY2 = WORLD_H;
  for (let i = 0; i < e.count; i++) minY2 = Math.min(minY2, e.py[i]);
  assert.ok(Math.abs(minY2 - minY) < 1.0,
    `pile keeps creeping: top moved ${(minY2 - minY).toFixed(2)}`);
  assertAllInsideAndFinite(e, "sand");
};

tests.sandSinksInWater = () => {
  const e = new FluidEngine(3);
  for (let y = 0; y < 14; y++)
    for (let x = 0; x < 40; x++)
      e.spawn(WATER, 20 + x * 1.4, 150 + y * 1.4, 1, 0.2);
  for (let t = 0; t < 600; t++) e.step();
  for (let y = 0; y < 5; y++)
    for (let x = 0; x < 8; x++)
      e.spawn(SAND, 55 + x * 1.3, 120 + y * 1.3, 1, 0.2);
  for (let t = 0; t < 2000; t++) e.step();
  let surface = WORLD_H;
  for (let i = 0; i < e.count; i++)
    if (e.type[i] === WATER) surface = Math.min(surface, e.py[i]);
  let sand = 0, submerged = 0, nearFloor = 0;
  for (let i = 0; i < e.count; i++) {
    if (e.type[i] !== SAND) continue;
    sand++;
    if (e.py[i] > surface + 1) submerged++;
    if (e.py[i] > WORLD_H - 6) nearFloor++;
  }
  assert.ok(submerged / sand >= 0.7,
    `sand floats: only ${submerged}/${sand} below the water surface`);
  assert.ok(nearFloor / sand >= 0.9,
    `sand did not reach the bottom: ${nearFloor}/${sand}`);
};

// --- Collisions & containment ---------------------------------------------------

tests.particlesNeverTunnelThroughWalls = () => {
  const e = new FluidEngine(4);
  for (let x = 0; x <= WORLD_W; x += 1.5) e.paintWall(x, 100, 2.5); // solid band
  for (let x = 0; x < 30; x++) e.spawn(WATER, 10 + x * 1.4, 5, 1, 0.3);
  for (let x = 0; x < 30; x++) e.spawn(SAND, 60 + x * 1.4, 5, 1, 0.3);
  for (let t = 0; t < 1200; t++) {
    e.step();
    for (let i = 0; i < e.count; i++)
      assert.ok(e.py[i] < 99, `particle reached y=${e.py[i].toFixed(2)} inside/behind the wall band`);
  }
  assertAllInsideAndFinite(e, "tunnel");
};

tests.chaosStaysBounded = () => {
  const e = new FluidEngine(5);
  for (let i = 0; i < 40; i++) e.paintWall(20 + i, 120 - i * 0.5, 2);
  for (let k = 0; k < 1200; k++)
    e.spawn(k % 3 === 0 ? SAND : WATER, 10 + (k % 50) * 2, 5 + Math.floor(k / 50) * 2, 1, 0.5);
  const total = e.count;
  for (let t = 0; t < 1000; t++) {
    e.step();
    for (let i = 0; i < e.count; i++) {
      const sp = Math.hypot(e.vx[i], e.vy[i]);
      assert.ok(sp <= MAX_SPEED + 1e-3, `speed ${sp.toFixed(3)} exceeds clamp`);
    }
  }
  assert.equal(e.count, total);
  assertAllInsideAndFinite(e, "chaos");
};

// --- Engine guarantees ---------------------------------------------------------------

tests.determinismSameSeedSameResult = () => {
  const build = seed => {
    const e = new FluidEngine(seed);
    for (let i = 0; i < 30; i++) e.paintWall(30 + i, 110, 2);
    for (let k = 0; k < 500; k++)
      e.spawn(k % 2 ? SAND : WATER, 15 + (k % 40) * 2.2, 8 + Math.floor(k / 40) * 2, 1, 0.4);
    return e;
  };
  const a = build(42), b = build(42);
  for (let t = 0; t < 400; t++) { a.step(); b.step(); }
  assert.equal(a.count, b.count);
  for (let i = 0; i < a.count; i++) {
    assert.equal(a.px[i], b.px[i], `x diverged at particle ${i}`);
    assert.equal(a.py[i], b.py[i], `y diverged at particle ${i}`);
  }
};

tests.particleCapAndEraseWork = () => {
  const e = new FluidEngine(6);
  e.spawn(WATER, 60, 90, MAX_PARTICLES + 500, 30);
  assert.equal(e.count, MAX_PARTICLES, "spawn must clamp at the particle cap");
  e.eraseAt(60, 90, 200);
  assert.equal(e.count, 0, "eraser must remove particles");
};

tests.wallSDFIsSigned = () => {
  const e = new FluidEngine(7);
  e.paintWall(60, 90, 4);
  e.rebuildSDF();
  assert.ok(e.sdfAt(60, 90) < 0, "inside a wall the distance must be negative");
  assert.ok(e.sdfAt(60, 60) > 5, "far from walls the distance must be large");
  e.eraseAt(60, 90, 10);
  e.rebuildSDF();
  assert.ok(e.sdfAt(60, 90) > 100, "erasing the wall must clear the field");
};

let passed = 0, failed = 0;
for (const [name, fn] of Object.entries(tests)) {
  const t0 = Date.now();
  try {
    fn();
    console.log(`ok   ${name} (${Date.now() - t0}ms)`);
    passed++;
  } catch (err) {
    console.error(`FAIL ${name}\n     ${err.message}`);
    failed++;
  }
}
console.log(`\n${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
