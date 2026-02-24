/*
Navy Museum

Abstract:
Debug settings for the gallery image spatial scene window.
*/

import SwiftUI

struct GalleryImageSettings: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model

        VStack {
            Text("Gallery image debug settings", comment: "The title of the settings presented to the viewer.")
                .font(.title)

            Form {
                Section(String(localized: "Spatial Scene", comment: "Section title for spatial scene settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 16) {
                        SliderGridRow(title: "Scale multiplier", value: $model.gallerySpatialDebug.scaleMultiplier, range: 0.25 ... 3, fractionLength: 3)

                        Divider()
                            .gridCellUnsizedAxes(.horizontal)

                        SliderGridRow(title: "X", value: $model.gallerySpatialDebug.position.x, range: -1 ... 1, fractionLength: 3)
                        SliderGridRow(title: "Y", value: $model.gallerySpatialDebug.position.y, range: -1 ... 1, fractionLength: 3)
                        SliderGridRow(title: "Z", value: $model.gallerySpatialDebug.position.z, range: -1 ... 0.2, fractionLength: 3)
                    }
                }

                Section(String(localized: "Window Frame", comment: "Section title for gallery frame settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 16) {
                        SliderGridRow(title: "Width", value: $model.gallerySpatialDebug.frameWidth, range: 400 ... 1400, fractionLength: 0)
                        SliderGridRow(title: "Height", value: $model.gallerySpatialDebug.frameHeight, range: 250 ... 900, fractionLength: 0)
                        SliderGridRow(title: "Corner radius", value: $model.gallerySpatialDebug.frameCornerRadius, range: 0 ... 60, fractionLength: 1)
                    }
                }

                Section(String(localized: "Ornament", comment: "Section title for settings button ornament configuration.")) {
                    Grid(alignment: .leading, verticalSpacing: 16) {
                        Toggle("Show settings ornament", isOn: $model.gallerySpatialDebug.showSettingsOrnament)

                        GridRow {
                            Text("Attachment")
                            Picker("Attachment", selection: $model.gallerySpatialDebug.settingsOrnamentAnchor) {
                                ForEach(GallerySettingsOrnamentAnchor.allCases, id: \.self) { anchor in
                                    Text(anchor.title)
                                        .tag(anchor)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }

                Section(String(localized: "System", comment: "Section title of system level settings.")) {
                    Grid(alignment: .leading, verticalSpacing: 20) {
                        Button("Reset") {
                            model.resetGallerySpatialDebugSettings()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    GalleryImageSettings()
        .frame(width: 500)
        .environment(ViewModel())
}
