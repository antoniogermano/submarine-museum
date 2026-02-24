/*
Navy Museum

Abstract:
A toggle that activates or deactivates the submarine immersive scene.
*/

import SwiftUI

struct SubmarineImmersiveToggle: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var model = model

        Toggle(model.isShowingSubmarineImmersive ? "Hide immersive" : Module.immersive.callToAction, isOn: $model.isShowingSubmarineImmersive)
            .onChange(of: model.isShowingSubmarineImmersive) { _, isShowing in
                Task {
                    if isShowing {
                        await openImmersiveSpace(id: SceneID.submarineImmersive)
                    } else {
                        await dismissImmersiveSpace()
                    }
                }
            }
            .toggleStyle(.button)
    }
}

#Preview {
    SubmarineImmersiveToggle()
        .environment(ViewModel())
}
