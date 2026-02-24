/*
Navy Museum

Abstract:
Unit tests for favorites persistence.
*/

import Foundation
import Testing

@testable import SubmarineMuseum

struct FavoritesStoreTests {
    @Test
    func toggleAndPersistFavorites() throws {
        let suiteName = "FavoritesStoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            #expect(Bool(false))
            return
        }
        defaults.removePersistentDomain(forName: suiteName)

        let store = FavoritesStore(defaults: defaults)
        let id = "uss-gato-ss-212"

        #expect(store.isFavorite(id: id) == false)
        store.setFavorite(id: id, isFavorite: true)
        #expect(store.isFavorite(id: id) == true)

        let storeReloaded = FavoritesStore(defaults: defaults)
        #expect(storeReloaded.isFavorite(id: id) == true)

        storeReloaded.setFavorite(id: id, isFavorite: false)
        #expect(storeReloaded.isFavorite(id: id) == false)
    }
}
