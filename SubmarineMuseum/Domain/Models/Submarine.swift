/*
Navy Museum

Abstract:
Core submarine model used across the museum experience.
*/

import Foundation

struct Submarine: Identifiable, Codable, Equatable, Hashable {
    enum DetailStatus: String, Codable {
        case full
        case stub
    }

    var id: String
    var name: String
    var submarineClass: SubmarineClass?
    var era: String
    var nation: String
    var commissionYear: Int
    var decommissionYear: Int?
    var lengthMeters: Double
    var displacementTons: Int
    var status: String
    var summary: String
    var profileImageName: String?
    var detailStatus: DetailStatus
    var model3D: SubmarineModel3D?
    var hotspots: [Hotspot]
    var waypoints: [Waypoint] = []
    var exhibitSections: [ExhibitSection]
    var galleryItems: [GalleryItem]
    var referenceLinks: [ReferenceLink]
    var locations: [Location]

    var displayTitle: String {
        if let submarineClass {
            return "\(name) (\(submarineClass.name))"
        }
        return name
    }

    func hotspot(id: String) -> Hotspot? {
        hotspots.first { $0.id == id }
    }

    func waypoint(id: String) -> Waypoint? {
        waypoints.first { $0.id == id }
    }

    func validated() -> Bool {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !era.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !nation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard commissionYear > 1900 else { return false }
        guard lengthMeters > 0 else { return false }
        guard displacementTons > 0 else { return false }
        guard locations.count >= 2 else { return false }
        guard locations.allSatisfy({ $0.validated() }) else { return false }

        if detailStatus == .full {
            guard let model3D else { return false }
            guard !model3D.usdzName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
            guard !hotspots.isEmpty else { return false }
            guard !waypoints.isEmpty else { return false }
        }

        return true
    }

    static func == (lhs: Submarine, rhs: Submarine) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
