/*
Navy Museum

Abstract:
Catalog view for submarine exhibits.
*/

import SwiftUI

struct CatalogView: View {
    private enum ViewState: Equatable {
        case loading
        case loaded
        case empty
        case error(String)
    }

    @State private var viewState: ViewState = .loading
    @State private var submarines: [Submarine] = []
    @State private var filteredSubmarines: [Submarine] = []
    @State private var searchQuery: String = ""
    @State private var selectedEra: String = "All eras"
    @State private var selectedNation: String = "All nations"
    @State private var filterTask: Task<Void, Never>?

    private let repository = SubmarineRepository.shared

    private var eras: [String] {
        let values = Set(submarines.map { $0.era })
        return ["All eras"] + values.sorted()
    }

    private var nations: [String] {
        let values = Set(submarines.map { $0.nation })
        return ["All nations"] + values.sorted()
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 24) {
                heroSection
                    .padding(.horizontal, 50)
                contentSection
            }
            .contentMargins(.horizontal, 50)
            .searchable(text: $searchQuery, placement: .toolbar, prompt: "Search submarines")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Picker("Era", selection: $selectedEra) {
                        ForEach(eras, id: \.self) { era in
                            Text(era)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Nation", selection: $selectedNation) {
                        ForEach(nations, id: \.self) { nation in
                            Text(nation)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .task {
                await loadData()
            }
            .onChange(of: selectedEra) { _, _ in scheduleFilterUpdate() }
            .onChange(of: selectedNation) { _, _ in scheduleFilterUpdate() }
            .onChange(of: searchQuery) { _, _ in scheduleFilterUpdate() }
        }
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.7), Color.black.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 260)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "ferry.fill")
                        .font(.system(size: 90))
                        .foregroundStyle(.white.opacity(0.2))
                        .padding(24)
                        .accessibilityHidden(true)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text("Submarine Catalog")
                    .font(.extraLargeTitle2)
                Text("Discover historic vessels and the stories behind them.")
                    .foregroundStyle(.secondary)
            }
            .padding(24)
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch viewState {
            case .loading:
                stateView(title: "Loading catalog...", systemImage: "hourglass")
            case .error(let message):
                stateView(title: "Unable to load catalog", subtitle: message, systemImage: "exclamationmark.triangle")
            case .empty:
                stateView(title: "No submarines found", subtitle: "Try adjusting your filters.", systemImage: "magnifyingglass")
            case .loaded:
                if filteredSubmarines.isEmpty {
                    stateView(title: "No submarines found", subtitle: "Try adjusting your filters.", systemImage: "magnifyingglass")
                } else {
                    rowsView
                }
            }
        }
        .animation(.default, value: viewState)
    }

    private var rowsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            let featured = Array(filteredSubmarines.prefix(4))
            let explore = Array(filteredSubmarines.dropFirst(4).prefix(4))
            
            submarineRow(title: "Featured", submarines: featured)
            if !explore.isEmpty {
                submarineRow(title: "More to Explore", submarines: explore)
                    .contentMargins(.bottom, 50)
            }
        }
    }

    private func submarineRow(title: String, submarines: [Submarine]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.horizontal, 50)

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(submarines) { submarine in
                        SubmarineCard(submarine: submarine)
                    }
                }
                .padding(.bottom, 4)
            }
            .scrollIndicators(.hidden)
        }
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

    private func scheduleFilterUpdate() {
        filterTask?.cancel()
        filterTask = Task { await updateFilteredSubmarines() }
    }

    private func loadData() async {
        viewState = .loading
        submarines = await repository.fetchAllSubmarines()
        if let errorMessage = await repository.lastError {
            viewState = .error(errorMessage)
            return
        }
        await updateFilteredSubmarines()
        viewState = submarines.isEmpty ? .empty : .loaded
    }

    private func updateFilteredSubmarines() async {
        let eraFilter = selectedEra == "All eras" ? nil : selectedEra
        let nationFilter = selectedNation == "All nations" ? nil : selectedNation
        let filtered = await repository.filter(era: eraFilter, nation: nationFilter)
        
        // Check for cancellation before doing search work
        if Task.isCancelled { return }
        
        let result: [Submarine]
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            result = filtered
        } else {
            let searched = await repository.search(query: searchQuery)
            if Task.isCancelled { return }
            let searchIDs = Set(searched.map { $0.id })
            result = filtered.filter { searchIDs.contains($0.id) }
        }
        
        // Check for cancellation before updating state
        if Task.isCancelled { return }
        
        filteredSubmarines = result
        if case .loading = viewState { return }
        if case .error = viewState { return }
        viewState = filteredSubmarines.isEmpty ? .empty : .loaded
    }
}

#Preview {
    NavigationStack {
        ModuleDetail(module: .catalog)
            .environment(ViewModel())
    }
}
