/*
Navy Museum

Abstract:
Anchor options for the gallery settings ornament in spatial presentation.
*/

import Foundation

enum GallerySettingsOrnamentAnchor: String, CaseIterable {
    case bottom
    case top
    case leading
    case trailing

    var title: String {
        rawValue.capitalized
    }
}
