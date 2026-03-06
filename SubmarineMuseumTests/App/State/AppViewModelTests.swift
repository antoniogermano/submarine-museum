/*
Navy Museum

Abstract:
Unit tests for app-level interaction state.
*/

import Testing

@testable import SubmarineMuseum

struct AppViewModelTests {
    @Test
    func resetExploreDebugSettingsRestoresDefaults() {
        let model = AppViewModel()
        model.exploreSubmarine.scale = 0.5
        model.exploreSubmarine.showsHotspots = false

        model.resetExploreDebugSettings()

        #expect(model.exploreSubmarine == .exploreDefault)
    }
}
