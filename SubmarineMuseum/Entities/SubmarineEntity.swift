/*
Navy Museum

Abstract:
An entity that represents a submarine and its hotspot markers.
*/

import RealityKit
import SwiftUI

/// An entity that represents a submarine and its hotspot markers.
class SubmarineEntity: Entity {
    /// The loaded submarine model entity.
    private(set) var modelEntity: Entity = Entity()

    /// A container for hotspot marker entities.
    private(set) var markersRoot: Entity = Entity()

    /// Marker entities indexed by hotspot identifier.
    private(set) var markerByID: [String: Entity] = [:]

    /// Original hotspot positions keyed by identifier.
    private var baseHotspots: [String: Hotspot] = [:]

    /// A container for waypoint marker entities.
    private(set) var waypointsRoot: Entity = Entity()

    /// Marker entities indexed by waypoint identifier.
    private(set) var waypointByID: [String: Entity] = [:]

    /// Original waypoint positions keyed by identifier.
    private var baseWaypoints: [String: Waypoint] = [:]

    @MainActor required init() {
        super.init()
    }

    @MainActor
    init(
        submarine: Submarine,
        configuration: Configuration
    ) async {
        super.init()

        modelEntity = await Self.loadModelEntity(for: submarine)
        markersRoot = Entity()
        waypointsRoot = Entity()
        markerByID = HotspotAttachment.attachHotspots(submarine.hotspots, to: markersRoot)
        waypointByID = WaypointAttachment.attachWaypoints(submarine.waypoints, to: waypointsRoot)
        baseHotspots = Dictionary(uniqueKeysWithValues: submarine.hotspots.map { ($0.id, $0) })
        baseWaypoints = Dictionary(uniqueKeysWithValues: submarine.waypoints.map { ($0.id, $0) })

        addChild(modelEntity)
        addChild(markersRoot)
        addChild(waypointsRoot)

        update(configuration: configuration, animateUpdates: false)
    }

    /// Updates configurable transform and hotspot visibility/positions.
    func update(
        configuration: Configuration,
        animateUpdates: Bool = false
    ) {
        updateMarkers(configuration: configuration)

        let pitch = configuration.pitchDegrees * .pi / 180
        let yaw = configuration.yawDegrees * .pi / 180
        let roll = configuration.rollDegrees * .pi / 180
        let orientation = simd_quatf(
            Rotation3D(
                eulerAngles: .init(angles: [pitch, yaw, roll], order: .xyz)
            )
        )

        let transform = Transform(
            scale: SIMD3(repeating: configuration.scale),
            rotation: orientation,
            translation: configuration.position
        )

        if animateUpdates, let parent {
            move(to: transform, relativeTo: parent, duration: 0.25)
        } else {
            self.transform = transform
        }
    }

    /// Updates hotspot and waypoint visibility/positions without mutating root transform.
    func updateMarkers(configuration: Configuration) {
        markersRoot.isEnabled = configuration.showsHotspots
        waypointsRoot.isEnabled = configuration.showsWaypoints

        for (hotspotID, marker) in markerByID {
            marker.position = markerPosition(for: hotspotID, overrides: configuration.hotspotOverrides)
        }
        for (waypointID, marker) in waypointByID {
            marker.position = waypointPosition(for: waypointID, overrides: configuration.waypointOverrides)
        }
    }

    private static func loadModelEntity(for submarine: Submarine) async -> Entity {
        if let usdzName = submarine.model3D?.usdzName,
           let entity = await SubmarineModelCache.shared.entity(named: usdzName) {
            return entity
        }

        let mesh = MeshResource.generateCylinder(height: 0.6, radius: 0.08)
        let material = SimpleMaterial(color: .gray, roughness: 0.4, isMetallic: true)
        return ModelEntity(mesh: mesh, materials: [material])
    }

    private func markerPosition(for hotspotID: String, overrides: [String: [Float]]) -> SIMD3<Float> {
        if let override = overrides[hotspotID], override.count == 3 {
            return SIMD3(override[0], override[1], override[2])
        }

        guard let fallback = baseHotspots[hotspotID]?.position else {
            fatalError("Missing base hotspot position for id: \(hotspotID)")
        }
        return fallback
    }

    private func waypointPosition(for waypointID: String, overrides: [String: [Float]]) -> SIMD3<Float> {
        if let override = overrides[waypointID], override.count == 3 {
            return SIMD3(override[0], override[1], override[2])
        }

        guard let fallback = baseWaypoints[waypointID]?.position else {
            fatalError("Missing base waypoint position for id: \(waypointID)")
        }
        return fallback
    }
}
