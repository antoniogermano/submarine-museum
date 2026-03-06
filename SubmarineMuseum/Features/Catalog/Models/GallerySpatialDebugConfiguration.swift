/*
Navy Museum

Abstract:
Debug configuration for the spatial gallery image presentation.
*/

import Foundation
import simd

struct GallerySpatialDebugConfiguration: Equatable {
    var scaleMultiplier: Float = 1
    var position: SIMD3<Float> = [0, 0, 0.002]
    var frameWidth: Double = 900
    var frameHeight: Double = 520
    var frameCornerRadius: Double = 24

    var showSettingsOrnament: Bool = true
    var settingsOrnamentAnchor: GallerySettingsOrnamentAnchor = .bottom

    static var `default`: GallerySpatialDebugConfiguration { .init() }
}
