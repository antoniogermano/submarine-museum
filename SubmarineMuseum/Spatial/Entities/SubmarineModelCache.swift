/*
Navy Museum

Abstract:
In-memory cache for submarine USDZ model entities.
*/

import Foundation
import RealityKit
#if canImport(UIKit)
import UIKit
#endif

actor SubmarineModelCache {
    static let shared = SubmarineModelCache()

    private let maxPrototypeCount = 2
    private var prototypeByName: [String: Entity] = [:]
    private var lruOrder: [String] = []

    func entity(named usdzName: String) async -> Entity? {
        guard let prototype = await prototypeEntity(named: usdzName) else {
            return nil
        }
        return await MainActor.run {
            prototype.clone(recursive: true)
        }
    }

    func preload(usdzNames: [String]) async {
        for name in Set(usdzNames) {
            _ = await prototypeEntity(named: name)
        }
    }

    func evictAll() {
        prototypeByName.removeAll(keepingCapacity: false)
        lruOrder.removeAll(keepingCapacity: false)
    }

    private func prototypeEntity(named usdzName: String) async -> Entity? {
        if let cached = prototypeByName[usdzName] {
            touch(usdzName)
            return cached
        }

        guard let loaded = try? await Entity(named: usdzName, in: .main) else {
            return nil
        }

        prototypeByName[usdzName] = loaded
        touch(usdzName)
        evictIfNeeded()
        return loaded
    }

    private func touch(_ usdzName: String) {
        lruOrder.removeAll { $0 == usdzName }
        lruOrder.append(usdzName)
    }

    private func evictIfNeeded() {
        while prototypeByName.count > maxPrototypeCount, let oldest = lruOrder.first {
            prototypeByName.removeValue(forKey: oldest)
            lruOrder.removeFirst()
        }
    }
}

final class SubmarineModelCacheMemoryPressureObserver {
    static let shared = SubmarineModelCacheMemoryPressureObserver()

    private var token: NSObjectProtocol?

    private init() {}

    func start() {
        guard token == nil else { return }

        #if canImport(UIKit)
        token = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task {
                await SubmarineModelCache.shared.evictAll()
            }
        }
        #endif
    }
}

