/*
Navy Museum

Abstract:
Explore view that shows the SS-212 submarine with hotspots.
*/

import SwiftUI
import RealityKit

struct SubmarineExploreView: View {
    @Environment(ViewModel.self) private var model

    @State private var exploreSubmarine: Submarine?
    @State private var selectedHotspot: Hotspot?
    @State private var selectedWaypoint: Waypoint?

    @State private var submarineEntity: SubmarineEntity?

    private let repository = SubmarineRepository.shared

    var body: some View {
        @Bindable var model = model

        ZStack(alignment: .bottom) {
            RealityView { content in
                await loadExploreContent(into: content)
            } update: { _ in
                applyDebugConfiguration()
            }
            .gesture(
                TapGesture()
                    .targetedToAnyEntity()
                    .onEnded { value in
                        if let component: HotspotComponent = value.entity.components[HotspotComponent.self],
                           let exploreSubmarine {
                            selectedHotspot = exploreSubmarine.hotspot(id: component.hotspotId)
                            selectedWaypoint = nil
                        } else if let component: WaypointComponent = value.entity.components[WaypointComponent.self],
                                  let exploreSubmarine {
                            selectedWaypoint = exploreSubmarine.waypoint(id: component.waypointId)
                            selectedHotspot = nil
                        }
                    }
            )
            .submarineRotationGesture(configuration: $model.exploreSubmarine, entity: submarineEntity)

            VStack(spacing: 12) {
                if let selectedHotspot {
                    HotspotInfoPanel(hotspot: selectedHotspot) {
                        self.selectedHotspot = nil
                    }
                }
                if let selectedWaypoint {
                    WaypointInfoPanel(waypoint: selectedWaypoint) {
                        self.selectedWaypoint = nil
                    }
                }

                HStack(spacing: 12) {
                    Toggle("Hotspots", isOn: $model.exploreSubmarine.showsHotspots)
                    Toggle("Waypoints", isOn: $model.exploreSubmarine.showsWaypoints)
                    Button("Reset") {
                        model.resetExploreDebugSettings()
                        model.exploreSelectedHotspotID = nil
                        model.exploreSelectedWaypointID = nil
                    }
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .padding(12)
                .glassBackgroundEffect(in: .rect(cornerRadius: 20))
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            Task { await loadExploreSubmarine() }
        }
        .onChange(of: exploreSubmarine?.id) { _, _ in
            selectedHotspot = nil
            selectedWaypoint = nil
        }
    }

    private func loadExploreSubmarine() async {
        exploreSubmarine = await repository.fetchAllSubmarines().first { $0.detailStatus == .full }
    }

    private func loadExploreContent(into content: RealityViewContent) async {
        if exploreSubmarine == nil {
            await loadExploreSubmarine()
        }
        guard let exploreSubmarine else { return }

        let entity = await SubmarineEntity(
            submarine: exploreSubmarine,
            configuration: model.exploreSubmarine
        )
        entity.modelEntity.generateCollisionShapes(recursive: true)
        entity.modelEntity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
        entity.components.set(InputTargetComponent())

        content.add(entity)
        submarineEntity = entity

        applyDebugConfiguration()
    }

    private func applyDebugConfiguration() {
        submarineEntity?.update(configuration: model.exploreSubmarine)
    }
}

private struct HotspotInfoPanel: View {
    var hotspot: Hotspot
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(hotspot.title)
                    .font(.headline)
                Spacer()
                Button("Close", action: onClose)
                    .buttonStyle(.borderless)
            }
            Text(hotspot.detail)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: 420)
        .glassBackgroundEffect(in: .rect(cornerRadius: 18))
    }
}

private struct WaypointInfoPanel: View {
    var waypoint: Waypoint
    var onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(waypoint.title)
                    .font(.headline)
                Spacer()
                Button("Close", action: onClose)
                    .buttonStyle(.borderless)
            }
            Text(waypoint.detail)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: 420)
        .glassBackgroundEffect(in: .rect(cornerRadius: 18))
    }
}

#Preview {
    SubmarineExploreView()
        .environment(ViewModel())
}
