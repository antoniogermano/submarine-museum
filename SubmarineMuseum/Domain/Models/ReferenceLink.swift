/*
Navy Museum

Abstract:
External reference related to a submarine exhibit.
*/

import Foundation

struct ReferenceLink: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var url: String
}
