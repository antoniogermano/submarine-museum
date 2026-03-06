/*
Navy Museum

Abstract:
Unit tests for strict waypoint SIMD3 position decoding.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct WaypointPositionDecodingTests {
    @Test
    func validPositionDecodes() throws {
        let waypoint = try decodeWaypoint(from: """
        {
            "id": "w1",
            "title": "Bridge",
            "detail": "Command area",
            "position": [1.25, -0.5, 3.0]
        }
        """)

        #expect(waypoint.position == SIMD3<Float>(1.25, -0.5, 3.0))
    }

    @Test
    func positionWithFewerThanThreeElementsThrows() {
        #expect(throws: Error.self) {
            _ = try decodeWaypoint(from: """
            {
                "id": "w1",
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
            _ = try decodeWaypoint(from: """
            {
                "id": "w1",
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
            _ = try decodeWaypoint(from: """
            {
                "id": "w1",
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
            _ = try decodeWaypoint(from: """
            {
                "id": "w1",
                "title": "Bridge",
                "detail": "Command area",
                "position": [10001.0, 0.0, 0.0]
            }
            """)
        }
    }

    private func decodeWaypoint(from json: String) throws -> Waypoint {
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Waypoint.self, from: data)
    }
}
