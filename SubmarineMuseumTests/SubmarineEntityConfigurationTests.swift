/*
Navy Museum

Abstract:
Tests for submarine entity configuration defaults and view-model resets.
*/

import Testing

@testable import SubmarineMuseum

struct SubmarineEntityConfigurationTests {
    @Test
    func defaultConfigurationsAreStable() {
        let explore = SubmarineEntity.Configuration.exploreDefault
        #expect(explore.scale == 0.00628)
        #expect(explore.yawDegrees == -46.5)
        #expect(explore.showsHotspots)
        #expect(explore.hotspotOverrides.isEmpty)
        #expect(explore.showsWaypoints)
        #expect(explore.waypointOverrides.isEmpty)

        let preview = SubmarineEntity.Configuration.previewDefault
        #expect(preview.scale == 0.006)
        #expect(preview.yawDegrees == 90)
        #expect(preview.showsHotspots == false)
        #expect(preview.showsWaypoints == false)
    }

    @Test
    func viewModelResetUsesEntityConfigurationDefaults() {
        let model = ViewModel()

        model.exploreSubmarine.scale = 0.1
        model.exploreSubmarine.yawDegrees = 123
        model.exploreSubmarine.hotspotOverrides = ["h": [1, 2, 3]]
        model.exploreSubmarine.waypointOverrides = ["w": [1, 2, 3]]
        model.previewSubmarine.scale = 0.01

        model.resetExploreDebugSettings()
        model.resetExhibitPreviewDebugSettings()

        #expect(model.exploreSubmarine == .exploreDefault)
        #expect(model.previewSubmarine == .previewDefault)
    }
}
