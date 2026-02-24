/*
Navy Museum

Abstract:
Dedicated window for viewing gallery images and converting them to spatial scenes.
*/

import SwiftUI
import RealityKit

struct GalleryImageWindowView: View {
    @Environment(ViewModel.self) private var model

    var item: GalleryItem

    @State private var isShowingSettings: Bool = false

    var body: some View {
        Group {
            GalleryImageWindowContent(item: item)
        }
        .ornament(
            visibility: settingsOrnamentVisibility,
            attachmentAnchor: settingsAttachmentAnchor
        ) {
            Button {
                isShowingSettings = true
            } label: {
                Label {
                    Text("Settings")
                } icon: {
                    Image(systemName: "gear")
                }
                .labelStyle(.iconOnly)
            }
            .popover(isPresented: $isShowingSettings) {
                GalleryImageSettings()
                    .padding(.vertical)
                    .frame(width: 600, height: 460)
            }
        }
    }

    private var settingsOrnamentVisibility: Visibility {
        (showDebugSettings && model.gallerySpatialDebug.showSettingsOrnament) ? .visible : .hidden
    }

    private var settingsAttachmentAnchor: OrnamentAttachmentAnchor {
        switch model.gallerySpatialDebug.settingsOrnamentAnchor {
        case .bottom:
            return .scene(.bottom)
        case .top:
            return .scene(.top)
        case .leading:
            return .scene(.leading)
        case .trailing:
            return .scene(.trailing)
        }
    }
}

private struct GalleryImageWindowContent: View {
    @Environment(ViewModel.self) private var model

    var item: GalleryItem

    @State private var isShowingSpatialScene: Bool = false
    @State private var imageComponent: ImagePresentationComponent?
    @State private var isGeneratingSpatialScene: Bool = false
    @State private var generationError: String?
    @State private var generationTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(spatialButtonTitle) {
                    handleSpatialButtonTap()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isGeneratingSpatialScene)

                if isGeneratingSpatialScene {
                    Button("Cancel") {
                        cancelSpatialGeneration()
                    }
                    .buttonStyle(.bordered)
                }

                Spacer()
            }

            mediaView

            if let generationError, !generationError.isEmpty {
                Text(generationError)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: model.gallerySpatialDebug.frameWidth, alignment: .leading)
            }

            Text(item.title)
                .font(.title2)
                .bold()

            Text(item.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .onChange(of: item.id) { _, _ in
            resetForNewItem()
        }
        .onDisappear {
            generationTask?.cancel()
        }
    }

    private var spatialButtonTitle: String {
        if isShowingSpatialScene {
            return "Show Original"
        }
        return imageComponent == nil ? "View as Spatial Scene" : "Show Spatial Scene"
    }

    private var mediaView: some View {
        ZStack {
            if isShowingSpatialScene, let imageComponent {
                SpatialSceneWindowRealityView(
                    component: imageComponent,
                    debugConfiguration: model.gallerySpatialDebug
                )
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
            }

            if isGeneratingSpatialScene {
                Color.black.opacity(0.25)
                ProgressView("Generating spatial scene...")
                    .padding(16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(
            maxWidth: model.gallerySpatialDebug.frameWidth,
            maxHeight: model.gallerySpatialDebug.frameHeight
        )
        .clipShape(RoundedRectangle(cornerRadius: model.gallerySpatialDebug.frameCornerRadius))
    }

    private func handleSpatialButtonTap() {
        if isShowingSpatialScene {
            isShowingSpatialScene = false
            return
        }

        if imageComponent != nil {
            isShowingSpatialScene = true
            return
        }

        startSpatialGeneration()
    }

    private func startSpatialGeneration() {
        generationTask?.cancel()
        isGeneratingSpatialScene = true
        generationError = nil

        generationTask = Task {
            do {
                let source = try SpatialSceneImageSource.resolve(named: item.imageName)
                let spatial3DImage: ImagePresentationComponent.Spatial3DImage

                switch source {
                case .url(let url):
                    spatial3DImage = try await ImagePresentationComponent.Spatial3DImage(contentsOf: url)
                case .imageSource(let imageSource):
                    spatial3DImage = try await ImagePresentationComponent.Spatial3DImage(imageSource: imageSource)
                }

                try Task.checkCancellation()
                try await spatial3DImage.generate()
                try Task.checkCancellation()

                var component = ImagePresentationComponent(spatial3DImage: spatial3DImage)
                component.desiredViewingMode = .spatial3D

                await MainActor.run {
                    imageComponent = component
                    isShowingSpatialScene = true
                    isGeneratingSpatialScene = false
                }
            } catch is CancellationError {
                await MainActor.run {
                    isGeneratingSpatialScene = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingSpatialScene = false
                    isShowingSpatialScene = false
                    generationError = error.localizedDescription
                }
            }
        }
    }

    private func cancelSpatialGeneration() {
        generationTask?.cancel()
    }

    private func resetForNewItem() {
        generationTask?.cancel()
        imageComponent = nil
        isShowingSpatialScene = false
        isGeneratingSpatialScene = false
        generationError = nil
    }
}

private struct SpatialSceneWindowRealityView: View {
    let component: ImagePresentationComponent
    let debugConfiguration: GallerySpatialDebugConfiguration

    @State private var contentEntity = Entity()

    var body: some View {
        GeometryReader3D { geometry in
            RealityView { content in
                contentEntity.components.set(component)
                content.add(contentEntity)
                updatePresentationTransform(content: content, geometry: geometry)
            } update: { content in
                updatePresentationTransform(content: content, geometry: geometry)
            }
        }
    }

    private func updatePresentationTransform(content: RealityViewContent, geometry: GeometryProxy3D) {
        let boundsInScene = content.convert(geometry.frame(in: .local), from: .local, to: .scene)

        guard let presentationScreenSize = contentEntity
            .observable
            .components[ImagePresentationComponent.self]?
            .presentationScreenSize,
            presentationScreenSize != .zero else {
            return
        }

        let xScale = boundsInScene.extents.x / presentationScreenSize.x
        let yScale = boundsInScene.extents.y / presentationScreenSize.y
        let baseScale = min(xScale, yScale)

        guard baseScale.isFinite, baseScale > 0 else {
            return
        }

        let adjustedScale = baseScale * debugConfiguration.scaleMultiplier
        contentEntity.scale = SIMD3<Float>(adjustedScale, adjustedScale, 1.0)
        contentEntity.setPosition(debugConfiguration.position, relativeTo: nil)
    }
}

#Preview("Gallery Portrait") {
    NavigationStack {
        GalleryImageWindowContent(
            item: GalleryItem(
                id: "preview-portrait",
                title: "Portrait Example",
                caption: "Portrait gallery image preview.",
                imageName: "USS_Gato;0821235"
            )
        )
        .environment(ViewModel())
    }
    .frame(width: 360, height: 600)
}

#Preview("Gallery Landscape") {
    NavigationStack {
        GalleryImageWindowContent(
            item: GalleryItem(
                id: "preview-landscape",
                title: "Landscape Example",
                caption: "Landscape gallery image preview.",
                imageName: "USS_Gato0821201"
            )
        )
        .environment(ViewModel())
    }
//    .frame(width: 1000, height: 700)
}
