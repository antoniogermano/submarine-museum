/*
Navy Museum

Abstract:
Simple local persistence for favorites.
*/

import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()

    private let storageKey = "favoriteSubmarineIDs"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func allFavorites() -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey) ?? [])
    }

    func isFavorite(id: String) -> Bool {
        allFavorites().contains(id)
    }

    func setFavorite(id: String, isFavorite: Bool) {
        var favorites = allFavorites()
        if isFavorite {
            favorites.insert(id)
        } else {
            favorites.remove(id)
        }
        defaults.set(Array(favorites), forKey: storageKey)
    }

    @discardableResult
    func toggleFavorite(id: String) -> Bool {
        let newValue = !isFavorite(id: id)
        setFavorite(id: id, isFavorite: newValue)
        return newValue
    }
}
