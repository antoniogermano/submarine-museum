/*
Navy Museum

Abstract:
Stub detail view for upcoming exhibits.
*/

import SwiftUI

struct StubDetailView: View {
    var submarine: Submarine

    var body: some View {
        VStack(spacing: 20) {
            SubmarineThumbnail(imageName: submarine.galleryItems.first?.imageName)
                .frame(width: 260, height: 160)

            Text(submarine.displayTitle)
                .font(.largeTitle)
                .bold()

            Text("Exhibit coming soon")
                .font(.title2)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(40)
        .navigationTitle("Exhibit Detail")
    }
}

#Preview {
    NavigationStack {
        StubDetailView(submarine: Submarine(
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
            detailStatus: .stub,
            model3D: nil,
            hotspots: [],
            exhibitSections: [],
            galleryItems: [],
            referenceLinks: [],
            locations: [
                Location(id: "a", name: "Museum", city: "City", region: "State", country: "Country", kind: .museum, latitude: 0, longitude: 0, notes: nil),
                Location(id: "b", name: "Historic Site", city: "City", region: "State", country: "Country", kind: .historicalSite, latitude: 0, longitude: 0, notes: nil)
            ]
        ))
    }
}
