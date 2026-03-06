/*
Navy Museum

Abstract:
The stored data for the app.
*/

import SwiftUI

/// The data that the app uses to configure its views.
@Observable
class AppViewModel {
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

extension AppViewModel {
    static func preview(favoriteIDs: [String]) -> AppViewModel {
        let model = AppViewModel()
        model.previewFavoriteIDs = Set(favoriteIDs)
        return model
    }
}
