/*
Navy Museum

Abstract:
The modules that the app can present.
*/


import Foundation

/// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    case explore, catalog, favorites, immersive
    var id: Self { self }
    var name: String { rawValue.capitalized }

    var eyebrow: String {
        switch self {
        case .explore:
            String(localized: "Discover", comment: "The subtitle of the Explore module.")
        case .catalog:
            String(localized: "Browse the Fleet", comment: "The subtitle of the Catalog module.")
        case .favorites:
            String(localized: "Saved Items", comment: "The subtitle of the Favorites module.")
        case .immersive:
            String(localized: "Immersive", comment: "The subtitle of the Immersive module.")
        }
    }

    var heading: String {
        switch self {
        case .explore:
            String(localized: "Explore", comment: "The title of a module in the app.")
        case .catalog:
            String(localized: "Catalog", comment: "The title of a module in the app.")
        case .favorites:
            String(localized: "Favorites", comment: "The title of a module in the app.")
        case .immersive:
            String(localized: "Immersive", comment: "The title of a module in the app.")
        }
    }

    var abstract: String {
        switch self {
        case .explore:
            String(localized: "Inspect the featured submarine in 3D and open hotspot details.", comment: "Detail text explaining the Explore module.")
        case .catalog:
            String(localized: "Browse every submarine in the museum collection.", comment: "Detail text explaining the Catalog module.")
        case .favorites:
            String(localized: "Keep track of submarines you want to revisit.", comment: "Detail text explaining the Favorites module.")
        case .immersive:
            String(localized: "Step into a full-scale submarine scene and inspect the vessel up close.", comment: "Detail text explaining the Immersive module.")
        }
    }

    var overview: String {
        switch self {
        case .explore:
            String(localized: "Open a 3D submarine volume to inspect major components.\n\nTap hotspots for context and rotate the model to examine it from different angles.", comment: "Educational text displayed in the Explore module.")
        case .catalog:
            String(localized: "Search, filter, and compare submarines across eras and nations.\n\nEach entry highlights design details, service history, and where you can see the vessel today.", comment: "Educational text displayed in the Catalog module.")
        case .favorites:
            String(localized: "Save submarines to build your own tour plan and return later.", comment: "Educational text displayed in the Favorites module.")
        case .immersive:
            String(localized: "Enter a full-scale submarine scene in an immersive environment.\n\nMove around the vessel and examine it from multiple viewpoints.", comment: "Educational text displayed in the Immersive module.")
        }
    }

    var callToAction: String {
        switch self {
        case .explore: String(localized: "Open Explore", comment: "An action the viewer can take in the Explore module.")
        case .catalog: String(localized: "Open Catalog", comment: "An action the viewer can take in the Catalog module.")
        case .favorites: String(localized: "Your saved submarines appear below.", comment: "Supporting text displayed in the Favorites module.")
        case .immersive: String(localized: "Enter Immersive", comment: "An action the viewer can take in the Immersive module.")
        }
    }

    static let funFacts = [
        String(localized: "The first practical submarines were powered by hand-cranked propulsion.", comment: "An educational fact displayed in the Deep Sea Theater module."),
        String(localized: "Modern submarines control buoyancy with ballast tanks filled with water or air.", comment: "An educational fact displayed in the Deep Sea Theater module."),
        String(localized: "Periscopes let submarines observe the surface while staying submerged.", comment: "An educational fact displayed in the Deep Sea Theater module."),
        String(localized: "Research submarines explore deep-sea ecosystems far beyond sunlight.", comment: "An educational fact displayed in the Deep Sea Theater module.")
    ]
}
