/*
Navy Museum

Abstract:
Exhibit detail view for submarines.
*/
import SwiftUI
import RealityKit

struct ExhibitDetailView: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var submarine: Submarine
    
    @State private var isFavorite: Bool = false
    @State private var galleryScrollID: GalleryItem.ID?
    
    private let favorites = FavoritesStore.shared
    
    var body: some View {
        Group {
            if let profileImageName = submarine.profileImageName {
                HStack(alignment: .top, spacing: 32) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            headerSection
                            overviewSection
                            timelineSection
                            gallerySection
                            referencesSection
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack {
                        if submarine.detailStatus == .full {
                            HStack {
                                Spacer()
                                Toggle(
                                    model.isShowingExplore ? "Hide in Explore" : "Show in Explore",
                                    isOn: Binding(
                                        get: { model.isShowingExplore },
                                        set: { isShowing in
                                            model.isShowingExplore = isShowing
                                            if isShowing {
                                                openWindow(id: SceneID.exploreVolume)
                                            } else {
                                                dismissWindow(id: SceneID.exploreVolume)
                                            }
                                        }
                                    )
                                )
                                .toggleStyle(.button)
                            }
                            
                            SubmarineModelSidebar(submarine: submarine)
                        } else {
                            Image(profileImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 544, height: 200)
                                .offset(z: 10)
                        }
                        
                        specificationsSection
                    }
                }
                .padding(40)
                .settingsButton(module: .explore)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerSection
                        overviewSection
                        specificationsSection
                        timelineSection
                        gallerySection
                        referencesSection
                    }
                    .padding(40)
                }
            }
        }
        .navigationTitle("Exhibit Detail")
        .onAppear {
            isFavorite = favorites.isFavorite(id: submarine.id)
        }
        .onChange(of: isFavorite) { _, newValue in
            favorites.setFavorite(id: submarine.id, isFavorite: newValue)
        }
    }
    
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(submarine.displayTitle)
                    .font(.largeTitle)
                    .bold()
                
                Text("\(submarine.era) • \(submarine.nation)")
                    .foregroundStyle(.secondary)
                
                Text(submarine.summary)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("Favorite", isOn: $isFavorite)
                .toggleStyle(.button)
        }
    }
    
    private var overviewSection: some View {
        sectionContainer(title: "Overview") {
            Text(submarine.summary)
                .foregroundStyle(.secondary)
        }
    }
    
    private var specificationsSection: some View {
        sectionContainer(title: "Specifications") {
            VStack(spacing: 10) {
                SpecificationRow(title: "Class", value: submarine.submarineClass?.name ?? "Unknown")
                SpecificationRow(title: "Role", value: submarine.submarineClass?.role ?? "—")
                SpecificationRow(title: "Commissioned", value: String(submarine.commissionYear))
                SpecificationRow(title: "Decommissioned", value: submarine.decommissionYear.map(String.init) ?? "—")
                SpecificationRow(title: "Length", value: String(format: "%.1f m", submarine.lengthMeters))
                SpecificationRow(title: "Displacement", value: "\(submarine.displacementTons) tons")
                SpecificationRow(title: "Status", value: submarine.status)
            }
        }
    }
    
    private var timelineSection: some View {
        sectionContainer(title: "Timeline & History") {
            let sortedSections = submarine.exhibitSections.sorted { $0.order < $1.order }
            if sortedSections.isEmpty {
                Text("No history entries yet.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sortedSections) { section in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(section.title)
                                .font(.headline)
                            Text(section.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
    
    private var gallerySection: some View {
        sectionContainer(title: "Gallery") {
            if submarine.galleryItems.isEmpty {
                Text("No gallery items available.")
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 16) {
                        ForEach(submarine.galleryItems) { item in
                            Button {
                                openWindow(id: SceneID.galleryImageWindow, value: item)
                            } label: {
                                GalleryCard(item: item)
                            }
                            .buttonStyle(.borderless)
                            .buttonSizing(.fitted)
                            .buttonBorderShape(.roundedRectangle(radius: 20))
                            .accessibilityLabel("Open \(item.title)")
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.vertical, 4)
                }
                .scrollPosition(id: $galleryScrollID)
                .scrollIndicators(.hidden)
            }
        }
    }
    
    private var referencesSection: some View {
        sectionContainer(title: "References") {
            if submarine.referenceLinks.isEmpty {
                Text("No references available.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(submarine.referenceLinks) { link in
                        if let url = URL(string: link.url) {
                            Button(link.title) {
                                openURL(url)
                            }
                        } else {
                            Text(link.title)
                        }
                    }
                }
            }
        }
    }
    
    private func sectionContainer<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct SubmarineModelSidebar: View {
    @Environment(ViewModel.self) private var model

    var submarine: Submarine

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let usdzName = submarine.model3D?.usdzName {
                CachedSubmarineSidebarModelView(
                    usdzName: usdzName,
                    configuration: model.previewSubmarine
                )
                .frame(width: 544, height: 200)
                .frame(depth: 100)
            } else {
                Text("3D model unavailable.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
    }
}

private struct CachedSubmarineSidebarModelView: View {
    var usdzName: String
    var configuration: SubmarineEntity.Configuration

    @State private var rootEntity: Entity = Entity()
    @State private var modelEntity: Entity?
    @State private var isLoading: Bool = false

    var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                content.add(rootEntity)
                await loadModelIfNeeded()
                updateModelTransform(content: content, geometry: geometry)
            } update: { content in
                updateModelTransform(content: content, geometry: geometry)
            }
            .overlay {
                if modelEntity == nil || isLoading {
                    ProgressView()
                }
            }
        }
    }

    @MainActor
    private func loadModelIfNeeded() async {
        guard modelEntity == nil, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        guard let entity = await SubmarineModelCache.shared.entity(named: usdzName) else {
            return
        }

        for child in rootEntity.children {
            child.removeFromParent()
        }
        rootEntity.addChild(entity)
        modelEntity = entity
    }

    private func updateModelTransform(content: RealityViewContent, geometry: GeometryProxy3D) {
        guard let modelEntity else { return }

        let boundsInScene = content.convert(geometry.frame(in: .local), from: .local, to: .scene)
        guard boundsInScene.extents.x > 0, boundsInScene.extents.y > 0 else {
            return
        }

        let pitch = configuration.pitchDegrees * .pi / 180
        let yaw = configuration.yawDegrees * .pi / 180
        let roll = configuration.rollDegrees * .pi / 180
        let orientation = simd_quatf(
            Rotation3D(
                eulerAngles: .init(angles: [pitch, yaw, roll], order: .xyz)
            )
        )

        modelEntity.scale = .one
        modelEntity.position = .zero
        modelEntity.orientation = orientation

        let modelBounds = modelEntity.visualBounds(relativeTo: rootEntity)
        guard modelBounds.extents.x > 0, modelBounds.extents.y > 0 else {
            return
        }

        let xScale = boundsInScene.extents.x / modelBounds.extents.x
        let yScale = boundsInScene.extents.y / modelBounds.extents.y
        let fitScale = min(xScale, yScale)
        guard fitScale.isFinite, fitScale > 0 else {
            return
        }

        modelEntity.scale = SIMD3<Float>(repeating: fitScale)

        let scaledCenter = modelBounds.center * fitScale
        let depthOffset = modelBounds.extents.z * fitScale * 0.5
        modelEntity.position = SIMD3(
            -scaledCenter.x,
            -scaledCenter.y,
            -scaledCenter.z - depthOffset
        )
    }
}

private struct SpecificationRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct GalleryCard: View {
    var item: GalleryItem
    
    private let cardWidth: CGFloat = 260
    private let imageWidth: CGFloat = 260
    private let imageHeight: CGFloat = 150
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GalleryImage(name: item.imageName)
                .frame(width: imageWidth, height: imageHeight, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Text(item.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(item.caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .frame(width: cardWidth, alignment: .leading)
    }
}

private struct GalleryImage: View {
    var name: String
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
    }
}

#Preview("Fully implemented submarine") {
    NavigationStack {
        ExhibitDetailView(submarine: Submarine(
            id: "preview",
            name: "USS Example",
            submarineClass: SubmarineClass(id: "example", name: "Example-class", role: "Research", notes: nil),
            era: "Cold War",
            nation: "United States",
            commissionYear: 1960,
            decommissionYear: nil,
            lengthMeters: 90,
            displacementTons: 2000,
            status: "Museum ship",
            summary: "A sample exhibit detail entry.",
            profileImageName: "USS-212",
            detailStatus: .full,
            model3D: SubmarineModel3D(usdzName: "USS_Gato_SS-212_Submarine_Displayed_on_Concrete_Blocks_SC_max_vray", displayName: "USS Gato SS-212"),
            hotspots: [
                Hotspot(id: "h", title: "Bow", detail: "Forward section", position: SIMD3<Float>(0, 0, 0))
            ],
            exhibitSections: [
                ExhibitSection(id: "a", title: "Commissioned", body: "Entered service in 1960.", order: 1),
                ExhibitSection(id: "b", title: "Decommissioned", body: "Retired in 1995.", order: 2),
                ExhibitSection(id: "c", title: "Whatever", body: "Something happened.", order: 3)
            ],
            galleryItems: [
                GalleryItem(id: "g", title: "Bridge", caption: "Control station and periscope", imageName: "19-N-49790_-_The_Gato_(SS-212)"),
                GalleryItem(id: "h", title: "Bridge", caption: "Control station and periscope", imageName: "USS_Gato;0821235"),
                GalleryItem(id: "i", title: "Bridge", caption: "Control station and periscope", imageName: "USS_Gato0821201")
            ],
            referenceLinks: [
                ReferenceLink(id: "r", title: "Museum Site", url: "https://example.com")
            ],
            locations: [
                Location(id: "a", name: "Museum", city: "City", region: "State", country: "Country", kind: .museum, latitude: 0, longitude: 0, notes: nil),
                Location(id: "b", name: "Historic Site", city: "City", region: "State", country: "Country", kind: .historicalSite, latitude: 0, longitude: 0, notes: nil)
            ]
        ))
        .environment(ViewModel())
    }
}

#Preview("Stub submarine") {
    NavigationStack {
        ExhibitDetailView(submarine: Submarine(
            id: "preview",
            name: "USS Example",
            submarineClass: SubmarineClass(id: "example", name: "Example-class", role: "Research", notes: nil),
            era: "Cold War",
            nation: "United States",
            commissionYear: 1960,
            decommissionYear: nil,
            lengthMeters: 90,
            displacementTons: 2000,
            status: "Museum ship",
            summary: "A sample exhibit detail entry.",
            profileImageName: "SubmarineProfiles/SS-212",
            detailStatus: .stub,
            model3D: SubmarineModel3D(usdzName: "USS_Gato_SS-212_Submarine_Displayed_on_Concrete_Blocks_SC_max_vray", displayName: "USS Gato SS-212"),
            hotspots: [
                Hotspot(id: "h", title: "Bow", detail: "Forward section", position: SIMD3<Float>(0, 0, 0))
            ],
            exhibitSections: [
                ExhibitSection(id: "a", title: "Commissioned", body: "Entered service in 1960.", order: 1),
                ExhibitSection(id: "b", title: "Decommissioned", body: "Retired in 1995.", order: 2),
                ExhibitSection(id: "c", title: "Whatever", body: "Something happened.", order: 3)
            ],
            galleryItems: [
                GalleryItem(id: "g", title: "Bridge", caption: "Control station and periscope", imageName: "19-N-49790_-_The_Gato_(SS-212)"),
                GalleryItem(id: "h", title: "Bridge", caption: "Control station and periscope", imageName: "USS_Gato;0821235"),
                GalleryItem(id: "i", title: "Bridge", caption: "Control station and periscope", imageName: "USS_Gato0821201")
            ],
            referenceLinks: [
                ReferenceLink(id: "r", title: "Museum Site", url: "https://example.com")
            ],
            locations: [
                Location(id: "a", name: "Museum", city: "City", region: "State", country: "Country", kind: .museum, latitude: 0, longitude: 0, notes: nil),
                Location(id: "b", name: "Historic Site", city: "City", region: "State", country: "Country", kind: .historicalSite, latitude: 0, longitude: 0, notes: nil)
            ]
        ))
        .environment(ViewModel())
    }
}
