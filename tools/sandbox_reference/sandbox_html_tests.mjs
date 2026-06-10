// Correctness tests for the JS engine embedded in docs/sandbox.html.
// Extracts the SandboxEngine portion of the page's script and verifies the
// velocity-field falling-sand dynamics. Run: node sandbox_html_tests.mjs

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

const factory = new Function(
  engineSource +
  "\nreturn { SandboxEngine, EMPTY, WALL, SAND, WATER, mulberry32, GRAVITY, MAX_FALL };"
);
const { SandboxEngine, EMPTY, WALL, SAND, WATER, mulberry32, GRAVITY, MAX_FALL } = factory();

const cell = (e, x, y) => e.cells[e.index(x, y)];
const count = (e, t) => e.cells.reduce((n, c) => (c === t ? n + 1 : n), 0);
const find = (e, t) => {
  const out = [];
  for (let y = 0; y < e.height; y++)
    for (let x = 0; x < e.width; x++)
      if (cell(e, x, y) === t) out.push({ x, y });
  return out;
};

const tests = {};

// --- Gravity & kinematics ----------------------------------------------------

tests.sandAcceleratesUnderGravity = () => {
  const e = new SandboxEngine(5, 80, 1);
  e.set(2, 0, SAND);
  const ys = [0];
  while (ys[ys.length - 1] < 79 && ys.length < 200) {
    e.step();
    const [s] = find(e, SAND);
    assert.ok(s, "sand disappeared mid-fall");
    ys.push(s.y);
  }
  const steps = ys.length - 1;
  // Constant 1 cell/tick would need 79 steps; gravity must beat that easily.
  assert.ok(steps < 40, `fall took ${steps} steps, expected acceleration`);
  // Position must increase monotonically and never skip past the floor.
  for (let i = 1; i < ys.length; i++) {
    assert.ok(ys[i] >= ys[i - 1], "sand moved upward");
    assert.ok(ys[i] - ys[i - 1] <= MAX_FALL, "exceeded terminal velocity");
    assert.ok(ys[i] <= 79, "sand left the grid");
  }
  // Late-fall speed should exceed the 1 cell/tick of the naive automaton.
  const lastDelta = ys[ys.length - 1] - ys[ys.length - 2];
  assert.ok(lastDelta > 1, `expected terminal-speed fall, got ${lastDelta}`);
};

tests.fastSandNeverTunnelsThroughWalls = () => {
  const e = new SandboxEngine(3, 100, 2);
  for (let x = 0; x < 3; x++) e.set(x, 70, WALL); // full-width shelf
  e.set(1, 0, SAND); // long free fall -> terminal velocity at impact
  let minDistanceAboveWall = Infinity;
  for (let i = 0; i < 200; i++) {
    e.step();
    for (const s of find(e, SAND)) {
      assert.ok(s.y < 70, `sand tunnelled through the wall to y=${s.y}`);
      minDistanceAboveWall = Math.min(minDistanceAboveWall, 70 - 1 - s.y);
    }
  }
  assert.equal(minDistanceAboveWall, 0, "sand never landed on the wall");
  assert.equal(count(e, SAND), 1);
};

tests.fullSandLayerIsStable = () => {
  const e = new SandboxEngine(8, 8, 1);
  for (let x = 0; x < 8; x++) { e.set(x, 7, SAND); e.set(x, 6, SAND); }
  const before = Array.from(e.cells);
  for (let i = 0; i < 10; i++) e.step();
  assert.deepEqual(Array.from(e.cells), before);
};

// --- Conservation laws ---------------------------------------------------------

tests.massConservationInRandomSoup = () => {
  const e = new SandboxEngine(40, 60, 7);
  const place = mulberry32(99);
  for (let y = 0; y < 60; y++) {
    for (let x = 0; x < 40; x++) {
      const r = Math.floor(place() * 10);
      if (r === 0) e.set(x, y, WALL);
      else if (r <= 2) e.set(x, y, SAND);
      else if (r <= 4) e.set(x, y, WATER);
    }
  }
  const counts = [EMPTY, WALL, SAND, WATER].map(t => count(e, t));
  for (let i = 0; i < 400; i++) e.step();
  assert.deepEqual([EMPTY, WALL, SAND, WATER].map(t => count(e, t)), counts);
};

tests.wallsNeverMove = () => {
  const e = new SandboxEngine(20, 20, 3);
  const walls = [[3, 3], [10, 15], [19, 19], [0, 0], [5, 10]];
  for (const [x, y] of walls) e.set(x, y, WALL);
  e.paint(10, 2, 3, SAND);
  e.paint(10, 8, 3, WATER);
  for (let i = 0; i < 200; i++) e.step();
  for (const [x, y] of walls) assert.equal(cell(e, x, y), WALL);
};

