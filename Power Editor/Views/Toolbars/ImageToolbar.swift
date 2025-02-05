import SwiftUI

struct ImageToolbar: View {
  let layerIndex: Int
  
  var body: some View {
    Text("Layer \(layerIndex + 1)")
      .foregroundStyle(.white)
  }
}