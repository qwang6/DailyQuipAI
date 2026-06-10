//
//  PhysicsSandboxView.swift
//  DailyQuipAI
//
//  Interactive falling-sand playground: draw sand, water and walls and watch
//  the cellular automaton run.
//

import SwiftUI

final class PhysicsSandboxViewModel: ObservableObject {
    static let gridWidth = 72
    static let gridHeight = 108

    let engine = SandboxEngine(
        width: PhysicsSandboxViewModel.gridWidth,
        height: PhysicsSandboxViewModel.gridHeight,
        seed: UInt64(Date().timeIntervalSince1970)
    )

    @Published var selectedMaterial: SandboxCell = .sand
    @Published var isPaused = false
    @Published private(set) var frame = 0

    func tick() {
        guard !isPaused else { return }
        engine.step()
        frame += 1
    }

    func paint(at point: CGPoint, canvasSize: CGSize) {
        let cellSize = min(canvasSize.width / CGFloat(engine.width),
                           canvasSize.height / CGFloat(engine.height))
        guard cellSize > 0 else { return }
        let x = Int(point.x / cellSize)
        let y = Int(point.y / cellSize)
        let radius = selectedMaterial == .wall || selectedMaterial == .empty ? 2 : 3
        engine.paint(centerX: x, centerY: y, radius: radius, type: selectedMaterial)
        frame += 1
    }

    func clear() {
        engine.clear()
        frame += 1
    }
}

struct PhysicsSandboxView: View {
    @StateObject private var viewModel = PhysicsSandboxViewModel()

    private let simulationTimer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: Spacing.sm) {
            canvas
            controls
        }
        .padding(Spacing.sm)
        .navigationTitle("sandbox.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(simulationTimer) { _ in
            viewModel.tick()
        }
    }

    private var canvas: some View {
        GeometryReader { proxy in
            let engine = viewModel.engine
            let frame = viewModel.frame
            let cellSize = min(proxy.size.width / CGFloat(engine.width),
                               proxy.size.height / CGFloat(engine.height))
            let gridSize = CGSize(width: cellSize * CGFloat(engine.width),
                                  height: cellSize * CGFloat(engine.height))

            Canvas { context, _ in
                // Capture the frame counter so the canvas redraws every tick.
                _ = frame
                context.fill(Path(CGRect(origin: .zero, size: gridSize)), with: .color(Color(white: 0.08)))
                for y in 0..<engine.height {
                    for x in 0..<engine.width {
                        let cell = engine.cells[engine.index(x: x, y: y)]
                        guard cell != .empty else { continue }
                        let rect = CGRect(x: CGFloat(x) * cellSize,
                                          y: CGFloat(y) * cellSize,
                                          width: cellSize,
                                          height: cellSize)
                        context.fill(Path(rect), with: .color(Self.color(for: cell)))
                    }
                }
            }
            .frame(width: gridSize.width, height: gridSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        viewModel.paint(at: value.location, canvasSize: gridSize)
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var controls: some View {
        VStack(spacing: Spacing.sm) {
            Picker("sandbox.material".localized, selection: $viewModel.selectedMaterial) {
                Text("sandbox.material.sand".localized).tag(SandboxCell.sand)
                Text("sandbox.material.water".localized).tag(SandboxCell.water)
                Text("sandbox.material.wall".localized).tag(SandboxCell.wall)
                Text("sandbox.material.eraser".localized).tag(SandboxCell.empty)
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    viewModel.isPaused.toggle()
                } label: {
                    Label(
                        (viewModel.isPaused ? "sandbox.resume" : "sandbox.pause").localized,
                        systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                    )
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(role: .destructive) {
                    viewModel.clear()
                } label: {
                    Label("sandbox.clear".localized, systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private static func color(for cell: SandboxCell) -> Color {
        switch cell {
        case .empty: return .clear
        case .wall: return Color(white: 0.55)
        case .sand: return Color(red: 0.91, green: 0.75, blue: 0.40)
        case .water: return Color(red: 0.25, green: 0.55, blue: 0.95)
        }
    }
}

struct PhysicsSandboxViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhysicsSandboxView()
        }
    }
}
