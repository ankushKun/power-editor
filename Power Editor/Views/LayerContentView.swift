//
//  LayerContentView.swift
//  Power Editor
//
//  Created by Ankush Singh on 19/12/24.
//


import SwiftUI

struct LayerContentView: View {
  let layer: Layer
  @EnvironmentObject var options: OptionsModel
  var export: Bool = false
  
  private var screenWidth: CGFloat { UIScreen.main.bounds.width }
  private var scaleFactor: CGFloat { screenWidth / options.canvasSize.width }
  
  private var position: CGPoint {
    if export {
      return layer.position
    }
    return CGPoint(
      x: layer.position.x * scaleFactor,
      y: layer.position.y * scaleFactor
    )
  }
  
  private var size: CGSize {
    if export {
      return layer.size
    }
    return CGSize(
      width: layer.size.width * scaleFactor,
      height: layer.size.height * scaleFactor
    )
  }
  
  var body: some View {
    ZStack {
      switch layer.content {
        case .color(let color):
          Rectangle().fill(color)
        case .image(let image):
          image.resizable()
        case .text(let text):
          let textSize = export ? 
            text.toTextStyle().size * (options.canvasSize.width / screenWidth) : 
            text.toTextStyle().size
            
          Text(text.toText())
            .font(.custom(text.toTextStyle().fontFamily, size: textSize, relativeTo: .body))
            .fontWeight(text.toTextStyle().weight)
            .italic(text.toTextStyle().isItalic)
            .foregroundColor(text.toTextStyle().color)
            .multilineTextAlignment(.center)
        case .shape(let shape):
          switch shape.shape {
            case .rectangle:
              Rectangle().fill(shape.color)
            case .circle:
              Circle().fill(shape.color)
            default:
              Rectangle().fill(shape.color)
          }
      }
    }
    .frame(width: size.width, height: size.height)
    .rotationEffect(.degrees(layer.rotation))
    .position(
      x: position.x + size.width / 2,
      y: position.y + size.height / 2
    )
    .opacity(layer.opacity)
  }
}