// --- Sand behaviour --------------------------------------------------------------

tests.sandColumnCollapsesIntoSupportedPile = () => {
  const e = new SandboxEngine(21, 30, 11);
  for (let y = 0; y < 10; y++) e.set(10, y, SAND);
  const total = count(e, SAND);
  for (let i = 0; i < 800; i++) e.step();
  assert.equal(count(e, SAND), total);
  // No floating sand: every grain rests on the floor or on something.
  for (const s of find(e, SAND))
    if (s.y < e.height - 1)
      assert.notEqual(cell(e, s.x, s.y + 1), EMPTY, `floating sand at (${s.x}, ${s.y})`);
  // The column spread sideways into a pile wider than one cell.
  assert.ok(new Set(find(e, SAND).map(s => s.x)).size > 1);
};

tests.sandSinksThroughWater = () => {
  const e = new SandboxEngine(7, 12, 5);
  for (let y = 8; y < 12; y++) { e.set(0, y, WALL); e.set(6, y, WALL); }
  for (let x = 1; x < 6; x++) for (let y = 8; y < 11; y++) e.set(x, y, WATER);
  e.set(3, 0, SAND);
  for (let i = 0; i < 80; i++) e.step();
  assert.equal(count(e, SAND), 1);
  const [s] = find(e, SAND);
  assert.equal(s.y, 11, "sand should reach the basin floor");
  assert.equal(cell(e, s.x, s.y - 1), WATER, "sand should be submerged");
};

// --- Water behaviour ---------------------------------------------------------------

tests.waterLevelsOutInABasin = () => {
  const e = new SandboxEngine(32, 20, 13);
  for (let x = 0; x < 32; x++) e.set(x, 19, WALL);
  for (let y = 10; y < 19; y++) { e.set(0, y, WALL); e.set(31, y, WALL); }
  for (let x = 1; x < 9; x++) for (let y = 11; y < 19; y++) e.set(x, y, WATER);
  const total = count(e, WATER);
  for (let i = 0; i < 1500; i++) e.step();
  assert.equal(count(e, WATER), total);
  const heights = [];
  for (let x = 1; x < 31; x++) {
    let h = 0;
    for (let y = 0; y < e.height; y++) if (cell(e, x, y) === WATER) h++;
    heights.push(h);
  }
  assert.ok(Math.max(...heights) - Math.min(...heights) <= 1,
    `water surface not level: ${heights}`);
};

tests.waterStaysInsideSealedBox = () => {
  const e = new SandboxEngine(12, 12, 17);
  for (let i = 0; i < 12; i++) { e.set(i, 2, WALL); e.set(i, 9, WALL); }
  for (let y = 2; y < 10; y++) { e.set(2, y, WALL); e.set(9, y, WALL); }
  for (let x = 3; x < 9; x++) for (let y = 6; y < 9; y++) e.set(x, y, WATER);
  const total = count(e, WATER);
  for (let i = 0; i < 300; i++) e.step();
  assert.equal(count(e, WATER), total);
  for (const w of find(e, WATER))
    assert.ok(w.x >= 3 && w.x <= 8 && w.y >= 3 && w.y <= 8,
      `water escaped to (${w.x}, ${w.y})`);
};

// --- Engine guarantees ------------------------------------------------------------

tests.determinismSameSeedSameResult = () => {
  const build = seed => {
    const e = new SandboxEngine(30, 40, seed);
    e.paint(10, 5, 3, SAND);
    e.paint(20, 5, 3, WATER);
    for (let x = 8; x < 25; x++) e.set(x, 30, WALL);
    return e;
  };
  const a = build(42), b = build(42);
  for (let i = 0; i < 300; i++) { a.step(); b.step(); }
  assert.deepEqual(Array.from(a.cells), Array.from(b.cells));
};

tests.particlesInCornersDoNotCrashOrEscape = () => {
  const e = new SandboxEngine(4, 4, 29);
  e.set(0, 0, SAND); e.set(3, 0, SAND);
  e.set(0, 3, WATER); e.set(3, 3, WATER);
  for (let i = 0; i < 100; i++) e.step();
  assert.equal(count(e, SAND), 2);
  assert.equal(count(e, WATER), 2);
};

tests.gravityConstantsAreSane = () => {
  assert.ok(GRAVITY > 0, "gravity must pull down");
  assert.ok(MAX_FALL >= 2, "terminal velocity must allow multi-cell falls");
};

let passed = 0, failed = 0;
for (const [name, fn] of Object.entries(tests)) {
  try {
    fn();
    console.log(`ok   ${name}`);
    passed++;
  } catch (err) {
    console.error(`FAIL ${name}\n     ${err.message}`);
    failed++;
  }
}
console.log(`\n${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
