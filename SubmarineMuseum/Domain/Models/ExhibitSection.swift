/*
Navy Museum

Abstract:
Ordered content section shown on a submarine exhibit detail page.
*/

import Foundation

struct ExhibitSection: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var body: String
    var order: Int
}
