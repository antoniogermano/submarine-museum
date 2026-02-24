/*
Navy Museum

Abstract:
A modifier for applying Y-axis offset to a SwiftUI view.
*/

import SwiftUI

extension View {
    /// Animates a bound Y-axis offset toward a final value.
    func yOffset(
        y: Binding<CGFloat>,
        finalY: CGFloat,
        isFinished: Binding<Bool> = .constant(false),
        isAnimated: Bool = true,
        stepDurationMilliseconds: UInt64 = 16,
        stepCount: Int = 30
    ) -> some View {
        self.modifier(
            YOffsetModifier(
                yOffset: y,
                finalYOffset: finalY,
                isFinished: isFinished,
                isAnimated: isAnimated,
                stepDurationMilliseconds: stepDurationMilliseconds,
                stepCount: stepCount
            )
        )
    }

    /// Convenience overload for direct Y values.
    func yOffset(_ y: CGFloat) -> some View {
        self.offset(x: 0, y: y)
    }
}

private struct YOffsetModifier: ViewModifier {
    @Binding var yOffset: CGFloat
    var finalYOffset: CGFloat
    @Binding var isFinished: Bool
    var isAnimated: Bool
    var stepDurationMilliseconds: UInt64
    var stepCount: Int

    func body(content: Content) -> some View {
        content
            .offset(x: 0, y: yOffset)
            .task(id: AnimationToken(finalYOffset: finalYOffset, isAnimated: isAnimated, stepDurationMilliseconds: stepDurationMilliseconds, stepCount: stepCount)) {
                let start = yOffset
                let end = finalYOffset

                guard abs(end - start) > 0.0001 else {
                    yOffset = end
                    isFinished = true
                    return
                }

                isFinished = false

                guard isAnimated else {
                    yOffset = end
                    isFinished = true
                    return
                }

                let safeStepCount = max(stepCount, 1)

                for step in 1 ... safeStepCount {
                    if Task.isCancelled {
                        return
                    }

                    let progress = CGFloat(step) / CGFloat(safeStepCount)
                    // Smooth ease-out curve to avoid abrupt stopping.
                    let easedProgress = 1 - pow(1 - progress, 3)
                    yOffset = start + (end - start) * easedProgress
                    try? await Task.sleep(for: .milliseconds(stepDurationMilliseconds))
                }

                yOffset = end
                isFinished = true
            }
    }
}

private struct AnimationToken: Hashable {
    let finalYOffset: CGFloat
    let isAnimated: Bool
    let stepDurationMilliseconds: UInt64
    let stepCount: Int
}
