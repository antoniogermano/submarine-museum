/*
Navy Museum

Abstract:
Image and caption shown in a submarine gallery.
*/

import Foundation

struct GalleryItem: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var caption: String
    var imageName: String
}
