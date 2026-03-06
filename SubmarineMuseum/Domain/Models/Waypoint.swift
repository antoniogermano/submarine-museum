/*
Navy Museum

Abstract:
Navigation point used to guide spatial exploration of a submarine.
*/

import Foundation
import simd

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
