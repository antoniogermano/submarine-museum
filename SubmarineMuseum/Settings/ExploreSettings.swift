/*
Navy Museum

Abstract:
Debug setting controls for the explore module.
*/

import SwiftUI

/// Debug setting controls for the explore module.
struct ExploreSettings: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack {
            Text("Explore debug settings", comment: "The title of the settings presented to the viewer.")
                .font(.title)
            Form {
                ExploreHotspotSettings(
                    configuration: $model.exploreSubmarine,
                    selectedHotspotID: $model.exploreSelectedHotspotID
                )
                ExploreWaypointSettings(
                    configuration: $model.exploreSubmarine,
                    selectedWaypointID: $model.exploreSelectedWaypointID
                )
                ExploreModelSettings(configuration: $model.exploreSubmarine)
                ExhibitPreviewSettings(configuration: $model.previewSubmarine)
                Section(String(localized: "System", comment: "Section title of system level settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        Button {
                            resetDebugSettings()
                        } label: {
                            Text("Reset", comment: "Action to reset the settings to their default values.")
                        }
                    }
                }
            }
        }
    }

    private func resetDebugSettings() {
        model.resetExploreDebugSettings()
        model.resetExhibitPreviewDebugSettings()
        model.exploreSelectedHotspotID = nil
        model.exploreSelectedWaypointID = nil
    }
}

#Preview {
    ExploreSettings()
        .frame(width: 500)
        .environment(ViewModel())
}
