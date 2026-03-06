/*
Navy Museum

Abstract:
A shared gesture modifier that rotates submarine entities with drag and momentum.
*/

import SwiftUI
import RealityKit

extension View {
    func submarineRotationGesture(
        configuration: Binding<SubmarineEntity.Configuration>,
        entity: SubmarineEntity?
    ) -> some View {
        modifier(
            SubmarineRotationGestureModifier(
                configuration: configuration,
                entity: entity
            )
        )
    }
}

private struct SubmarineRotationGestureModifier: ViewModifier {
    @Binding var configuration: SubmarineEntity.Configuration
    var entity: SubmarineEntity?

    @State private var gestureStartYaw: Float?
    @State private var gestureStartPitch: Float?
    @State private var inertiaTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(rotationGesture)
            .onDisappear {
                cancelInertia()
                gestureStartYaw = nil
                gestureStartPitch = nil
            }
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .targetedToAnyEntity()
            .onChanged { value in
                guard isInEntityHierarchy(value.entity) else { return }
                cancelInertia()

                let startYaw = gestureStartYaw ?? configuration.yawDegrees
                let startPitch = gestureStartPitch ?? configuration.pitchDegrees
                if gestureStartYaw == nil {
                    gestureStartYaw = startYaw
                    gestureStartPitch = startPitch
                }

                let location3D = value.convert(value.location3D, from: .local, to: .scene)
                let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                let delta = location3D - startLocation3D

                // Drag right/left adjusts yaw, drag up/down adjusts pitch.
                let yawDegreesPerMeter: Float = 220
                let pitchDegreesPerMeter: Float = 180
                let yaw = normalizeDegrees(startYaw + Float(delta.x) * yawDegreesPerMeter)
                let pitch = clamp(startPitch - Float(delta.y) * pitchDegreesPerMeter, min: -70, max: 70)

                withAnimation(.interactiveSpring) {
                    configuration.yawDegrees = yaw
                    configuration.pitchDegrees = pitch
                }
            }
            .onEnded { value in
                defer {
                    gestureStartYaw = nil
                    gestureStartPitch = nil
                }

                guard isInEntityHierarchy(value.entity) else { return }

                let startYaw = gestureStartYaw ?? configuration.yawDegrees
                let startPitch = gestureStartPitch ?? configuration.pitchDegrees

                let location3D = value.convert(value.location3D, from: .local, to: .scene)
                let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                let predictedEndLocation3D = value.convert(value.predictedEndLocation3D, from: .local, to: .scene)
                let delta = location3D - startLocation3D
                let predictedDelta = predictedEndLocation3D - location3D

                let yawDegreesPerMeter: Float = 220
                let pitchDegreesPerMeter: Float = 180
                let currentYaw = normalizeDegrees(startYaw + Float(delta.x) * yawDegreesPerMeter)
                let currentPitch = clamp(startPitch - Float(delta.y) * pitchDegreesPerMeter, min: -70, max: 70)

                configuration.yawDegrees = currentYaw
                configuration.pitchDegrees = currentPitch

                let extraYaw = clamp(Float(predictedDelta.x) * yawDegreesPerMeter, min: -80, max: 80)
                let extraPitch = clamp(-Float(predictedDelta.y) * pitchDegreesPerMeter, min: -55, max: 55)
                startInertia(yawDelta: extraYaw, pitchDelta: extraPitch)
            }
    }

    private func startInertia(yawDelta: Float, pitchDelta: Float) {
        cancelInertia()

        inertiaTask = Task { @MainActor in
            var remainingYaw = yawDelta
            var remainingPitch = pitchDelta
            let damping: Float = 0.82
            let minimumStep: Float = 0.02

            while !Task.isCancelled {
                let stepYaw = remainingYaw * (1 - damping)
                let stepPitch = remainingPitch * (1 - damping)

                if abs(stepYaw) < minimumStep, abs(stepPitch) < minimumStep {
                    break
                }

                configuration.yawDegrees = normalizeDegrees(configuration.yawDegrees + stepYaw)
                configuration.pitchDegrees = clamp(configuration.pitchDegrees + stepPitch, min: -70, max: 70)

                remainingYaw *= damping
                remainingPitch *= damping

                try? await Task.sleep(for: .milliseconds(16))
            }

            inertiaTask = nil
        }
    }

    private func cancelInertia() {
        inertiaTask?.cancel()
        inertiaTask = nil
    }

    private func isInEntityHierarchy(_ candidate: Entity) -> Bool {
        guard let entity else { return false }
        var current: Entity? = candidate
        while let node = current {
            if node === entity {
                return true
            }
            current = node.parent
        }
        return false
    }

    private func clamp(_ value: Float, min minValue: Float, max maxValue: Float) -> Float {
        Swift.max(minValue, Swift.min(maxValue, value))
    }

    private func normalizeDegrees(_ value: Float) -> Float {
        var normalized = value.truncatingRemainder(dividingBy: 360)
        if normalized > 180 {
            normalized -= 360
        } else if normalized < -180 {
            normalized += 360
        }
        return normalized
    }
}
