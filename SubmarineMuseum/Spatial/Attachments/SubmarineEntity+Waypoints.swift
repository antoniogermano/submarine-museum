/*
Navy Museum

Abstract:
Waypoint marker helpers for submarine entities.
*/

import RealityKit

@MainActor
enum WaypointAttachment {
    static func attachWaypoints(_ waypoints: [Waypoint], to root: Entity) -> [String: Entity] {
        var mapping: [String: Entity] = [:]
        for waypoint in waypoints {
            let marker = makeMarkerEntity()
            marker.position = waypoint.position
            marker.components.set(WaypointComponent(waypointId: waypoint.id))
            root.addChild(marker)
            mapping[waypoint.id] = marker
        }
        return mapping
    }

    private static func makeMarkerEntity() -> Entity {
        let markerRadius: Float = 1
        let mesh = MeshResource.generateSphere(radius: markerRadius)
        let material = SimpleMaterial(color: .blue, roughness: 0.2, isMetallic: false)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.components.set(CollisionComponent(shapes: [.generateSphere(radius: markerRadius)]))
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        return model
    }
}
