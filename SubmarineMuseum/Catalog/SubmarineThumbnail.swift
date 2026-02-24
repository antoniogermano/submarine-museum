/*
Navy Museum

Abstract:
Thumbnail view for submarine cards.
*/

import SwiftUI

struct SubmarineThumbnail: View {
    var imageName: String?

    var body: some View {
        if let imageName {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: 18))
        } else {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.blue.opacity(0.2))
                .overlay {
                    Image(systemName: "ferry.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)
                        .accessibilityHidden(true)
                }
        }
    }
}
