//
//  DeviceSize.swift
//  DailyQuipAI
//
//  Created by Claude on 10/4/25.
//

import SwiftUI

/// Device size detection and responsive design utilities
struct DeviceSize {
    /// Check if current device is iPad
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    /// Check if current device is iPhone
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    /// Get adaptive card width based on device
    static func cardWidth(for geometry: GeometryProxy) -> CGFloat {
        if isIPad {
            // iPad: Max 600pt width for comfortable reading
            return min(600, geometry.size.width * 0.7)
        } else {
            // iPhone: Full width with padding
            return geometry.size.width - (Spacing.md * 2)
        }
    }

    /// Get adaptive card height based on device
    static func cardHeight(for geometry: GeometryProxy) -> CGFloat {
        if isIPad {
            // iPad: Maintain aspect ratio
            return geometry.size.height * 0.75
        } else {
            // iPhone: Full height minus progress indicator
            return geometry.size.height - 60
        }
    }

    /// Get adaptive corner radius
    static var cardCornerRadius: CGFloat {
        isIPad ? 48 : 40
    }

    /// Get adaptive title font size
    static var cardTitleSize: CGFloat {
        isIPad ? 36 : 28
    }

    /// Get adaptive body font size
    static var cardBodySize: CGFloat {
        isIPad ? 20 : 16
    }

    /// Get adaptive category tag size
    static var categoryTagSize: CGFloat {
        isIPad ? 16 : 13
    }

    /// Get number of columns for grid layouts
    static var gridColumns: Int {
        isIPad ? 3 : 2
    }
}

/// View extension for device-specific modifiers
extension View {
    /// Apply padding based on device type
    func paddingAdaptive() -> some View {
        self.padding(DeviceSize.isIPad ? Spacing.xl : Spacing.md)
    }

    /// Frame for centered iPad content
    func iPadCentered(in geometry: GeometryProxy) -> some View {
        self.frame(
            width: DeviceSize.isIPad ? min(800, geometry.size.width * 0.8) : geometry.size.width,
            alignment: .center
        )
    }
}
