//
//  SandboxEngine.swift
//  DailyQuipAI
//
//  Falling-sand cellular automaton powering the physics sandbox.
//  Mirrored line for line by tools/sandbox_reference/sandbox_engine.py,
//  which is used to validate rule changes; keep the two in sync.
//

import Foundation

/// Cell material types for the falling-sand cellular automaton.
enum SandboxCell: UInt8, CaseIterable {
    case empty = 0
    case wall = 1
    case sand = 2
    case water = 3
}

/// SplitMix64 — deterministic RNG so simulations are reproducible in tests.
struct SandboxRNG {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }

    mutating func nextBool() -> Bool {
        next() & 1 == 1
    }
}

/// Falling-sand cellular automaton.
///
/// Coordinates: `x` in `0..<width` left to right, `y` in `0..<height` top to
/// bottom. Gravity points toward larger `y`. Grid edges behave like walls.
/// Each particle moves at most one cell per step.
final class SandboxEngine {
    let width: Int
    let height: Int
    private(set) var cells: [SandboxCell]
    private var moved: [Bool]
    private var rng: SandboxRNG
    private(set) var stepCount = 0

    init(width: Int, height: Int, seed: UInt64 = 0xDA11C0DE) {
        precondition(width > 0 && height > 0)
        self.width = width
        self.height = height
        cells = Array(repeating: .empty, count: width * height)
        moved = Array(repeating: false, count: width * height)
        rng = SandboxRNG(seed: seed)
    }

    func contains(x: Int, y: Int) -> Bool {
        x >= 0 && x < width && y >= 0 && y < height
    }

    func index(x: Int, y: Int) -> Int {
        y * width + x
    }

    func cell(x: Int, y: Int) -> SandboxCell {
        cells[index(x: x, y: y)]
    }

    func set(x: Int, y: Int, _ value: SandboxCell) {
        guard contains(x: x, y: y) else { return }
        cells[index(x: x, y: y)] = value
    }

    func count(of type: SandboxCell) -> Int {
        cells.reduce(0) { $1 == type ? $0 + 1 : $0 }
    }

    func clear() {
        for i in cells.indices { cells[i] = .empty }
        stepCount = 0
    }

    /// Paint a filled circle of material; used by the UI brush.
    func paint(centerX: Int, centerY: Int, radius: Int, type: SandboxCell) {
        for dy in -radius...radius {
            for dx in -radius...radius where dx * dx + dy * dy <= radius * radius {
                set(x: centerX + dx, y: centerY + dy, type)
            }
        }
    }

    /// Advance the simulation by one tick.
    func step() {
        for i in moved.indices { moved[i] = false }
        // Alternate the horizontal scan direction each tick to avoid drift bias.
        let leftToRight = stepCount % 2 == 0
        var y = height - 1
        while y >= 0 {
            for col in 0..<width {
                let x = leftToRight ? col : width - 1 - col
                let i = index(x: x, y: y)
                if moved[i] { continue }
                switch cells[i] {
                case .sand: updateSand(x: x, y: y)
                case .water: updateWater(x: x, y: y)
                case .empty, .wall: break
                }
            }
            y -= 1
        }
        stepCount += 1
    }

    private func updateSand(x: Int, y: Int) {
        let src = index(x: x, y: y)
        guard y + 1 < height else { return } // resting on the floor
        let below = index(x: x, y: y + 1)
        if cells[below] == .empty {
            move(from: src, to: below)
            return
        }
        if cells[below] == .water && !moved[below] {
            swapCells(src, below)
            return
        }
        let first = rng.nextBool() ? 1 : -1
        for dx in [first, -first] {
            let nx = x + dx
            if nx >= 0 && nx < width {
                let diag = index(x: nx, y: y + 1)
                if cells[diag] == .empty {
                    move(from: src, to: diag)
                    return
                }
            }
        }
    }

    private func updateWater(x: Int, y: Int) {
        let src = index(x: x, y: y)
        if y + 1 < height {
            let below = index(x: x, y: y + 1)
            if cells[below] == .empty {
                move(from: src, to: below)
                return
            }
            let first = rng.nextBool() ? 1 : -1
            for dx in [first, -first] {
                let nx = x + dx
                if nx >= 0 && nx < width {
                    let diag = index(x: nx, y: y + 1)
                    if cells[diag] == .empty {
                        move(from: src, to: diag)
                        return
                    }
                }
            }
        }
        let first = rng.nextBool() ? 1 : -1
        for dx in [first, -first] {
            let nx = x + dx
            if nx >= 0 && nx < width {
                let side = index(x: nx, y: y)
                if cells[side] == .empty {
                    move(from: src, to: side)
                    return
                }
            }
        }
    }

    private func move(from src: Int, to dst: Int) {
        cells[dst] = cells[src]
        cells[src] = .empty
        moved[dst] = true
    }

    private func swapCells(_ a: Int, _ b: Int) {
        cells.swapAt(a, b)
        moved[a] = true
        moved[b] = true
    }
}
