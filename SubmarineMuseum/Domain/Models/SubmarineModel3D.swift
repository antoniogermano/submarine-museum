/*
Navy Museum

Abstract:
Metadata for the 3D model associated with a submarine.
*/

import Foundation

struct SubmarineModel3D: Codable, Equatable, Hashable {
    var usdzName: String
    var displayName: String?
}
