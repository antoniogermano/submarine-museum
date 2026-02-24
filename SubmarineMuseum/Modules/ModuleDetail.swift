/*
Navy Museum

Abstract:
A detail view that presents information about different module types.
*/

import SwiftUI

/// A detail view that presents information about different module types.
struct ModuleDetail: View {
    @Environment(ViewModel.self) private var model

    var module: Module

    var body: some View {
        @Bindable var model = model

        GeometryReader { proxy in
            let textWidth = min(max(proxy.size.width * 0.4, 300), 500)
            let imageWidth = min(max(proxy.size.width - textWidth, 300), 700)
            ZStack {
                if module == .catalog {
                    module.detailView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    HStack(spacing: 60) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(module.heading)
                                .font(.extraLargeTitle)
                                .padding(.bottom, 15)
                                .accessibilitySortPriority(4)

                            Text(module.overview)
                                .padding(.bottom, 24)
                                .accessibilitySortPriority(3)

                            switch module {
                            case .explore:
                                ExploreToggle()
                            case .catalog:
                                Text(Module.catalog.callToAction)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            case .favorites:
                                Text(Module.favorites.callToAction)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)
                            case .immersive:
                                SubmarineImmersiveToggle()
                            }
                        }
                        .frame(width: textWidth, alignment: .leading)

                        module.detailView
                            .frame(width: imageWidth, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding([.leading, .trailing], module == .catalog ? 0 : 70)
//        .padding(.bottom, 24)

        // A settings button in an ornament,
        // visible only when `showDebugSettings` is true.
        .settingsButton(module: module)
   }
}

extension Module {
    @ViewBuilder
    fileprivate var detailView: some View {
        switch self {
        case .explore: ExploreSectionView()
        case .catalog: CatalogView()
        case .favorites: FavoritesSectionView()
        case .immersive: ImmersiveSectionView()
        }
    }
}

#Preview("Explore") {
    NavigationStack {
        ModuleDetail(module: .explore)
            .environment(ViewModel())
    }
}

#Preview("Catalog") {
    NavigationStack {
        ModuleDetail(module: .catalog)
            .environment(ViewModel())
    }
}

#Preview("Favorites") {
    NavigationStack {
        ModuleDetail(module: .favorites)
            .environment(ViewModel())
    }
}

#Preview("Immersive") {
    NavigationStack {
        ModuleDetail(module: .immersive)
            .environment(ViewModel())
    }
}
