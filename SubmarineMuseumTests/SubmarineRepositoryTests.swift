/*
Navy Museum

Abstract:
Unit tests for submarine repository data.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct SubmarineRepositoryTests {
    @Test
    func decodingSubmarinesJSON() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let submarines = await repository.fetchAllSubmarines()

        #expect(submarines.count >= 8)
        #expect(submarines.contains { $0.id == "uss-gato-ss-212" })
        #expect(submarines.allSatisfy { $0.locations.count >= 2 })
    }

    @Test
    func searchFindsGato() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let results = await repository.search(query: "Gato")

        #expect(results.contains { $0.id == "uss-gato-ss-212" })
    }

    @Test
    func filterByEraAndNation() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let results = await repository.filter(era: "Cold War", nation: "United States")
        let ids = Set(results.map { $0.id })

        #expect(ids.contains("uss-nautilus-ssn-571"))
        #expect(ids.contains("uss-growler-ssg-577"))
    }
}
