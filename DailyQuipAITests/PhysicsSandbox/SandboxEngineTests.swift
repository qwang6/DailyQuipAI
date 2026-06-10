//
//  SandboxEngineTests.swift
//  DailyQuipAITests
//
//  Correctness tests for the falling-sand cellular automaton.
//  Mirrored by tools/sandbox_reference/sandbox_engine_tests.py.
//

import XCTest
@testable import DailyQuipAI

final class SandboxEngineTests: XCTestCase {

    /// Step until the grid stops changing; returns steps taken, or nil if it
    /// never stabilised within `maxSteps`.
    private func runUntilStable(_ engine: SandboxEngine, maxSteps: Int) -> Int? {
        for i in 0..<maxSteps {
            let before = engine.cells
            engine.step()
            if engine.cells == before { return i + 1 }
        }
        return nil
    }

    /// Number of cells of the given types in column x.
    private func columnFillHeight(_ engine: SandboxEngine, x: Int, types: Set<SandboxCell>) -> Int {
        (0..<engine.height).reduce(0) { types.contains(engine.cell(x: x, y: $1)) ? $0 + 1 : $0 }
    }

    // MARK: - Basic kinematics

    func testSandFallsExactlyOneCellPerStep() {
        let e = SandboxEngine(width: 5, height: 10)
        e.set(x: 2, y: 0, .sand)
        for step in 0..<9 {
            e.step()
            XCTAssertEqual(e.cell(x: 2, y: step), .empty)
            XCTAssertEqual(e.cell(x: 2, y: step + 1), .sand)
        }
    }

    func testSandRestsOnFloor() {
        let e = SandboxEngine(width: 5, height: 10)
        e.set(x: 2, y: 9, .sand)
        e.step()
        XCTAssertEqual(e.cell(x: 2, y: 9), .sand)
        XCTAssertEqual(e.count(of: .sand), 1)
    }

    func testSandRestsOnWall() {
        let e = SandboxEngine(width: 3, height: 10)
        // Wall shelf across the full width so sand cannot slide off it.
        for x in 0..<3 { e.set(x: x, y: 5, .wall) }
        e.set(x: 1, y: 0, .sand)
        for _ in 0..<20 { e.step() }
        XCTAssertEqual(e.cell(x: 1, y: 4), .sand)
        XCTAssertEqual(e.cell(x: 1, y: 5), .wall)
    }

    func testFullSandLayerIsStable() {
        let e = SandboxEngine(width: 8, height: 8)
        for x in 0..<8 {
            e.set(x: x, y: 7, .sand)
            e.set(x: x, y: 6, .sand)
        }
        let before = e.cells
        for _ in 0..<10 { e.step() }
        XCTAssertEqual(e.cells, before)
    }

    // MARK: - Conservation laws

    func testMassConservationInRandomSoup() {
        let e = SandboxEngine(width: 40, height: 60, seed: 7)
        var placement = SandboxRNG(seed: 99)
        for y in 0..<60 {
            for x in 0..<40 {
                switch placement.next() % 10 {
                case 0: e.set(x: x, y: y, .wall)
                case 1, 2: e.set(x: x, y: y, .sand)
                case 3, 4: e.set(x: x, y: y, .water)
                default: break
                }
            }
        }
        let counts = SandboxCell.allCases.map { ($0, e.count(of: $0)) }
        for _ in 0..<400 { e.step() }
        for (type, n) in counts {
            XCTAssertEqual(e.count(of: type), n, "count changed for \(type)")
        }
    }

    func testWallsNeverMove() {
        let e = SandboxEngine(width: 20, height: 20, seed: 3)
        let wallPositions = [(3, 3), (10, 15), (19, 19), (0, 0), (5, 10)]
        for (x, y) in wallPositions { e.set(x: x, y: y, .wall) }
        e.paint(centerX: 10, centerY: 2, radius: 3, type: .sand)
        e.paint(centerX: 10, centerY: 8, radius: 3, type: .water)
        for _ in 0..<200 { e.step() }
        for (x, y) in wallPositions {
            XCTAssertEqual(e.cell(x: x, y: y), .wall)
        }
    }

    // MARK: - Sand behaviour

    func testSandColumnCollapsesIntoSupportedPile() {
        let e = SandboxEngine(width: 21, height: 30, seed: 11)
        for y in 0..<10 { e.set(x: 10, y: y, .sand) }
        let total = e.count(of: .sand)
        XCTAssertNotNil(runUntilStable(e, maxSteps: 500), "pile never stabilised")
        XCTAssertEqual(e.count(of: .sand), total)
        // No floating sand: every grain rests on the floor or on something.
        for y in 0..<(e.height - 1) {
            for x in 0..<e.width where e.cell(x: x, y: y) == .sand {
                XCTAssertNotEqual(e.cell(x: x, y: y + 1), .empty, "floating sand at (\(x), \(y))")
            }
        }
        // The column spread sideways into a pile wider than one cell.
        let occupiedColumns = Set(
            (0..<e.width).filter { x in (0..<e.height).contains { e.cell(x: x, y: $0) == .sand } }
        )
        XCTAssertGreaterThan(occupiedColumns.count, 1)
    }

