/*
Navy Museum

Abstract:
Debug settings for explore hotspots.
*/

import SwiftUI

/// Controls for debug settings specific to explore hotspots.
struct ExploreHotspotSettings: View {
    @Binding var configuration: SubmarineEntity.Configuration
    @Binding var selectedHotspotID: String?

    @State private var exploreSubmarine: Submarine?
    @State private var hotspotStep: Float = 0.05

    private let repository = SubmarineRepository.shared

    var body: some View {
        Section(String(localized: "Hotspots", comment: "Debug settings for submarine hotspots.")) {
            Grid(alignment: .leading, verticalSpacing: 16) {
                if let exploreSubmarine {
                    GridRow {
                        Text("Hotspot")
                        Picker("Hotspot", selection: hotspotSelectionBinding) {
                            ForEach(exploreSubmarine.hotspots) { hotspot in
                                Text(hotspot.title)
                                    .tag(hotspot.id)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    GridRow {
                        Text("ID")
                        Text(selectedHotspot?.id ?? "—")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                    }

                    GridRow {
                        Text("Title")
                        Text(selectedHotspot?.title ?? "—")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                    }

                    Divider()
                        .gridCellUnsizedAxes(.horizontal)

                    SliderGridRow(title: "X", value: hotspotAxisBinding(index: 0), range: -10 ... 10, fractionLength: 2)
                    SliderGridRow(title: "Y", value: hotspotAxisBinding(index: 1), range: -10 ... 10, fractionLength: 2)
                    SliderGridRow(title: "Z", value: hotspotAxisBinding(index: 2), range: -45 ... 45, fractionLength: 2)

                    GridRow {
                        Text("Step")
                        Picker("Step", selection: $hotspotStep) {
                            Text("0.01").tag(Float(0.01))
                            Text("0.05").tag(Float(0.05))
                            Text("0.10").tag(Float(0.10))
                        }
                        .pickerStyle(.segmented)
                    }

                    GridRow {
                        Text("Nudge")
                        HStack(spacing: 8) {
                            Button("X-") { nudge(axis: 0, delta: -hotspotStep) }
                            Button("X+") { nudge(axis: 0, delta: hotspotStep) }
                            Button("Y-") { nudge(axis: 1, delta: -hotspotStep) }
                            Button("Y+") { nudge(axis: 1, delta: hotspotStep) }
                            Button("Z-") { nudge(axis: 2, delta: -hotspotStep) }
                            Button("Z+") { nudge(axis: 2, delta: hotspotStep) }
                        }
                    }

                    GridRow {
                        Button("Reset hotspot position") {
                            resetSelectedHotspot()
                        }
                        Button("Copy selected hotspot JSON") {
                            copySelectedHotspotJSON()
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

    private var hotspotSelectionBinding: Binding<String> {
        Binding<String>(
            get: {
                if let selected = selectedHotspotID {
                    return selected
                }
                return exploreSubmarine?.hotspots.first?.id ?? ""
            },
            set: { newValue in
                selectedHotspotID = newValue
            }
        )
    }

    private var selectedHotspot: Hotspot? {
        guard let exploreSubmarine else { return nil }
        let selectedID = hotspotSelectionBinding.wrappedValue
        return exploreSubmarine.hotspots.first { $0.id == selectedID }
    }

    private func hotspotAxisBinding(index: Int) -> Binding<Float> {
        Binding<Float>(
            get: {
                guard let selectedID = selectedHotspotID ?? exploreSubmarine?.hotspots.first?.id else { return 0 }
                if let override = configuration.hotspotOverrides[selectedID], override.count == 3 {
                    return override[index]
                }
                guard let position = selectedHotspot?.position else { return 0 }
                return axisValue(index: index, from: position)
            },
            set: { newValue in
                guard let selectedID = selectedHotspotID ?? exploreSubmarine?.hotspots.first?.id else { return }

                let basePosition: SIMD3<Float>
                if let override = configuration.hotspotOverrides[selectedID], override.count == 3 {
                    basePosition = SIMD3(override[0], override[1], override[2])
                } else if let position = selectedHotspot?.position {
                    basePosition = position
                } else {
                    return
                }

                var values = [basePosition.x, basePosition.y, basePosition.z]
                values[index] = newValue
                configuration.hotspotOverrides[selectedID] = values
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
        let binding = hotspotAxisBinding(index: axis)
        binding.wrappedValue += delta
    }

    private func resetSelectedHotspot() {
        guard let selectedID = selectedHotspotID ?? exploreSubmarine?.hotspots.first?.id else { return }
        configuration.hotspotOverrides.removeValue(forKey: selectedID)
    }

    private func copySelectedHotspotJSON() {
        guard let selectedHotspot else { return }
        let position: [Float] = [
            hotspotAxisBinding(index: 0).wrappedValue,
            hotspotAxisBinding(index: 1).wrappedValue,
            hotspotAxisBinding(index: 2).wrappedValue
        ]
        let positionString = position.map { String(format: "%.4f", Double($0)) }.joined(separator: ", ")
        let snippet = """
        {
            \"id\": \"\(selectedHotspot.id)\",
            \"title\": \"\(selectedHotspot.title)\",
            \"detail\": \"\(selectedHotspot.detail)\",
            \"position\": [\(positionString)]
        }
        """
        UIPasteboard.general.string = snippet
    }

    private func loadExploreSubmarine() async {
        exploreSubmarine = await repository.fetchAllSubmarines().first { $0.detailStatus == .full }
        if selectedHotspotID == nil {
            selectedHotspotID = exploreSubmarine?.hotspots.first?.id
        }
    }
}

