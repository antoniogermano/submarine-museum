/*
Navy Museum

Abstract:
Configuration information for submarine entities.
*/

import RealityKit
import SwiftUI

extension SubmarineEntity {
    /// Configuration information for submarine entities.
    struct Configuration: Equatable {
        var scale: Float = 1
        var yawDegrees: Float = 0
        var pitchDegrees: Float = 0
        var rollDegrees: Float = 0
        var position: SIMD3<Float> = .zero

        var showsHotspots: Bool = true
        var hotspotOverrides: [String: [Float]] = [:]
        var showsWaypoints: Bool = true
        var waypointOverrides: [String: [Float]] = [:]

        static var exploreDefault: Configuration = .init(
            scale: 0.00628,
            yawDegrees: -46.5,
            showsHotspots: true
        )

        static var previewDefault: Configuration = .init(
            scale: 0.006,
            yawDegrees: 90,
            showsHotspots: false,
            showsWaypoints: false
        )

        static var immersiveDefault: Configuration = .init(
            scale: 0.12,
            yawDegrees: -45,
            pitchDegrees: 0,
            rollDegrees: 0,
            position: [0, -1, -2],
            showsHotspots: false,
            showsWaypoints: false
        )
    }
}
