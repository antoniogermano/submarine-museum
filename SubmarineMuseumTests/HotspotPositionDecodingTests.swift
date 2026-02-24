/*
Navy Museum

Abstract:
Unit tests for strict hotspot SIMD3 position decoding.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct HotspotPositionDecodingTests {
    @Test
    func validPositionDecodes() throws {
        let hotspot = try decodeHotspot(from: """
        {
            "id": "h1",
            "title": "Bridge",
            "detail": "Command area",
            "position": [1.25, -0.5, 3.0]
        }
        """)

        #expect(hotspot.position == SIMD3<Float>(1.25, -0.5, 3.0))
    }

    @Test
    func positionWithFewerThanThreeElementsThrows() {
        #expect(throws: Error.self) {
            _ = try decodeHotspot(from: """
            {
                "id": "h1",
                "title": "Bridge",
                "detail": "Command area",
                "position": [1.0, 2.0]
            }
            """)
        }
    }

    @Test
    func positionWithMoreThanThreeElementsThrows() {
        #expect(throws: Error.self) {
            _ = try decodeHotspot(from: """
            {
                "id": "h1",
                "title": "Bridge",
                "detail": "Command area",
                "position": [1.0, 2.0, 3.0, 4.0]
            }
            """)
        }
    }

    @Test
    func positionWithNaNOrInfinityThrows() {
        #expect(throws: Error.self) {
            _ = try decodeHotspot(from: """
            {
                "id": "h1",
                "title": "Bridge",
                "detail": "Command area",
                "position": [1e309, 0.0, 0.0]
            }
            """)
        }
    }

    @Test
    func positionWithAbsurdMagnitudeThrows() {
        #expect(throws: Error.self) {
            _ = try decodeHotspot(from: """
            {
                "id": "h1",
                "title": "Bridge",
                "detail": "Command area",
                "position": [10001.0, 0.0, 0.0]
            }
            """)
        }
    }

    private func decodeHotspot(from json: String) throws -> Hotspot {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Hotspot.self, from: data)
    }
}
