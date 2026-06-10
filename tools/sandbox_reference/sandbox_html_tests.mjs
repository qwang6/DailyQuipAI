// Correctness tests for the JS engine embedded in docs/sandbox.html.
// Extracts the SandboxEngine portion of the page's script and runs the same
// scenario tests as sandbox_engine_tests.py. Run: node sandbox_html_tests.mjs

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

const factory = new Function(engineSource + "\nreturn { SandboxEngine, EMPTY, WALL, SAND, WATER, mulberry32 };");
const { SandboxEngine, EMPTY, WALL, SAND, WATER, mulberry32 } = factory();

const cell = (e, x, y) => e.cells[e.index(x, y)];
const count = (e, t) => e.cells.reduce((n, c) => (c === t ? n + 1 : n), 0);
const runUntilStable = (e, maxSteps) => {
  for (let i = 0; i < maxSteps; i++) {
    const before = Array.from(e.cells);
    e.step();
    if (before.every((c, j) => c === e.cells[j])) return i + 1;
  }
  return null;
};

const tests = {};

tests.sandFallsExactlyOneCellPerStep = () => {
  const e = new SandboxEngine(5, 10, 1);
  e.set(2, 0, SAND);
  for (let step = 0; step < 9; step++) {
    e.step();
    assert.equal(cell(e, 2, step), EMPTY);
    assert.equal(cell(e, 2, step + 1), SAND);
  }
};

tests.sandRestsOnFloorAndWall = () => {
  const e = new SandboxEngine(3, 10, 1);
  for (let x = 0; x < 3; x++) e.set(x, 5, WALL);
  e.set(1, 0, SAND);
  for (let i = 0; i < 20; i++) e.step();
  assert.equal(cell(e, 1, 4), SAND);
  assert.equal(cell(e, 1, 5), WALL);
};

tests.fullSandLayerIsStable = () => {
  const e = new SandboxEngine(8, 8, 1);
  for (let x = 0; x < 8; x++) { e.set(x, 7, SAND); e.set(x, 6, SAND); }
  const before = Array.from(e.cells);
  for (let i = 0; i < 10; i++) e.step();
  assert.deepEqual(Array.from(e.cells), before);
};

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

tests.sandColumnCollapsesIntoSupportedPile = () => {
  const e = new SandboxEngine(21, 30, 11);
  for (let y = 0; y < 10; y++) e.set(10, y, SAND);
  const total = count(e, SAND);
  assert.notEqual(runUntilStable(e, 500), null, "pile never stabilised");
  assert.equal(count(e, SAND), total);
  for (let y = 0; y < e.height - 1; y++)
    for (let x = 0; x < e.width; x++)
      if (cell(e, x, y) === SAND)
        assert.notEqual(cell(e, x, y + 1), EMPTY, `floating sand at (${x}, ${y})`);
};

tests.sandSinksThroughWater = () => {
  const e = new SandboxEngine(7, 12, 5);
  for (let y = 8; y < 12; y++) { e.set(0, y, WALL); e.set(6, y, WALL); }
  for (let x = 1; x < 6; x++) for (let y = 8; y < 11; y++) e.set(x, y, WATER);
  e.set(3, 0, SAND);
  for (let i = 0; i < 60; i++) e.step();
  assert.equal(count(e, SAND), 1);
  let sx = -1, sy = -1;
  for (let y = 0; y < e.height; y++)
    for (let x = 0; x < e.width; x++)
      if (cell(e, x, y) === SAND) { sx = x; sy = y; }
  assert.equal(sy, 11, "sand should reach the basin floor");
  assert.equal(cell(e, sx, sy - 1), WATER, "sand should be submerged");
};

tests.waterLevelsOutInABasin = () => {
  const e = new SandboxEngine(32, 20, 13);
  for (let x = 0; x < 32; x++) e.set(x, 19, WALL);
  for (let y = 10; y < 19; y++) { e.set(0, y, WALL); e.set(31, y, WALL); }
  for (let x = 1; x < 9; x++) for (let y = 11; y < 19; y++) e.set(x, y, WATER);
  const total = count(e, WATER);
  for (let i = 0; i < 4000; i++) e.step();
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
  for (let y = 0; y < e.height; y++)
    for (let x = 0; x < e.width; x++)
      if (cell(e, x, y) === WATER)
        assert.ok(x >= 3 && x <= 8 && y >= 3 && y <= 8, `water escaped to (${x}, ${y})`);
};

tests.eachParticleMovesAtMostOneCellPerStep = () => {
  const e = new SandboxEngine(15, 30, 23);
  e.paint(7, 3, 2, SAND);
  e.paint(7, 10, 2, WATER);
  for (let i = 0; i < 100; i++) {
    const before = Array.from(e.cells);
    e.step();
    for (let y = 0; y < e.height; y++)
      for (let x = 0; x < e.width; x++) {
        const c = cell(e, x, y);
        if (c !== SAND && c !== WATER) continue;
        let near = false;
        for (let ny = Math.max(0, y - 1); ny <= Math.min(e.height - 1, y + 1); ny++)
          for (let nx = Math.max(0, x - 1); nx <= Math.min(e.width - 1, x + 1); nx++)
            if (before[ny * e.width + nx] === c) near = true;
        assert.ok(near, `particle teleported to (${x}, ${y})`);
      }
  }
};

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
