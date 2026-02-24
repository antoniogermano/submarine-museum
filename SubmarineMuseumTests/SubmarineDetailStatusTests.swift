/*
Navy Museum

Abstract:
Unit tests for submarine detail status and model data.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct SubmarineDetailStatusTests {
    @Test
    func exactlyOneFullDetailSubmarine() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let submarines = await repository.fetchAllSubmarines()
        let full = submarines.filter { $0.detailStatus == .full }

        #expect(full.count == 1)
        if let fullSubmarine = full.first {
            let modelName = fullSubmarine.model3D?.usdzName ?? ""
            #expect(modelName.isEmpty == false)
            #expect(fullSubmarine.hotspots.isEmpty == false)
            #expect(fullSubmarine.waypoints.isEmpty == false)
        }
    }

    @Test
    func hotspotLookupById() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let submarines = await repository.fetchAllSubmarines()
        guard let fullSubmarine = submarines.first(where: { $0.detailStatus == .full }) else {
            #expect(Bool(false))
            return
        }
        let hotspot = fullSubmarine.hotspot(id: fullSubmarine.hotspots.first?.id ?? "")
        #expect(hotspot != nil)
    }

    @Test
    func waypointLookupById() async throws {
        let repository = SubmarineRepository(bundle: .main)
        let submarines = await repository.fetchAllSubmarines()
        guard let fullSubmarine = submarines.first(where: { $0.detailStatus == .full }) else {
            #expect(Bool(false))
            return
        }
        let waypoint = fullSubmarine.waypoint(id: fullSubmarine.waypoints.first?.id ?? "")
        #expect(waypoint != nil)
    }
}
