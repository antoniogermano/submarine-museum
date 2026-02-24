/*
Navy Museum

Abstract:
Repository for loading submarine museum data.
*/

import Foundation

actor SubmarineRepository {
    static let shared = SubmarineRepository()
    private let bundle: Bundle
    private var cachedSubmarines: [Submarine]?
    private(set) var lastError: String?

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchAllSubmarines() async -> [Submarine] {
        await loadSubmarines()
    }

    func fetchSubmarine(id: String) async -> Submarine? {
        await loadSubmarines().first { $0.id == id }
    }

    func search(query: String) async -> [Submarine] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let all = await loadSubmarines()
        guard !trimmed.isEmpty else { return all }
        let needle = trimmed.lowercased()

        return all.filter { submarine in
            let className = submarine.submarineClass?.name ?? ""
            let haystack = [
                submarine.name,
                className,
                submarine.era,
                submarine.nation,
                submarine.summary
            ]
            .joined(separator: " ")
            .lowercased()

            return haystack.contains(needle)
        }
    }

    func filter(era: String?, nation: String?) async -> [Submarine] {
        let eraNeedle = era?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let nationNeedle = nation?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return await loadSubmarines().filter { submarine in
            let matchesEra = eraNeedle.map { submarine.era.lowercased().contains($0) } ?? true
            let matchesNation = nationNeedle.map { submarine.nation.lowercased().contains($0) } ?? true
            return matchesEra && matchesNation
        }
    }

    private func loadSubmarines() async -> [Submarine] {
        if let cachedSubmarines {
            return cachedSubmarines
        }

        lastError = nil

        guard let url = bundle.url(forResource: "Submarines", withExtension: "json") else {
            let message = "Submarines.json is missing from the app bundle."
            print("SubmarineRepository: \(message)")
            lastError = message
            cachedSubmarines = []
            return []
        }

        do {
            let data = try await Task.detached(priority: .userInitiated) {
                try Data(contentsOf: url)
            }.value
            let decoder = JSONDecoder()
            let submarines = try decoder.decode([Submarine].self, from: data)
            let validated = submarines.filter { $0.validated() }
            if validated.count != submarines.count {
                print("SubmarineRepository: Some submarines failed validation.")
            }
            cachedSubmarines = validated
            return validated
        } catch {
            let message = "Failed to decode Submarines.json."
            print("SubmarineRepository: \(message) \(error)")
            lastError = message
            cachedSubmarines = []
            return []
        }
    }
}
