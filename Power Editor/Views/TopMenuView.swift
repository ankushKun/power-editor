//
//  TopMenuView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//
import SwiftUI

//var maintainAspectRatio: Bool = true

struct TopMenuView: View {
  @Binding var layers: [Layer]
  @Binding var isSidebarVisible: Bool
  @EnvironmentObject var options: OptionsModel
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  func saveCanvas() {
      print("Trying to save canvas")

      // Define a higher resolution for the canvas
      let targetSize = CGSize(width: 2000, height: 2000) // Adjust as needed for desired quality
      let scale = targetSize.width / screenWidth
      // Create the high-resolution canvas
      let canvas = ZStack(alignment: .center) {
          ForEach(
              Array(layers.enumerated().filter { $0.element.isVisible }).reversed(),
              id: \.element.id
          ) { index, _ in
            LayerContentView(layer: layers[index])
              .scaleEffect(scale, anchor: UnitPoint(x: 0, y: 0))
          }
      }
      .background(.white)
      .frame(width: targetSize.width, height: targetSize.height) // High-res dimensions

      // Render the high-resolution canvas
      let renderer = ImageRenderer(content: canvas)
      renderer.scale = UIScreen.main.scale // Use device screen scale for sharper output
      
      // Save the rendered image
      if let img = renderer.uiImage {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
        showPopup(message: "Image saved to Photos")
      } else {
        showPopup(message: "Failed to save image")
      }
  }
  
  func showPopup(message: String) {
          guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController else {
              return
          }

          let alert = UIAlertController(
              title: nil,
              message: message,
              preferredStyle: .alert
          )
          rootViewController.present(alert, animated: true)

          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              alert.dismiss(animated: true)
          }
      }

  
    var body: some View {
        HStack {
          Button(action: {
            isSidebarVisible.toggle()
          }) {
            Label("Layers", systemImage: "square.3.layers.3d.top.filled")
              .font(.system(size: iconSize/1.2))
          }
          
          Spacer()
          
          Button(action:saveCanvas) {
              Label("Export", systemImage: "square.and.arrow.up")
              .font(.system(size: iconSize/1.2))
            }
        }
        .frame(height:40)
        .padding(5)
        .background(.black)
      
      ScrollView(.horizontal, showsIndicators: false){
        HStack{
          if isLayerActive(), let activeIndex = getActiveLayerIndex(), activeIndex >= 0 {
            Button(action:{options.maintainAspectRatio.toggle()}){
              Image(
                systemName: options.maintainAspectRatio ? "aspectratio.fill":"aspectratio"
              )
              .font(.system(size: iconSize))
            }
          }
        }
        .frame(height:40)
        .padding(5)
      }.background(isLayerActive() ? .black : .gray)
    }
}
