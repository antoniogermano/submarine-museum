/*
Navy Museum

Abstract:
Debug settings for the explore model.
*/

import SwiftUI

/// Controls for debug settings specific to the explore model.
struct ExploreModelSettings: View {
    @Binding var configuration: SubmarineEntity.Configuration

    var body: some View {
        Section(String(localized: "Explore Model", comment: "Debug settings for the explore model.")) {
            Grid(alignment: .leading, verticalSpacing: 16) {
                SliderGridRow(title: "Scale", value: $configuration.scale, range: 0 ... 0.1, fractionLength: 8)
                SliderGridRow(title: "Yaw", value: $configuration.yawDegrees, range: -180 ... 180, fractionLength: 1)
                SliderGridRow(title: "Pitch", value: $configuration.pitchDegrees, range: -180 ... 180, fractionLength: 1)
                SliderGridRow(title: "Roll", value: $configuration.rollDegrees, range: -180 ... 180, fractionLength: 1)
            }
        }
    }
}
