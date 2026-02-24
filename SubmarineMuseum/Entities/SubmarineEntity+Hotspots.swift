/*
Navy Museum

Abstract:
Hotspot marker helpers for submarine entities.
*/

import RealityKit

@MainActor
enum HotspotAttachment {
    static func attachHotspots(_ hotspots: [Hotspot], to root: Entity) -> [String: Entity] {
        var mapping: [String: Entity] = [:]
        for hotspot in hotspots {
            let marker = makeMarkerEntity()
            marker.position = hotspot.position
            marker.components.set(HotspotComponent(hotspotId: hotspot.id))
            root.addChild(marker)
            mapping[hotspot.id] = marker
        }
        return mapping
    }

    private static func makeMarkerEntity() -> Entity {
        let markerRadius: Float = 2
        let mesh = MeshResource.generateSphere(radius: markerRadius)
        let material = SimpleMaterial(color: .orange, roughness: 0.2, isMetallic: false)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.components.set(CollisionComponent(shapes: [.generateSphere(radius: markerRadius)]))
        model.components.set(InputTargetComponent())
        model.components.set(HoverEffectComponent())
        return model
    }
}
