/*
Navy Museum

Abstract:
Classification metadata for a submarine.
*/

import Foundation

struct SubmarineClass: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var role: String
    var notes: String?
}
