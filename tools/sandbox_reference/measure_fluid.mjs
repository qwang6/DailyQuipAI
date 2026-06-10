// Scratch harness to observe fluid engine behaviour and pick test thresholds.
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const here = dirname(fileURLToPath(import.meta.url));
const html = readFileSync(join(here, "../../docs/sandbox.html"), "utf8");
const start = html.indexOf('"use strict"');
const end = html.indexOf("// ============================================================================\n// Rendering & interaction");
const src = html.slice(start, end);
const { FluidEngine, WATER, SAND, WORLD_W, WORLD_H, MAX_SPEED } = new Function(
  src + "\nreturn { FluidEngine, WATER, SAND, WORLD_W, WORLD_H, MAX_SPEED };"
)();

function ascii(e, rows = 36, cols = 60) {
  const grid = Array.from({ length: rows }, () => Array(cols).fill(" "));
  for (let gy = 0; gy < rows; gy++)
    for (let gx = 0; gx < cols; gx++) {
      const wx = Math.floor(gx / cols * WORLD_W), wy = Math.floor(gy / rows * WORLD_H);
      if (e.walls[wy * WORLD_W + wx]) grid[gy][gx] = "#";
    }
  for (let i = 0; i < e.count; i++) {
    const gx = Math.min(cols - 1, Math.floor(e.px[i] / WORLD_W * cols));
    const gy = Math.min(rows - 1, Math.floor(e.py[i] / WORLD_H * rows));
    grid[gy][gx] = e.type[i] === WATER ? "~" : (e.asleep[i] ? "S" : "s");
  }
  return grid.map(r => r.join("")).join("\n");
}

const stats = e => {
  let maxSp = 0, bad = 0;
  for (let i = 0; i < e.count; i++) {
    const sp = Math.hypot(e.vx[i], e.vy[i]);
    maxSp = Math.max(maxSp, sp);
    if (!isFinite(e.px[i]) || !isFinite(e.py[i])) bad++;
  }
  return { ke: (e.kineticEnergy() / Math.max(1, e.count)).toFixed(5), maxSp: maxSp.toFixed(3), bad };
};

// --- A: water settling & leveling ---
{
  const e = new FluidEngine(1);
  for (let y = 0; y < 20; y++)
    for (let x = 0; x < 20; x++)
      e.spawn(WATER, 8 + x * 1.4, 120 + y * 1.4, 1, 0.2);
  console.log("A water n=", e.count);
  for (let t = 0; t <= 2400; t++) {
    e.step();
    if (t % 600 === 0) console.log("  t=" + t, JSON.stringify(stats(e)));
  }
  // surface height across x bins
  const bins = 8, top = Array(bins).fill(WORLD_H), cnt = Array(bins).fill(0);
  for (let i = 0; i < e.count; i++) {
    const b = Math.min(bins - 1, Math.floor(e.px[i] / WORLD_W * bins));
    top[b] = Math.min(top[b], e.py[i]);
    cnt[b]++;
  }
  console.log("  surface tops:", top.map(v => v.toFixed(1)).join(" "), "counts:", cnt.join(" "));
}

// --- B: sand pile persistence ---
{
  const e = new FluidEngine(2);
  for (let y = 0; y < 16; y++)
    for (let x = 0; x < 12; x++)
      e.spawn(SAND, 52 + x * 1.4, 140 + y * 1.4, 1, 0.2);
  console.log("B sand n=", e.count);
  let h1500 = 0;
  for (let t = 0; t <= 3000; t++) {
    e.step();
    if (t === 1500 || t === 3000) {
      let minY = WORLD_H, minX = WORLD_W, maxX = 0, asleep = 0;
      for (let i = 0; i < e.count; i++) {
        minY = Math.min(minY, e.py[i]);
        minX = Math.min(minX, e.px[i]); maxX = Math.max(maxX, e.px[i]);
        asleep += e.asleep[i];
      }
      const h = WORLD_H - 1 - minY;
      console.log(`  t=${t} pileH=${h.toFixed(1)} width=${(maxX - minX).toFixed(1)} asleep=${asleep}/${e.count}`, JSON.stringify(stats(e)));
      if (t === 1500) h1500 = h;
    }
  }
  console.log(ascii(e));
}

// --- C: sand sinks in water ---
{
  const e = new FluidEngine(3);
  for (let y = 0; y < 14; y++)
    for (let x = 0; x < 40; x++)
      e.spawn(WATER, 20 + x * 1.4, 150 + y * 1.4, 1, 0.2);
  for (let t = 0; t < 600; t++) e.step();
  for (let y = 0; y < 5; y++)
    for (let x = 0; x < 8; x++)
      e.spawn(SAND, 55 + x * 1.3, 120 + y * 1.3, 1, 0.2);
  for (let t = 0; t < 2000; t++) e.step();
  let surface = WORLD_H, sn = 0, submerged = 0, nearFloor = 0;
  for (let i = 0; i < e.count; i++)
    if (e.type[i] === WATER) surface = Math.min(surface, e.py[i]);
  for (let i = 0; i < e.count; i++) {
    if (e.type[i] !== SAND) continue;
    sn++;
    if (e.py[i] > surface + 1) submerged++;
    if (e.py[i] > WORLD_H - 6) nearFloor++;
  }
  console.log("C waterSurface=", surface.toFixed(1), "sand submerged=", submerged + "/" + sn, "nearFloor=", nearFloor + "/" + sn, JSON.stringify(stats(e)));
}

// --- D: no tunneling through wall band ---
{
  const e = new FluidEngine(4);
  for (let x = 0; x <= WORLD_W; x += 1.5) e.paintWall(x, 100, 2.5);
  for (let x = 0; x < 30; x++) e.spawn(WATER, 10 + x * 1.4, 5, 1, 0.3);
  for (let x = 0; x < 30; x++) e.spawn(SAND, 60 + x * 1.4, 5, 1, 0.3);
  let worstY = 0;
  for (let t = 0; t < 1200; t++) {
    e.step();
    for (let i = 0; i < e.count; i++) worstY = Math.max(worstY, e.py[i]);
  }
  console.log("D worst y =", worstY.toFixed(2), "(wall band at 97.5..102.5)", JSON.stringify(stats(e)));
}

// --- E: chaos stability ---
{
  const e = new FluidEngine(5);
  for (let i = 0; i < 40; i++) e.paintWall(20 + i, 120 - i * 0.5, 2);
  for (let k = 0; k < 1200; k++) e.spawn(k % 3 === 0 ? SAND : WATER, 10 + (k % 50) * 2, 5 + Math.floor(k / 50) * 2, 1, 0.5);
  let maxSp = 0, bad = 0;
  for (let t = 0; t < 1500; t++) {
    e.step();
    for (let i = 0; i < e.count; i++) {
      maxSp = Math.max(maxSp, Math.hypot(e.vx[i], e.vy[i]));
      if (!isFinite(e.px[i]) || !isFinite(e.py[i]) ||
          e.px[i] < 0 || e.px[i] > WORLD_W || e.py[i] < 0 || e.py[i] > WORLD_H) bad++;
    }
  }
  console.log("E maxSpeed=", maxSp.toFixed(3), "MAX_SPEED=", MAX_SPEED, "outOfBounds=", bad);
}
