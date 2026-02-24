/*
Navy Museum

Abstract:
Debug settings for the exhibit preview model.
*/

import SwiftUI

/// Controls for debug settings specific to the exhibit preview model.
struct ExhibitPreviewSettings: View {
    @Binding var configuration: SubmarineEntity.Configuration

    var body: some View {
        Section(String(localized: "Exhibit Preview", comment: "Debug settings for the exhibit preview model.")) {
            Grid(alignment: .leading, verticalSpacing: 16) {
                SliderGridRow(title: "Scale", value: $configuration.scale, range: 0.00 ... 0.02, fractionLength: 8)
                SliderGridRow(title: "Yaw", value: $configuration.yawDegrees, range: -180 ... 180, fractionLength: 1)
                SliderGridRow(title: "Pitch", value: $configuration.pitchDegrees, range: -180 ... 180, fractionLength: 1)
                SliderGridRow(title: "Roll", value: $configuration.rollDegrees, range: -180 ... 180, fractionLength: 1)
                Divider()
                SliderGridRow(title: "X", value: $configuration.position.x, range: -2 ... 2, fractionLength: 2)
                SliderGridRow(title: "Y", value: $configuration.position.y, range: -2 ... 2, fractionLength: 2)
                SliderGridRow(title: "Z", value: $configuration.position.z, range: -2 ... 2, fractionLength: 2)
            }
        }
    }
}
