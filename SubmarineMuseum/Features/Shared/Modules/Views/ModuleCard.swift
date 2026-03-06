/*
Navy Museum

Abstract:
A card that displays a navigation destination.
*/

import SwiftUI

/// A card that displays a navigation destination.
struct ModuleCard: View {
    var module: Module

    var body: some View {
        NavigationLink(value: module) {
            VStack(alignment: .leading, spacing: 4) {
                Text(module.eyebrow)
                    .font(.callout)
                    .bold()
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 10) {
                    Text(module.heading)
                        .font(.largeTitle)
                    Text(module.abstract)
                }
            }
            .padding(.vertical, 30)
        }
        .buttonStyle(.borderless)
        .buttonBorderShape(.roundedRectangle(radius: 20))
        .offset(z: 10)
    }
}

#Preview {
    HStack {
        ModuleCard(module: .explore)
        ModuleCard(module: .catalog)
        ModuleCard(module: .favorites)
        ModuleCard(module: .immersive)
    }
    .padding()
    .glassBackgroundEffect()
}
