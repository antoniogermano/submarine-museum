/*
Navy Museum

Abstract:
Debug settings for explore waypoints.
*/

import SwiftUI

/// Controls for debug settings specific to explore waypoints.
struct ExploreWaypointSettings: View {
    @Binding var configuration: SubmarineEntity.Configuration
    @Binding var selectedWaypointID: String?

    @State private var exploreSubmarine: Submarine?
    @State private var waypointStep: Float = 0.05

    private let repository = SubmarineRepository.shared

    var body: some View {
        Section(String(localized: "Waypoints", comment: "Debug settings for submarine waypoints.")) {
            Grid(alignment: .leading, verticalSpacing: 16) {
                if let exploreSubmarine {
                    GridRow {
                        Text("Waypoint")
                        Picker("Waypoint", selection: waypointSelectionBinding) {
                            ForEach(exploreSubmarine.waypoints) { waypoint in
                                Text(waypoint.title)
                                    .tag(waypoint.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    GridRow {
                        Text("ID")
                        Text(selectedWaypoint?.id ?? "—")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                    }

                    GridRow {
                        Text("Title")
                        Text(selectedWaypoint?.title ?? "—")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                    }

                    Divider()
                        .gridCellUnsizedAxes(.horizontal)

                    SliderGridRow(title: "X", value: waypointAxisBinding(index: 0), range: -10 ... 10, fractionLength: 2)
                    SliderGridRow(title: "Y", value: waypointAxisBinding(index: 1), range: -10 ... 10, fractionLength: 2)
                    SliderGridRow(title: "Z", value: waypointAxisBinding(index: 2), range: -45 ... 45, fractionLength: 2)

                    GridRow {
                        Text("Step")
                        Picker("Step", selection: $waypointStep) {
                            Text("0.01").tag(Float(0.01))
                            Text("0.05").tag(Float(0.05))
                            Text("0.10").tag(Float(0.10))
                        }
                        .pickerStyle(.segmented)
                    }

                    GridRow {
                        Text("Nudge")
                        HStack(spacing: 8) {
                            Button("X-") { nudge(axis: 0, delta: -waypointStep) }
                            Button("X+") { nudge(axis: 0, delta: waypointStep) }
                            Button("Y-") { nudge(axis: 1, delta: -waypointStep) }
                            Button("Y+") { nudge(axis: 1, delta: waypointStep) }
                            Button("Z-") { nudge(axis: 2, delta: -waypointStep) }
                            Button("Z+") { nudge(axis: 2, delta: waypointStep) }
                        }
                    }

                    GridRow {
                        Button("Reset waypoint position") {
                            resetSelectedWaypoint()
                        }
                        Button("Copy selected waypoint JSON") {
                            copySelectedWaypointJSON()
                        }
                    }
                } else {
                    Text("No full-detail submarine found.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            Task { await loadExploreSubmarine() }
        }
    }

    private var waypointSelectionBinding: Binding<String> {
        Binding<String>(
            get: {
                if let selected = selectedWaypointID {
                    return selected
                }
                return exploreSubmarine?.waypoints.first?.id ?? ""
            },
            set: { newValue in
                selectedWaypointID = newValue
            }
        )
    }

    private var selectedWaypoint: Waypoint? {
        guard let exploreSubmarine else { return nil }
        let selectedID = waypointSelectionBinding.wrappedValue
        return exploreSubmarine.waypoints.first { $0.id == selectedID }
    }

    private func waypointAxisBinding(index: Int) -> Binding<Float> {
        Binding<Float>(
            get: {
                guard let selectedID = selectedWaypointID ?? exploreSubmarine?.waypoints.first?.id else { return 0 }
                if let override = configuration.waypointOverrides[selectedID], override.count == 3 {
                    return override[index]
                }
                guard let position = selectedWaypoint?.position else { return 0 }
                return axisValue(index: index, from: position)
            },
            set: { newValue in
                guard let selectedID = selectedWaypointID ?? exploreSubmarine?.waypoints.first?.id else { return }

                let basePosition: SIMD3<Float>
                if let override = configuration.waypointOverrides[selectedID], override.count == 3 {
                    basePosition = SIMD3(override[0], override[1], override[2])
                } else if let position = selectedWaypoint?.position {
                    basePosition = position
                } else {
                    return
                }

                var values = [basePosition.x, basePosition.y, basePosition.z]
                values[index] = newValue
                configuration.waypointOverrides[selectedID] = values
            }
        )
    }

    private func axisValue(index: Int, from position: SIMD3<Float>) -> Float {
        switch index {
        case 0: return position.x
        case 1: return position.y
        case 2: return position.z
        default: return 0
        }
    }

    private func nudge(axis: Int, delta: Float) {
        let binding = waypointAxisBinding(index: axis)
        binding.wrappedValue += delta
    }

    private func resetSelectedWaypoint() {
        guard let selectedID = selectedWaypointID ?? exploreSubmarine?.waypoints.first?.id else { return }
        configuration.waypointOverrides.removeValue(forKey: selectedID)
    }

    private func copySelectedWaypointJSON() {
        guard let selectedWaypoint else { return }
        let position: [Float] = [
            waypointAxisBinding(index: 0).wrappedValue,
            waypointAxisBinding(index: 1).wrappedValue,
            waypointAxisBinding(index: 2).wrappedValue
        ]
        let positionString = position.map { String(format: "%.4f", Double($0)) }.joined(separator: ", ")
        let snippet = """
        {
            \"id\": \"\(selectedWaypoint.id)\",
            \"title\": \"\(selectedWaypoint.title)\",
            \"detail\": \"\(selectedWaypoint.detail)\",
            \"position\": [\(positionString)]
        }
        """
        UIPasteboard.general.string = snippet
    }

    private func loadExploreSubmarine() async {
        exploreSubmarine = await repository.fetchAllSubmarines().first { $0.detailStatus == .full }
        if selectedWaypointID == nil {
            selectedWaypointID = exploreSubmarine?.waypoints.first?.id
        }
    }
}
