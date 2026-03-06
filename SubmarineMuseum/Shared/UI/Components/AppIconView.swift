//
//  AppIconView.swift
//  Navy Museum
//
//  Created by Antonio Germano on 17/2/26.
//

import SwiftUI

struct AppIconView: View {
  var body: some View {
    appIcon
  }
  
  private var appIcon: some View {
    GeometryReader { proxy in
      let size = min(proxy.size.width, proxy.size.height)
      
      // Calculate Z axis offset such that it scales with size while still looking good on all possible sizes
      let minSize: CGFloat = 80
      let maxSize: CGFloat = 320
      let minOffset: CGFloat = 6
      let maxOffset: CGFloat = 24
      
      let t = clamp((size - minSize) / (maxSize - minSize), to: 0...1)
      // t grows 0→1 as size grows
      let eased = pow(t, 0.6) // <1 makes it drop slower when small
      let offset = minOffset + (maxOffset - minOffset) * eased
      
      ZStack {
        Image("sky")
          .resizable()
          .clipShape(Circle())
          .scaledToFit()
        Image("submarine")
          .resizable()
          .clipShape(Circle())
          .scaledToFit()
          .offset(z: offset * 0.75) // the ship is closer to the water than it is to the sky
        Image("water")
          .resizable()
          .clipShape(Circle())
          .scaledToFit()
          .offset(z: offset * 1)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
  
  private func clamp(_ value: CGFloat, to range: ClosedRange<CGFloat>) -> CGFloat {
    min(max(value, range.lowerBound), range.upperBound)
  }
}

#Preview(windowStyle: .automatic) {
  AppIconView()
}
