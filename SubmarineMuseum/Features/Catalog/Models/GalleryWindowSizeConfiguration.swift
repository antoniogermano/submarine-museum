/*
Navy Museum

Abstract:
Window sizing rules for gallery image presentation.
*/

import SwiftUI

struct GalleryWindowSizeConfiguration: Equatable {
    var minWidth: CGFloat = 765
    var minHeight: CGFloat = 442
    var idealWidth: CGFloat = 900
    var idealHeight: CGFloat = 520
    var maxWidth: CGFloat = 1080
    var maxHeight: CGFloat = 624

    static var `default`: GalleryWindowSizeConfiguration { .init() }

    static func forImage(named imageName: String) -> GalleryWindowSizeConfiguration {
        guard let imageSize = SpatialSceneImageMetrics.imageSize(named: imageName),
              imageSize.width > 0,
              imageSize.height > 0 else {
            return .default
        }

        let clampedHeight = min(max(imageSize.height, 400), 600)
        let aspectRatio = imageSize.width / imageSize.height
        let idealWidth = clampedHeight * aspectRatio
        let idealHeight = clampedHeight

        let minMultiplier: CGFloat = 0.85
        let maxMultiplier: CGFloat = 1.2

        return GalleryWindowSizeConfiguration(
            minWidth: idealWidth * minMultiplier,
            minHeight: idealHeight * minMultiplier,
            idealWidth: idealWidth,
            idealHeight: idealHeight,
            maxWidth: idealWidth * maxMultiplier,
            maxHeight: idealHeight * maxMultiplier
        )
    }
}
