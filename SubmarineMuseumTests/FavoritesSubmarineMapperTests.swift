/*
Navy Museum

Abstract:
Unit tests for favorites mapping and ordering.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct FavoritesSubmarineMapperTests {
    @Test
    func mapFiltersMissingIDsAndSortsByDisplayTitle() {
        let alpha = makeSubmarine(id: "alpha", name: "USS Alpha", detailStatus: .stub)
        let zulu = makeSubmarine(id: "zulu", name: "USS Zulu", detailStatus: .full)
        let bravo = makeSubmarine(id: "bravo", name: "USS Bravo", detailStatus: .stub)

        let favoriteIDs: Set<String> = ["zulu", "missing", "bravo"]
        let result = FavoritesSubmarineMapper.map(
            submarines: [alpha, zulu, bravo],
            favoriteIDs: favoriteIDs
        )

        #expect(result.map(\.id) == ["bravo", "zulu"])
    }

    private func makeSubmarine(id: String, name: String, detailStatus: Submarine.DetailStatus) -> Submarine {
        Submarine(
            id: id,
            name: name,
            submarineClass: nil,
            era: "Cold War",
            nation: "United States",
            commissionYear: 1950,
            decommissionYear: nil,
            lengthMeters: 90,
            displacementTons: 1000,
            status: "Museum ship",
            summary: "Summary",
            profileImageName: nil,
            detailStatus: detailStatus,
            model3D: nil,
            hotspots: [],
            waypoints: [],
            exhibitSections: [],
            galleryItems: [],
            referenceLinks: [],
            locations: [
                Location(
                    id: "loc1",
                    name: "Museum",
                    city: "City",
                    region: "Region",
                    country: "Country",
                    kind: .museum,
                    latitude: 0,
                    longitude: 0,
                    notes: nil
                ),
                Location(
                    id: "loc2",
                    name: "Historic Site",
                    city: "City",
                    region: "Region",
                    country: "Country",
                    kind: .historicalSite,
                    latitude: 0,
                    longitude: 0,
                    notes: nil
                )
            ]
        )
    }
}
