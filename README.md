# Submarine Museum

Submarine Museum is a visionOS app for exploring historic submarines with 2D content, 3D volumetric inspection, and a full immersive scene.

## What the app includes

- A main window (`Modules`) with four modules: `Explore`, `Catalog`, `Favorites`, and `Immersive`.
- A volumetric window (`SceneID.exploreVolume`) that loads a submarine model in `RealityView`, with tappable hotspots and waypoints.
- An immersive space (`SceneID.submarineImmersive`) for full-scale viewing and waypoint teleport controls.
- A gallery image window (`SceneID.galleryImageWindow`) that opens selected exhibit photos in a dedicated window with Spatial Photo support.
- A catalog flow with search and filtering by era/nation, plus exhibit detail pages.
- A favorites system persisted via `UserDefaults` (`FavoritesStore`).

## Core data and assets

- Data source: `SubmarineMuseum/SubmarineMuseum/Resources/Submarines.json`
- 3D model asset: `SubmarineMuseum/SubmarineMuseum/Resources/USS_Gato_SS-212_Submarine_Displayed_on_Concrete_Blocks_SC_max_vray.usdz`
- Additional images and app assets: `Assets.xcassets`

## Main files (high level)

- App entry: `SubmarineMuseum/SubmarineMuseum/SubmarineMuseumApp.swift`
- App state: `SubmarineMuseum/SubmarineMuseum/Model/ViewModel.swift`
- Data repository: `SubmarineMuseum/SubmarineMuseum/Museum/SubmarineRepository.swift`
- 3D entity setup and behavior: `SubmarineMuseum/SubmarineMuseum/Entities/*`
- Module UI and navigation: `SubmarineMuseum/SubmarineMuseum/Modules/*`
- Catalog and exhibit detail experience: `SubmarineMuseum/SubmarineMuseum/Catalog/*`
- Explore/Immersive experiences: `SubmarineMuseum/SubmarineMuseum/Explore*` and `SubmarineMuseum/SubmarineMuseum/Immersive/*`

## Tests

Unit tests live in `SubmarineMuseum/SubmarineMuseumTests/` and currently cover:

- Favorites mapping and persistence behavior
- Submarine repository loading/decoding behavior
- Detail status and entity configuration behavior
- Hotspot and waypoint position decoding
