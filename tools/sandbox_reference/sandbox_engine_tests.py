"""Correctness tests for the falling-sand cellular automaton.

These mirror DailyQuipAITests/PhysicsSandbox/SandboxEngineTests.swift one to
one. Run with: python3 sandbox_engine_tests.py
"""

import unittest

from sandbox_engine import EMPTY, SAND, WALL, WATER, SandboxEngine, SandboxRNG


def run_until_stable(engine, max_steps):
    """Step until the grid stops changing; return steps taken or None."""
    for i in range(max_steps):
        before = list(engine.cells)
        engine.step()
        if engine.cells == before:
            return i + 1
    return None


def column_fill_height(engine, x, types):
    """Number of cells of the given types in column x, counted from the floor up."""
    h = 0
    for y in range(engine.height - 1, -1, -1):
        if engine.cell(x, y) in types:
            h += 1
    return h


class SandboxEngineTests(unittest.TestCase):

    # --- Basic kinematics -------------------------------------------------

    def test_sand_falls_exactly_one_cell_per_step(self):
        e = SandboxEngine(5, 10)
        e.set(2, 0, SAND)
        for step in range(9):
            e.step()
            self.assertEqual(e.cell(2, step), EMPTY)
            self.assertEqual(e.cell(2, step + 1), SAND)

    def test_sand_rests_on_floor(self):
        e = SandboxEngine(5, 10)
        e.set(2, 9, SAND)
        e.step()
        self.assertEqual(e.cell(2, 9), SAND)
        self.assertEqual(e.count(SAND), 1)

    def test_sand_rests_on_wall(self):
        e = SandboxEngine(3, 10)
        # Wall shelf across the full width so sand cannot slide off it.
        for x in range(3):
            e.set(x, 5, WALL)
        e.set(1, 0, SAND)
        for _ in range(20):
            e.step()
        self.assertEqual(e.cell(1, 4), SAND)
        self.assertEqual(e.cell(1, 5), WALL)

    def test_full_sand_layer_is_stable(self):
        e = SandboxEngine(8, 8)
        for x in range(8):
            e.set(x, 7, SAND)
            e.set(x, 6, SAND)
        before = list(e.cells)
        for _ in range(10):
            e.step()
        self.assertEqual(e.cells, before)

    # --- Conservation laws ------------------------------------------------

    def test_mass_conservation_in_random_soup(self):
        e = SandboxEngine(40, 60, seed=7)
        placement = SandboxRNG(99)
        for y in range(60):
            for x in range(40):
                r = placement.next() % 10
                if r == 0:
                    e.set(x, y, WALL)
                elif r in (1, 2):
                    e.set(x, y, SAND)
                elif r in (3, 4):
                    e.set(x, y, WATER)
        counts = {t: e.count(t) for t in (WALL, SAND, WATER, EMPTY)}
        for _ in range(400):
            e.step()
        for t, n in counts.items():
            self.assertEqual(e.count(t), n, f"type {t} count changed")

    def test_walls_never_move(self):
        e = SandboxEngine(20, 20, seed=3)
        wall_positions = [(3, 3), (10, 15), (19, 19), (0, 0), (5, 10)]
        for x, y in wall_positions:
            e.set(x, y, WALL)
        e.paint(10, 2, 3, SAND)
        e.paint(10, 8, 3, WATER)
        for _ in range(200):
            e.step()
        for x, y in wall_positions:
            self.assertEqual(e.cell(x, y), WALL)

    # --- Sand behaviour ---------------------------------------------------

    def test_sand_column_collapses_into_supported_pile(self):
        e = SandboxEngine(21, 30, seed=11)
        for y in range(10):
            e.set(10, y, SAND)
        total = e.count(SAND)
        steps = run_until_stable(e, 500)
        self.assertIsNotNone(steps, "pile never stabilised")
        self.assertEqual(e.count(SAND), total)
        # No floating sand: every grain rests on the floor or on something.
        for y in range(e.height - 1):
            for x in range(e.width):
                if e.cell(x, y) == SAND:
                    self.assertNotEqual(
                        e.cell(x, y + 1), EMPTY,
                        f"floating sand at ({x}, {y})",
                    )
        # The column spread sideways into a pile wider than one cell.
        occupied_columns = {
            x for x in range(e.width)
            for y in range(e.height) if e.cell(x, y) == SAND
        }
        self.assertGreater(len(occupied_columns), 1)

    def test_sand_sinks_through_water(self):
        e = SandboxEngine(7, 12, seed=5)
        # Water pool in a wall basin, sand grain dropped from above.
        for y in range(8, 12):
            e.set(0, y, WALL)
            e.set(6, y, WALL)
        for x in range(1, 6):
            for y in range(8, 11):
                e.set(x, y, WATER)
        e.set(3, 0, SAND)
        for _ in range(60):
            e.step()
        self.assertEqual(e.count(SAND), 1)
        sand_x, sand_y = next(
            (x, y) for y in range(e.height) for x in range(e.width)
            if e.cell(x, y) == SAND
        )
        self.assertEqual(sand_y, 11, "sand should reach the basin floor")
        self.assertEqual(e.cell(sand_x, sand_y - 1), WATER,
                         "sand should be submerged under water")

    # --- Water behaviour --------------------------------------------------

    def test_water_levels_out_in_a_basin(self):
        e = SandboxEngine(32, 20, seed=13)
        # Basin: floor walls plus side walls up to y = 10.
        for x in range(32):
            e.set(x, 19, WALL)
        for y in range(10, 19):
            e.set(0, y, WALL)
            e.set(31, y, WALL)
        # Water block stacked against the left wall.
        for x in range(1, 9):
            for y in range(11, 19):
                e.set(x, y, WATER)
        water_total = e.count(WATER)
        for _ in range(4000):
            e.step()
        self.assertEqual(e.count(WATER), water_total)
        heights = [
            column_fill_height(e, x, (WATER,)) for x in range(1, 31)
        ]
        self.assertLessEqual(
            max(heights) - min(heights), 1,
            f"water surface not level: {heights}",
        )
        # No floating water: every water cell sits on water, wall or floor.
        for y in range(e.height - 1):
            for x in range(e.width):
                if e.cell(x, y) == WATER:
                    self.assertNotEqual(e.cell(x, y + 1), EMPTY)

    def test_water_stays_inside_sealed_box(self):
        e = SandboxEngine(12, 12, seed=17)
        for i in range(12):
            e.set(i, 2, WALL)
            e.set(i, 9, WALL)
        for y in range(2, 10):
            e.set(2, y, WALL)
            e.set(9, y, WALL)
        for x in range(3, 9):
            for y in range(6, 9):
                e.set(x, y, WATER)
        total = e.count(WATER)
        for _ in range(300):
            e.step()
        self.assertEqual(e.count(WATER), total)
        for y in range(e.height):
            for x in range(e.width):
                if e.cell(x, y) == WATER:
                    self.assertTrue(3 <= x <= 8 and 3 <= y <= 8,
                                    f"water escaped to ({x}, {y})")

    # --- Engine guarantees --------------------------------------------------

    def test_each_particle_moves_at_most_one_cell_per_step(self):
        e = SandboxEngine(15, 30, seed=23)
        e.paint(7, 3, 2, SAND)
        e.paint(7, 10, 2, WATER)
        for _ in range(100):
            before = list(e.cells)
            e.step()
            # A displacement of more than one cell would require some cell
            # at Chebyshev distance > 1 from any prior occupied cell.
            for y in range(e.height):
                for x in range(e.width):
                    c = e.cell(x, y)
                    if c in (SAND, WATER):
                        near = any(
                            before[ny * e.width + nx] == c
                            for nx in range(max(0, x - 1), min(e.width, x + 2))
                            for ny in range(max(0, y - 1), min(e.height, y + 2))
                        )
                        self.assertTrue(near, f"particle teleported to ({x}, {y})")

    def test_determinism_same_seed_same_result(self):
        def build(seed):
            e = SandboxEngine(30, 40, seed=seed)
            e.paint(10, 5, 3, SAND)
            e.paint(20, 5, 3, WATER)
            for x in range(8, 25):
                e.set(x, 30, WALL)
            return e

        a, b = build(42), build(42)
        for _ in range(300):
            a.step()
            b.step()
        self.assertEqual(a.cells, b.cells)

    def test_different_seeds_can_diverge(self):
        def build(seed):
            e = SandboxEngine(30, 40, seed=seed)
            e.paint(15, 5, 4, SAND)
            for x in range(10, 21):
                e.set(x, 20, WALL)
            return e

        a, b = build(1), build(2)
        for _ in range(50):
            a.step()
            b.step()
        self.assertNotEqual(a.cells, b.cells)

    def test_particles_in_corners_do_not_crash_or_escape(self):
        e = SandboxEngine(4, 4, seed=29)
        e.set(0, 0, SAND)
        e.set(3, 0, SAND)
        e.set(0, 3, WATER)
        e.set(3, 3, WATER)
        for _ in range(100):
            e.step()
        self.assertEqual(e.count(SAND), 2)
        self.assertEqual(e.count(WATER), 2)


if __name__ == "__main__":
    unittest.main(verbosity=2)
