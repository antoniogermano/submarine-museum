/*
Navy Museum

Abstract:
Museum, memorial, or site associated with a submarine.
*/

import Foundation

struct Location: Identifiable, Codable, Equatable, Hashable {
    enum Kind: String, Codable {
        case museum
        case historicalSite
        case shipyard
        case memorial
    }

    var id: String
    var name: String
    var city: String
    var region: String
    var country: String
    var kind: Kind
    var latitude: Double
    var longitude: Double
    var notes: String?

    func validated() -> Bool {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !country.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180
    }
}
