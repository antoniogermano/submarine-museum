/*
Navy Museum

Abstract:
The module detail content that's specific to the explore module.
*/

import SwiftUI

/// The module detail content that's specific to the explore module.
struct ExploreModule: View {
    var body: some View {
        AppIconView()
            .scaledToFit()
    }
}

#Preview {
    ExploreModule()
        .padding()
}
