/*
Navy Museum

Abstract:
The launching point for the app's modules.
*/

import SwiftUI

/// The launching point for the app's modules.
struct TableOfContents: View {
    @Environment(ViewModel.self) private var model

    var body: some View {
        @Bindable var model = model
        
        VStack {
            VStack {
                HStack {
                    VStack {
                        TitleText(title: model.finalTitle)
                            .padding(.horizontal, 70)
                            .overlay(alignment: .leading) {
                                TitleText(title: model.titleText)
                                    .padding(.leading, 70)
                            }
                            .yOffset(
                                y: $model.titleYOffset,
                                finalY: model.finalTitleYOffset,
                                isFinished: $model.isTitleFinished,
                                stepDurationMilliseconds: 2,
                                stepCount: 400
                            )
                        Text("Discover the stories beneath the waves.",
                             comment: "The app's subtitle, appearing immediately below the title in a smaller font, on the splash screen.")
                        .font(.title)
                        .opacity(model.isTitleFinished ? 1 : 0)
                    }
                    Spacer()
                }
            }
            .padding(.top, 100)
            
            Spacer()

            HStack(alignment: .top, spacing: 20) {
                ForEach(Module.allCases) {
                    ModuleCard(module: $0)
                }
            }
            .padding(.bottom, 40)
            .opacity(model.isTitleFinished ? 1 : 0)
        }
        .padding(.horizontal, 50)
        .background {
            Image("USS-Washington-2000x1286-220854631")
                .resizable()
                .scaledToFill()
                .opacity(model.isTitleFinished ? 1 : 0)
                .accessibility(hidden: true)
        }
        .animation(.default.speed(0.25), value: model.isTitleFinished)
    }
}

/// The text that displays the app's title.
private struct TitleText: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.extraLargeTitle)
    }
}

#Preview {
    NavigationStack {
        TableOfContents()
            .environment(ViewModel())
    }
}