    func testSandSinksThroughWater() {
        let e = SandboxEngine(width: 7, height: 12, seed: 5)
        // Water pool in a wall basin, sand grain dropped from above.
        for y in 8..<12 {
            e.set(x: 0, y: y, .wall)
            e.set(x: 6, y: y, .wall)
        }
        for x in 1..<6 {
            for y in 8..<11 { e.set(x: x, y: y, .water) }
        }
        e.set(x: 3, y: 0, .sand)
        for _ in 0..<60 { e.step() }
        XCTAssertEqual(e.count(of: .sand), 1)
        var sandPosition: (x: Int, y: Int)?
        for y in 0..<e.height {
            for x in 0..<e.width where e.cell(x: x, y: y) == .sand {
                sandPosition = (x, y)
            }
        }
        guard let sand = sandPosition else { return XCTFail("sand disappeared") }
        XCTAssertEqual(sand.y, 11, "sand should reach the basin floor")
        XCTAssertEqual(e.cell(x: sand.x, y: sand.y - 1), .water, "sand should be submerged under water")
    }

    // MARK: - Water behaviour

    func testWaterLevelsOutInABasin() {
        let e = SandboxEngine(width: 32, height: 20, seed: 13)
        // Basin: floor walls plus side walls up to y = 10.
        for x in 0..<32 { e.set(x: x, y: 19, .wall) }
        for y in 10..<19 {
            e.set(x: 0, y: y, .wall)
            e.set(x: 31, y: y, .wall)
        }
        // Water block stacked against the left wall.
        for x in 1..<9 {
            for y in 11..<19 { e.set(x: x, y: y, .water) }
        }
        let waterTotal = e.count(of: .water)
        for _ in 0..<4000 { e.step() }
        XCTAssertEqual(e.count(of: .water), waterTotal)
        let heights = (1..<31).map { columnFillHeight(e, x: $0, types: [.water]) }
        XCTAssertLessThanOrEqual(
            heights.max()! - heights.min()!, 1,
            "water surface not level: \(heights)"
        )
        // No floating water: every water cell sits on water, wall or floor.
        for y in 0..<(e.height - 1) {
            for x in 0..<e.width where e.cell(x: x, y: y) == .water {
                XCTAssertNotEqual(e.cell(x: x, y: y + 1), .empty)
            }
        }
    }

    func testWaterStaysInsideSealedBox() {
        let e = SandboxEngine(width: 12, height: 12, seed: 17)
        for i in 0..<12 {
            e.set(x: i, y: 2, .wall)
            e.set(x: i, y: 9, .wall)
        }
        for y in 2..<10 {
            e.set(x: 2, y: y, .wall)
            e.set(x: 9, y: y, .wall)
        }
        for x in 3..<9 {
            for y in 6..<9 { e.set(x: x, y: y, .water) }
        }
        let total = e.count(of: .water)
        for _ in 0..<300 { e.step() }
        XCTAssertEqual(e.count(of: .water), total)
        for y in 0..<e.height {
            for x in 0..<e.width where e.cell(x: x, y: y) == .water {
                XCTAssertTrue((3...8).contains(x) && (3...8).contains(y), "water escaped to (\(x), \(y))")
            }
        }
    }

    // MARK: - Engine guarantees

    func testEachParticleMovesAtMostOneCellPerStep() {
        let e = SandboxEngine(width: 15, height: 30, seed: 23)
        e.paint(centerX: 7, centerY: 3, radius: 2, type: .sand)
        e.paint(centerX: 7, centerY: 10, radius: 2, type: .water)
        for _ in 0..<100 {
            let before = e.cells
            e.step()
            // A displacement of more than one cell would leave some particle
            // at Chebyshev distance > 1 from every prior cell of its type.
            for y in 0..<e.height {
                for x in 0..<e.width {
                    let c = e.cell(x: x, y: y)
                    guard c == .sand || c == .water else { continue }
                    var near = false
                    for ny in max(0, y - 1)...min(e.height - 1, y + 1) {
                        for nx in max(0, x - 1)...min(e.width - 1, x + 1) where before[ny * e.width + nx] == c {
                            near = true
                        }
                    }
                    XCTAssertTrue(near, "particle teleported to (\(x), \(y))")
                }
            }
        }
    }

    func testDeterminismSameSeedSameResult() {
        func build(seed: UInt64) -> SandboxEngine {
            let e = SandboxEngine(width: 30, height: 40, seed: seed)
            e.paint(centerX: 10, centerY: 5, radius: 3, type: .sand)
            e.paint(centerX: 20, centerY: 5, radius: 3, type: .water)
            for x in 8..<25 { e.set(x: x, y: 30, .wall) }
            return e
        }
        let a = build(seed: 42)
        let b = build(seed: 42)
        for _ in 0..<300 {
            a.step()
            b.step()
        }
        XCTAssertEqual(a.cells, b.cells)
    }

    func testDifferentSeedsCanDiverge() {
        func build(seed: UInt64) -> SandboxEngine {
            let e = SandboxEngine(width: 30, height: 40, seed: seed)
            e.paint(centerX: 15, centerY: 5, radius: 4, type: .sand)
            for x in 10..<21 { e.set(x: x, y: 20, .wall) }
            return e
        }
        let a = build(seed: 1)
        let b = build(seed: 2)
        for _ in 0..<50 {
            a.step()
            b.step()
        }
        XCTAssertNotEqual(a.cells, b.cells)
    }

    func testParticlesInCornersDoNotCrashOrEscape() {
        let e = SandboxEngine(width: 4, height: 4, seed: 29)
        e.set(x: 0, y: 0, .sand)
        e.set(x: 3, y: 0, .sand)
        e.set(x: 0, y: 3, .water)
        e.set(x: 3, y: 3, .water)
        for _ in 0..<100 { e.step() }
        XCTAssertEqual(e.count(of: .sand), 2)
        XCTAssertEqual(e.count(of: .water), 2)
    }
}
