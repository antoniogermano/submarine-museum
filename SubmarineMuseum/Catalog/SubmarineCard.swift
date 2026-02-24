/*
Navy Museum

Abstract:
Reusable card for navigating to submarine exhibits.
*/

import SwiftUI

struct SubmarineCard: View {
    var submarine: Submarine

    private let cardWidth: CGFloat = 290
    private let cardCornerRadius: CGFloat = 20

    var body: some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 10) {
                SubmarineThumbnail(imageName: submarine.profileImageName ?? submarine.galleryItems.first?.imageName)
                    .frame(height: 100)
                    .padding(.top)
                    .offset(z: 5)

                Group {
                    Text(submarine.name)
                        .font(.headline)

                    Text(submarine.submarineClass?.name ?? submarine.era)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(submarine.nation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            .frame(width: cardWidth)
        }
        .buttonSizing(.fitted)
        .buttonBorderShape(.roundedRectangle(radius: cardCornerRadius))
    }

    private var route: ExhibitRoute {
        .full(submarine)
//        submarine.detailStatus == .full ? .full(submarine) : .stub(submarine)
    }
}
