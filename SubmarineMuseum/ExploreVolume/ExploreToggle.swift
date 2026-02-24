/*
Navy Museum

Abstract:
A toggle that activates or deactivates the explore volume.
*/

import SwiftUI

/// A toggle that activates or deactivates the explore volume.
struct ExploreToggle: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        @Bindable var model = model

        Toggle(Module.explore.callToAction, isOn: $model.isShowingExplore)
            .onChange(of: model.isShowingExplore) { _, isShowing in
                if isShowing {
                    openWindow(id: SceneID.exploreVolume)
                } else {
                    dismissWindow(id: SceneID.exploreVolume)
                }
            }
            .toggleStyle(.button)
    }
}

#Preview {
    ExploreToggle()
        .environment(ViewModel())
}
