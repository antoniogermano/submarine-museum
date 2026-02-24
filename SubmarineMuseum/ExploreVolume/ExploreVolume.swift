/*
Navy Museum

Abstract:
The explore content for a volume.
*/

import SwiftUI

/// The explore content for a volume.
struct ExploreVolume: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        SubmarineExploreView()
            .environment(model)
            .onDisappear {
                model.isShowingExplore = false
            }
    }
}

#Preview {
    ExploreVolume()
        .environment(ViewModel())
}
