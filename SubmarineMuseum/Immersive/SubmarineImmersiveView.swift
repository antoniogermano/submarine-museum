/*
Navy Museum

Abstract:
An immersive view that presents the highlighted submarine.
*/

import SwiftUI
import RealityKit

struct SubmarineImmersiveView: View {
    @Environment(ViewModel.self) private var model

    @State private var submarine: Submarine?
    @State private var submarineEntity: SubmarineEntity?
    @State private var defaultRootTransform: Transform = .identity
    @State private var selectedWaypointID: String?
    @State private var isShowingWaypointPicker: Bool = false
    @State private var waypointTeleportTask: Task<Void, Never>?

    @State private var debugRootScale: Float = 1
    @State private var debugModelBounds: SIMD3<Float> = .zero

    private let repository = SubmarineRepository.shared
    private let teleportDuration: TimeInterval = 0.9

    var body: some View {
        @Bindable var model = model

        RealityView { content in
            await loadContent(into: content)
        } update: { _ in
            applyMarkerConfiguration()
        }
        .ornament(
            visibility: .visible,
            attachmentAnchor: .scene(.bottom)
        ) {
            Button {
                isShowingWaypointPicker = true
            } label: {
                Label("Waypoints", systemImage: "location.circle")
            }
            .popover(isPresented: $isShowingWaypointPicker) {
                waypointPickerPopover
                    .padding(.vertical)
                    .frame(width: 520, height: 420)
            }
        }
        .onDisappear {
            waypointTeleportTask?.cancel()
            model.isShowingSubmarineImmersive = false
        }
        .onChange(of: model.immersiveSubmarine.showsHotspots) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.immersiveSubmarine.showsWaypoints) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.immersiveSubmarine.hotspotOverrides) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.immersiveSubmarine.waypointOverrides) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.exploreSubmarine.showsHotspots) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.exploreSubmarine.showsWaypoints) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.exploreSubmarine.hotspotOverrides) { _, _ in
            applyMarkerConfiguration()
        }
        .onChange(of: model.exploreSubmarine.waypointOverrides) { _, _ in
            applyMarkerConfiguration()
            teleportToRequestedWaypoint()
        }
        .onChange(of: model.immersiveTeleportRequestToken) { _, _ in
            teleportToRequestedWaypoint()
        }
        .onChange(of: model.immersiveResetRequestToken) { _, _ in
            resetToDefaultPlacement()
        }
    }

    private func loadContent(into content: RealityViewContent) async {
        guard let submarine = await repository.fetchAllSubmarines().first(where: { $0.detailStatus == .full }) else {
            return
        }

        let entity = await SubmarineEntity(
            submarine: submarine,
            configuration: immersiveConfiguration
        )
        entity.modelEntity.generateCollisionShapes(recursive: true)
        entity.modelEntity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
        entity.components.set(InputTargetComponent())

        content.add(entity)
        self.submarine = submarine
        submarineEntity = entity
        defaultRootTransform = entity.transform
        selectedWaypointID = submarine.waypoints.first?.id
        if model.immersiveSelectedWaypointID == nil {
            model.immersiveSelectedWaypointID = submarine.waypoints.first?.id
        }
        refreshDebugReadout()
        applyMarkerConfiguration()
    }

    private func applyMarkerConfiguration() {
        submarineEntity?.updateMarkers(configuration: immersiveConfiguration)
    }

    private var waypointPickerPopover: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Immersive Waypoints")
                    .font(.title3)
                    .bold()
                Spacer()
                Button("Reset") {
                    resetToDefaultPlacement()
                }
                .buttonStyle(.borderedProminent)
                .disabled(submarineEntity == nil)
            }

            Toggle("Show Hotspots", isOn: Binding(
                get: { model.exploreSubmarine.showsHotspots },
                set: { model.exploreSubmarine.showsHotspots = $0 }
            ))
            Toggle("Show Waypoints", isOn: Binding(
                get: { model.exploreSubmarine.showsWaypoints },
                set: { model.exploreSubmarine.showsWaypoints = $0 }
            ))

            Divider()

            if let submarine {
                List(submarine.waypoints, id: \.id) { waypoint in
                    Button {
                        selectedWaypointID = waypoint.id
                        model.immersiveSelectedWaypointID = waypoint.id
                        teleportToWaypoint(waypoint)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(waypoint.title)
                                .font(.headline)
                            Text(waypoint.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ContentUnavailableView(
                    "No Waypoints",
                    systemImage: "location.slash",
                    description: Text("No full-detail submarine is currently loaded.")
                )
            }

            if showDebugSettings {
                Divider()
                Text(debugReadoutText)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    private func teleportToWaypoint(_ waypoint: Waypoint) {
        guard let submarineEntity else { return }

        waypointTeleportTask?.cancel()

        // Waypoint orientation is not present in current JSON, so infer a local yaw fallback.
        let waypointLocal = Transform(
            scale: .one,
            rotation: inferredWaypointLocalRotation(position: waypointPosition(for: waypoint)),
            translation: waypointPosition(for: waypoint)
        )

        // Target pose relative to the immersive scene origin, which starts at the user location.
        // This places the selected waypoint comfortably in front of the viewer.
        let targetPose = Transform(
            scale: .one,
            rotation: defaultRootTransform.rotation,
            translation: SIMD3<Float>(0, -0.1, -1.25)
        )

        let targetMatrix = targetPose.matrix * simd_inverse(waypointLocal.matrix)
        var destination = Transform(matrix: targetMatrix)
        destination.scale = SIMD3<Float>(repeating: 1)

        waypointTeleportTask = Task { @MainActor in
            await animateSubmarineRoot(
                entity: submarineEntity,
                to: destination,
                duration: teleportDuration
            )
            refreshDebugReadout()
        }
    }

    private func teleportToRequestedWaypoint() {
        guard
            let submarine,
            let selectedID = activeWaypointID(in: submarine),
            let waypoint = submarine.waypoints.first(where: { $0.id == selectedID })
        else {
            return
        }
        selectedWaypointID = selectedID
        model.immersiveSelectedWaypointID = selectedID
        teleportToWaypoint(waypoint)
    }

    private func activeWaypointID(in submarine: Submarine) -> String? {
        if let immersiveID = model.immersiveSelectedWaypointID,
           submarine.waypoints.contains(where: { $0.id == immersiveID }) {
            return immersiveID
        }
        if let exploreID = model.exploreSelectedWaypointID,
           submarine.waypoints.contains(where: { $0.id == exploreID }) {
            return exploreID
        }
        return submarine.waypoints.first?.id
    }

    private func resetToDefaultPlacement() {
        guard let submarineEntity else { return }
        waypointTeleportTask?.cancel()

        waypointTeleportTask = Task { @MainActor in
            await animateSubmarineRoot(
                entity: submarineEntity,
                to: defaultRootTransform,
                duration: teleportDuration
            )
            refreshDebugReadout()
        }
    }

    private func waypointPosition(for waypoint: Waypoint) -> SIMD3<Float> {
        if let override = model.exploreSubmarine.waypointOverrides[waypoint.id], override.count == 3 {
            return SIMD3(override[0], override[1], override[2])
        }
        return waypoint.position
    }

    // Waypoint orientation is absent in current schema, so infer yaw from the
    // waypoint's local direction relative to submarine forward.
    private func inferredWaypointLocalRotation(position: SIMD3<Float>) -> simd_quatf {
        let directionXZ = SIMD2<Float>(position.x, position.z)
        guard simd_length(directionXZ) > 0.0001 else {
            return simd_quatf(angle: 0, axis: [0, 1, 0])
        }
        let yaw = atan2(directionXZ.x, directionXZ.y)
        return simd_quatf(angle: yaw, axis: [0, 1, 0])
    }

    private var debugReadoutText: String {
        String(
            format: "Debug: root scale %.3f  •  bounds %.1f × %.1f × %.1f m",
            debugRootScale,
            debugModelBounds.x,
            debugModelBounds.y,
            debugModelBounds.z
        )
    }

    @MainActor
    private func animateSubmarineRoot(
        entity: SubmarineEntity,
        to destination: Transform,
        duration: TimeInterval
    ) async {
        let frameCount = max(Int(duration * 60), 1)
        let start = entity.transform

        for frame in 0 ... frameCount {
            if Task.isCancelled { return }
            let t = Float(frame) / Float(frameCount)
            let eased = t * t * (3 - 2 * t) // smoothstep easeInOut

            let interpolated = Transform(
                scale: simd_mix(start.scale, destination.scale, SIMD3<Float>(repeating: eased)),
                rotation: simd_slerp(start.rotation, destination.rotation, eased),
                translation: simd_mix(start.translation, destination.translation, SIMD3<Float>(repeating: eased))
            )
            entity.transform = interpolated

            if frame < frameCount {
                try? await Task.sleep(nanoseconds: 16_666_667)
            }
        }
    }

    @MainActor
    private func refreshDebugReadout() {
        guard let submarineEntity else { return }
        debugRootScale = submarineEntity.transform.scale.x
        let bounds = submarineEntity.modelEntity.visualBounds(relativeTo: submarineEntity)
        debugModelBounds = bounds.extents
    }

    private var immersiveConfiguration: SubmarineEntity.Configuration {
        var configuration = model.immersiveSubmarine
        configuration.showsHotspots = model.exploreSubmarine.showsHotspots
        configuration.hotspotOverrides = model.exploreSubmarine.hotspotOverrides
        configuration.showsWaypoints = model.exploreSubmarine.showsWaypoints
        configuration.waypointOverrides = model.exploreSubmarine.waypointOverrides
        configuration.scale = 1
        return configuration
    }
}
