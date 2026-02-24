/*
Navy Museum

Abstract:
Section views for the main navigation information architecture.
*/

import SwiftUI

struct ExploreSectionView: View {
    var body: some View {
        ExploreModule()
    }
}

struct ImmersiveSectionView: View {
    @Environment(ViewModel.self) private var model

    @State private var submarine: Submarine?
    private let repository = SubmarineRepository.shared

    var body: some View {
        @Bindable var model = model

        VStack(alignment: .leading, spacing: 14) {
            Text("Immersive Controls")
                .font(.title2)

            Text("Step in for a full-scale submarine view and inspect details up close.")
                .foregroundStyle(.secondary)

            if model.isShowingSubmarineImmersive, let submarine, !submarine.waypoints.isEmpty {
                Picker(
                    "Waypoint",
                    selection: Binding(
                        get: { model.immersiveSelectedWaypointID ?? submarine.waypoints.first?.id ?? "" },
                        set: { newValue in
                            model.requestImmersiveTeleport(to: newValue)
                        }
                    )
                ) {
                    ForEach(submarine.waypoints) { waypoint in
                        Text(waypoint.title).tag(waypoint.id)
                    }
                }
                .pickerStyle(.menu)

                HStack(spacing: 12) {
                    Button("Teleport") {
                        guard let waypointID = model.immersiveSelectedWaypointID ?? submarine.waypoints.first?.id else { return }
                        model.requestImmersiveTeleport(to: waypointID)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Reset") {
                        model.requestImmersiveReset()
                    }
                    .buttonStyle(.bordered)
                }

                Toggle("Show Hotspots", isOn: $model.exploreSubmarine.showsHotspots)
                Toggle("Show Waypoints", isOn: $model.exploreSubmarine.showsWaypoints)
            } else {
                Text("Enter immersive mode to access waypoint picker and scene controls.")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(24)
        .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        .task {
            await loadImmersiveSubmarine()
        }
    }

    private func loadImmersiveSubmarine() async {
        submarine = await repository.fetchAllSubmarines().first { $0.detailStatus == .full }
        if model.immersiveSelectedWaypointID == nil {
            model.immersiveSelectedWaypointID = submarine?.waypoints.first?.id
        }
    }
}

#Preview("Explore") {
    ExploreSectionView()
        .padding()
}

#Preview("Favorites") {
    FavoritesSectionView()
        .padding()
}

#Preview("Immersive") {
    ImmersiveSectionView()
        .padding()
}
