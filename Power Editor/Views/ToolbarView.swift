//
//  ToolbarView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//

import SwiftUI
import PhotosUI

struct AddLayerToolbar: View {
  let iconSize: CGFloat
  let addTextLayer: () -> Void
  let addShapeLayer: () -> Void
  let addImageLayer: (UIImage) -> Void
  
  var body: some View {
    HStack(spacing: 10) {
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
      
      Button(action: addShapeLayer) {
        VStack(spacing: 4) {
          Image(systemName: "square.fill")
            .font(.system(size: iconSize))
            .foregroundStyle(.blue)
          Text("Shape")
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
                addImageLayer(image)
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
}

struct ToolbarView: View {
  @Binding var layers: [Layer]
  @State private var selectedImage: UIImage? = nil
  let iconSize: CGFloat = 25
  
  func addTextLayer() {
    layers.insert(Layer(
      name: "Text Layer",
      content: .text(TextLayer(text: "Hello World", textStyle: TextStyle(size: 20, weight: .regular, isItalic: false, color: .black, fontFamily: "Helvetica Neue")))
    ), at: 0)
    layers[0].isActive = true
  }
  
  func addShapeLayer() {
    layers.insert(Layer(
      name: "Shape Layer",
      content: .shape(ShapeLayer(shape: .rectangle, color: .red))
    ), at: 0)
    layers[0].isActive = true
  }
  
  func addImageLayer(image: UIImage) {
    let scaledImgWidth = UIScreen.main.bounds.width/2
    let scaledImgHeight = scaledImgWidth * image.size.height / image.size.width
    
    layers.insert(Layer(
      name: "Image Layer",
      size: CGSize(width: scaledImgWidth, height: scaledImgHeight),
      content: .image(Image(uiImage: image))
    ), at: 0)
    layers[0].isActive = true
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
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 16) {
            switch layers[activeIndex].content {
            case .text:
              TextToolbar(layer: $layers[activeIndex])
            case .color:
              ColorToolbar(layer: $layers[activeIndex])
            case .image:
              ImageToolbar(layerIndex: activeIndex)
            case .shape:
              ShapeToolbar(layer: $layers[activeIndex])
            }
          }
          .padding(.horizontal)
        }
        .frame(height: 60)
        .background(.black)
      } else {
        ScrollView(.horizontal, showsIndicators: false) {
          AddLayerToolbar(
            iconSize: iconSize,
            addTextLayer: addTextLayer,
            addShapeLayer: addShapeLayer,
            addImageLayer: addImageLayer
          )
        }
        .background(.black)
      }
    }
    .frame(height: 60)
  }
}
