# Physics Sandbox — reference implementation & algorithm verification

`DailyQuipAI/Features/PhysicsSandbox/SandboxEngine.swift` implements a
falling-sand cellular automaton (sand / water / wall). This directory holds a
line-by-line Python port of that engine plus a correctness test suite, so the
algorithm can be verified in environments without a Swift toolchain.

- `sandbox_engine.py` — 1:1 port of `SandboxEngine.swift` (same SplitMix64
  RNG, same scan order, same rules). Keep in sync with the Swift file.
- `sandbox_engine_tests.py` — mirrors
  `DailyQuipAITests/PhysicsSandbox/SandboxEngineTests.swift` one to one.

Run:

```sh
python3 sandbox_engine_tests.py
```

## Properties verified

| Property | Test |
| --- | --- |
| Sand falls exactly one cell per tick | `test_sand_falls_exactly_one_cell_per_step` |
| Particles rest on floor / walls | `test_sand_rests_on_floor`, `test_sand_rests_on_wall` |
| Stable configurations stay fixed | `test_full_sand_layer_is_stable` |
| Mass conservation (no particle created/destroyed) | `test_mass_conservation_in_random_soup` |
| Walls are immutable | `test_walls_never_move` |
| Sand piles have no floating grains | `test_sand_column_collapses_into_supported_pile` |
| Sand sinks through water (density) | `test_sand_sinks_through_water` |
| Water levels out to a flat surface (±1 cell) | `test_water_levels_out_in_a_basin` |
| Water cannot escape a sealed container | `test_water_stays_inside_sealed_box` |
| No particle moves more than one cell per tick | `test_each_particle_moves_at_most_one_cell_per_step` |
| Deterministic for a fixed seed | `test_determinism_same_seed_same_result` |
| Seed actually influences the dynamics | `test_different_seeds_can_diverge` |
| Boundary safety at grid corners | `test_particles_in_corners_do_not_crash_or_escape` |

## Algorithm summary

Grid of `width × height` cells, `y` grows downward. Each `step()`:

1. Clear the per-cell `moved` flags (each particle moves at most once per tick).
2. Scan rows bottom-up; alternate the horizontal scan direction every tick to
   avoid lateral drift bias.
3. **Sand**: move down into empty space; swap with water below (sinks);
   otherwise slide to a random empty down-diagonal.
4. **Water**: move down; otherwise a random empty down-diagonal; otherwise
   flow one cell sideways into empty space.
5. Direction choices come from a seeded SplitMix64 RNG, so runs are
   reproducible.
