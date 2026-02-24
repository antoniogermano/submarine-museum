/*
Navy Museum

Abstract:
The stored data for the app.
*/

import SwiftUI

enum GallerySettingsOrnamentAnchor: String, CaseIterable {
    case bottom
    case top
    case leading
    case trailing

    var title: String {
        rawValue.capitalized
    }
}

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

/// The data that the app uses to configure its views.
@Observable
class ViewModel {
    // MARK: - Navigation
    var navigationPath: NavigationPath = NavigationPath()
    var titleText: String = "Submarine Museum"
    var isTitleFinished: Bool = false
    var finalTitle: String = String(localized: "Submarine Museum", comment: "The title of the app.")
    var titleYOffset: CGFloat = -300
    var finalTitleYOffset: CGFloat = 0
    var previewFavoriteIDs: Set<String>? = nil

    // MARK: - Explore
    var isShowingExplore: Bool = false

    var exploreSubmarine: SubmarineEntity.Configuration = .exploreDefault
    var previewSubmarine: SubmarineEntity.Configuration = .previewDefault
    var immersiveSubmarine: SubmarineEntity.Configuration = .immersiveDefault
    var exploreSelectedHotspotID: String? = nil
    var exploreSelectedWaypointID: String? = nil
    var isShowingSubmarineImmersive: Bool = false
    var immersiveSelectedWaypointID: String? = nil
    var immersiveTeleportRequestToken: Int = 0
    var immersiveResetRequestToken: Int = 0

    // MARK: - Gallery
    var gallerySpatialDebug: GallerySpatialDebugConfiguration = .default

    func resetExploreDebugSettings() {
        exploreSubmarine = .exploreDefault
    }

    func resetExhibitPreviewDebugSettings() {
        previewSubmarine = .previewDefault
    }

    func resetGallerySpatialDebugSettings() {
        gallerySpatialDebug = .default
    }

    func requestImmersiveTeleport(to waypointID: String) {
        immersiveSelectedWaypointID = waypointID
        immersiveTeleportRequestToken += 1
    }

    func requestImmersiveReset() {
        immersiveResetRequestToken += 1
    }

}

extension ViewModel {
    static func preview(favoriteIDs: [String]) -> ViewModel {
        let model = ViewModel()
        model.previewFavoriteIDs = Set(favoriteIDs)
        return model
    }
}
