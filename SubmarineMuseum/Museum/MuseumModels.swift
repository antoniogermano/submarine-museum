/*
Navy Museum

Abstract:
Data models for the Submarine Museum domain.
*/

import Foundation
import simd

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

struct SubmarineModel3D: Codable, Equatable, Hashable {
    var usdzName: String
    var displayName: String?
}

struct Hotspot: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var detail: String
    var position: SIMD3<Float>

    enum CodingKeys: String, CodingKey {
        case id, title, detail, position
    }

    init(id: String, title: String, detail: String, position: SIMD3<Float>) {
        self.id = id
        self.title = title
        self.detail = detail
        self.position = position
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decode(String.self, forKey: .detail)

        let decodedPosition = try container.decode(SIMD3<Float>.self, forKey: .position)
        let limit: Float = 10_000
        let values = [decodedPosition.x, decodedPosition.y, decodedPosition.z]

        for value in values {
            guard value.isFinite else {
                throw DecodingError.dataCorruptedError(
                    forKey: .position,
                    in: container,
                    debugDescription: "Hotspot position contains non-finite value: \(value)."
                )
            }
            guard abs(value) <= limit else {
                throw DecodingError.dataCorruptedError(
                    forKey: .position,
                    in: container,
                    debugDescription: "Hotspot position value \(value) exceeds allowed magnitude \(limit)."
                )
            }
        }

        position = decodedPosition
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
        try container.encode([position.x, position.y, position.z], forKey: .position)
    }
}

struct Waypoint: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var detail: String
    var position: SIMD3<Float>

    enum CodingKeys: String, CodingKey {
        case id, title, detail, position
    }

    init(id: String, title: String, detail: String, position: SIMD3<Float>) {
        self.id = id
        self.title = title
        self.detail = detail
        self.position = position
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decode(String.self, forKey: .detail)

        let decodedPosition = try container.decode(SIMD3<Float>.self, forKey: .position)
        let limit: Float = 10_000
        let values = [decodedPosition.x, decodedPosition.y, decodedPosition.z]

        for value in values {
            guard value.isFinite else {
                throw DecodingError.dataCorruptedError(
                    forKey: .position,
                    in: container,
                    debugDescription: "Waypoint position contains non-finite value: \(value)."
                )
            }
            guard abs(value) <= limit else {
                throw DecodingError.dataCorruptedError(
                    forKey: .position,
                    in: container,
                    debugDescription: "Waypoint position value \(value) exceeds allowed magnitude \(limit)."
                )
            }
        }

        position = decodedPosition
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
        try container.encode([position.x, position.y, position.z], forKey: .position)
    }
}

struct SubmarineClass: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var role: String
    var notes: String?
}

struct ExhibitSection: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var body: String
    var order: Int
}

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

struct GalleryItem: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var caption: String
    var imageName: String
}

struct ReferenceLink: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var title: String
    var url: String
}
