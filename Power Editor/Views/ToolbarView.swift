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
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  let iconSize: CGFloat = 25
  
  func addTextLayer() {
    layers.insert(Layer(
      name: "Text Layer",
      content: .text("Hello World")
    ), at: 0)
  }
  
  func addColorLayer() {
    layers.insert(Layer(
      name: "Color Layer", 
      content: .color(.red)
    ), at: 0)
  }
  
  func addImageLayer(image: UIImage) {
    let scaledImgWidth = screenWidth/2
    let scaledImgHeight = scaledImgWidth * image.size.height / image.size.width
    
    layers.insert(Layer(
      name: "Image Layer",
      size: CGSize(width: scaledImgWidth, height: scaledImgHeight),
      content: .image(Image(uiImage: image))
    ), at: 0)
  }
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  var body: some View {
    VStack(spacing: 0) {
      if isLayerActive(), let activeIndex = getActiveLayerIndex(), activeIndex >= 0 {
        // Layer Options
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            switch layers[activeIndex].content {
            case .text(let text):
              TextField("Enter text...", text: Binding(get: {
                text
              }, set: { newValue in
                layers[activeIndex].content = .text(newValue)
              }))
              .background(.white)
              .foregroundStyle(.black)
              .frame(width: 200)
              .padding(.vertical, 8)
              
            case .color(let color):
              ColorPicker("", selection: Binding(get: {
                color
              }, set: { newValue in
                layers[activeIndex].content = .color(newValue)
              }))
              .labelsHidden()
              .frame(width: 40)
              
            default:
              Text("Layer \(activeIndex + 1)")
                .foregroundStyle(.white)
            }
          }
          .padding(.horizontal)
        }
        .frame(height: 60)
        .background(.black)
      } else {
        // Tools
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            Button(action: addTextLayer) {
              VStack(spacing: 4) {
                Image(systemName: "textformat")
                  .font(.system(size: iconSize))
                  .foregroundStyle(.blue)
                Text("Text")
                  .font(.caption2)
                  .foregroundStyle(.blue)
              }
            }
            
            Button(action: addColorLayer) {
              VStack(spacing: 4) {
                Image(systemName: "square.fill")
                  .font(.system(size: iconSize))
                  .foregroundStyle(.blue)
                Text("Color")
                  .font(.caption2)
                  .foregroundStyle(.blue)
              }
            }
            
            PhotosPicker(
              selection: Binding<PhotosPickerItem?>(
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
            ) {
              VStack(spacing: 4) {
                Image(systemName: "photo.badge.plus")
                  .font(.system(size: iconSize))
                  .foregroundStyle(.blue)
                Text("Image")
                  .font(.caption2)
                  .foregroundStyle(.blue)
              }
            }
          }
          .foregroundStyle(.white)
          .padding(.horizontal)
          .frame(height: 60)
        }
        .background(.black)
      }
    }
    .frame(height: 60)
  }
}
