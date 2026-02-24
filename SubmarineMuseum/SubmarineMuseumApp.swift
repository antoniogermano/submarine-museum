/*
Navy Museum

Abstract:
The main entry point of the Submarine Museum experience.
*/

import SwiftUI

/// The main entry point of the Submarine Museum experience.
@main
struct SubmarineMuseumApp: App {
    // The view model.
    @State private var model = ViewModel()

    // The immersion style used by the submarine immersive module.
    @State private var submarineImmersionStyle: ImmersionStyle = .full

    var body: some Scene {
        // The main window that presents the app's modules.
        WindowGroup(String(localized: "Submarine Museum",
                           comment: "The name of the app."),
                    id: "modules") {
            Modules()
                .frame(minWidth: 1280, minHeight: 720)
                .environment(model)
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)

        // A volume that displays the explore model.
        WindowGroup(id: SceneID.exploreVolume) {
            ExploreVolume()
                .environment(model)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        // A window that displays a selected gallery image.
        WindowGroup(id: SceneID.galleryImageWindow, for: GalleryItem.self) { $item in
            if let item {
                let windowSize = GalleryWindowSizeConfiguration.forImage(named: item.imageName)
                GalleryImageWindowView(item: item)
                    .frame(
                        minWidth: windowSize.minWidth,
                        idealWidth: windowSize.idealWidth,
                        maxWidth: windowSize.maxWidth,
                        minHeight: windowSize.minHeight,
                        idealHeight: windowSize.idealHeight,
                        maxHeight: windowSize.maxHeight
                    )
                    .environment(model)
            } else {
                ContentUnavailableView(
                    "No Image Selected",
                    systemImage: "photo",
                    description: Text("Open a gallery image from an exhibit.")
                )
                .environment(model)
            }
        }
        .windowResizability(.contentSize)

        // An immersive space that presents the featured submarine in full scale.
        ImmersiveSpace(id: SceneID.submarineImmersive) {
            SubmarineImmersiveView()
                .environment(model)
        }
        .immersionStyle(selection: $submarineImmersionStyle, in: .full)

    }
    
    init() {
        // Register all the custom components and systems that the app uses.
        HotspotComponent.registerComponent()
        WaypointComponent.registerComponent()

        SubmarineModelCacheMemoryPressureObserver.shared.start()

        Task(priority: .utility) {
            let submarines = await SubmarineRepository.shared.fetchAllSubmarines()
            let usdzNames = submarines.compactMap(\.model3D?.usdzName)
            await SubmarineModelCache.shared.preload(usdzNames: usdzNames)
        }
    }
}
