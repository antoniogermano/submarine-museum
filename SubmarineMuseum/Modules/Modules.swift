/*
Navy Museum

Abstract:
The top level navigation stack for the app.
*/

import SwiftUI

/// The top level navigation stack for the app.
struct Modules: View {
    @Environment(ViewModel.self) private var model

    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var model = model

        NavigationStack(path: $model.navigationPath) {
            TableOfContents()
                .navigationDestination(for: Module.self) { module in
                    ModuleDetail(module: module)
                        .navigationTitle(module.eyebrow)
                }
                .navigationDestination(for: ExhibitRoute.self) { route in
                    switch route {
                    case .full(let submarine):
                        ExhibitDetailView(submarine: submarine)
                    case .stub(let submarine):
                        StubDetailView(submarine: submarine)
                    }
                }
        }

        // Close any open detail view when returning to the table of contents.
        .onChange(of: model.navigationPath) { _, path in
            if path.isEmpty {
                if model.isShowingExplore {
                    dismissWindow(id: SceneID.exploreVolume)
                }
                if model.isShowingSubmarineImmersive {
                    Task {
                        await dismissImmersiveSpace()
                    }
                }
            }
        }
    }
}

#Preview {
    Modules()
        .environment(ViewModel())
}
