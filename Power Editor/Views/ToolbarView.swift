//
//  ToolbarView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI
import PhotosUI


struct ToolbarView: View {
  @Binding var layers: [Layer]
  @State private var selectedImage: UIImage? = nil
  
  
  var screenWidth:CGFloat { UIScreen.main.bounds.width }
  
  func addTextLayer() {
    layers.insert(Layer(
      name: "Text Layer",
      content: .text("Hello World")
    ), at: 0)
  }
  
  func addColorLayer(){
    layers.insert(Layer(
      name: "Color Layer",
      content: .color(.red)
    ),at:0)
  }
  
  func addImageLayer(image: UIImage){
    let scaledImgWidth = screenWidth/2
    let scaledImgHeight = scaledImgWidth * image.size.height / image.size.width
    
    // add to layers
    layers.insert(Layer(
      name: "Image Layer",
      size: CGSize(width: scaledImgWidth,height: scaledImgHeight),
      content: .image(Image(uiImage: image))
    ),at:0)
  }
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  var body: some View {
    VStack(spacing: 0){
      // Layer Options
      ScrollView(.horizontal, showsIndicators: false){
        HStack{
          if isLayerActive(), let activeIndex = getActiveLayerIndex(), activeIndex >= 0 {
            
            switch layers[activeIndex].content {
              case .text(let text):
                //                  text input field
                TextField("",text: Binding(get: {
                  text
                }, set: {
                  newValue in
                  layers[activeIndex].content = .text(newValue)
                  print(newValue)
                  
                })).frame(maxHeight: .infinity)
                  .padding(5).background(.white).foregroundStyle(
                    .black
                  ).frame(maxWidth: 150)
              case .color(let color):
                ColorPicker("color", selection: Binding(get: {
                  color
                }, set: {
                  newValue in
                  layers[activeIndex].content = .color(newValue)
                })).frame(maxWidth: 30)
              default: Text("selected layer \(activeIndex)")
            }
          }
        }
        .frame(height:40)
        .padding(2)
        
      }
      .background(isLayerActive() ? .black : .gray)
      
      // Tools
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 10) {
          Button(action:addTextLayer) {
            Image(systemName: "textformat") .font(.system(size: iconSize))
          }
          Button(action:addColorLayer) {
            Image(systemName: "square.fill") .font(.system(size: iconSize))
          }
          PhotosPicker(
            selection:Binding<PhotosPickerItem?>(
              get: { nil },
              set: { item in
                guard let item = item else { return }
                Task {
                  if let data = try? await item.loadTransferable(type: Data.self),
                     let image = UIImage(data: data) {
                    
                    addImageLayer(image: image)
                  }
                }
              }
            ),
            matching: .images
          ){
            Image(systemName: "photo.badge.plus.fill")
              .font(.system(size: iconSize))
          }
        }
        .frame(height:40)
        .padding(5)
        .background(.black)
      }.background(.black)
    }.frame(maxHeight: 80).background(.gray)
  }
}
