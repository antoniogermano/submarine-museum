/*
Navy Museum

Abstract:
Favorites module view with persisted submarine favorites.
*/

import SwiftUI

struct FavoritesSectionView: View {
    @Environment(ViewModel.self) private var model

    @State private var viewState: ViewState = .loading
    @State private var allSubmarines: [Submarine] = []
    @State private var favoriteSubmarines: [Submarine] = []

    private let repository = SubmarineRepository.shared
    private let favoritesStore = FavoritesStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch viewState {
            case .loading:
                stateView(title: "Loading favorites...", systemImage: "hourglass")
            case .error(let message):
                stateView(title: "Unable to load favorites", subtitle: message, systemImage: "exclamationmark.triangle")
            case .empty:
                emptyStateView
            case .loaded:
                favoritesList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task {
            await loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
            refreshFavorites()
        }
    }

    private var favoritesList: some View {
        ScrollView(.vertical) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(favoriteSubmarines) { submarine in
                    SubmarineCard(submarine: submarine)
                        .contextMenu {
                            Button("Unfavorite", systemImage: "heart.slash") {
                                favoritesStore.setFavorite(id: submarine.id, isFavorite: false)
                                refreshFavorites()
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No favorites yet")
                .font(.title2)

            Text("Save submarines from the catalog to see them here.")
                .foregroundStyle(.secondary)

            Button("Browse Catalog") {
                model.navigationPath.append(Module.catalog)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stateView(title: String, subtitle: String? = nil, systemImage: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.title2)

            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }

    private func loadData() async {
        let submarines = await repository.fetchAllSubmarines()
        let repositoryError = await repository.lastError

        allSubmarines = submarines

        if let repositoryError {
            viewState = .error(repositoryError)
            return
        }

        refreshFavorites()
    }

    private func refreshFavorites() {
        let favoriteIDs = model.previewFavoriteIDs ?? favoritesStore.allFavorites()
        favoriteSubmarines = FavoritesSubmarineMapper.map(
            submarines: allSubmarines,
            favoriteIDs: favoriteIDs
        )
        viewState = favoriteSubmarines.isEmpty ? .empty : .loaded
    }
}

enum FavoritesSubmarineMapper {
    static func map(submarines: [Submarine], favoriteIDs: Set<String>) -> [Submarine] {
        submarines
            .filter { favoriteIDs.contains($0.id) }
            .sorted {
                $0.displayTitle.localizedCaseInsensitiveCompare($1.displayTitle) == .orderedAscending
            }
    }
}

private enum ViewState: Equatable {
    case loading
    case loaded
    case empty
    case error(String)
}

#Preview("0 Favorites") {
    NavigationStack {
        ModuleDetail(module: .favorites)
            .environment(ViewModel.preview(favoriteIDs: []))
    }
}

#Preview("5 Favorites") {
    NavigationStack {
        ModuleDetail(module: .favorites)
            .environment(ViewModel.preview(favoriteIDs: [
                "uss-gato-ss-212",
                "uss-nautilus-ssn-571",
                "hms-alliance",
                "u-995",
                "ijn-i-400"
            ]))
    }
}

