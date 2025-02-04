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
  
  private var screenWidth: CGFloat { UIScreen.main.bounds.width }
  private var scaleFactor: CGFloat { screenWidth / options.canvasSize.width }
  
  private var scaledPosition: CGPoint {
    CGPoint(
      x: layer.position.x * scaleFactor,
      y: layer.position.y * scaleFactor
    )
  }
  
  private var scaledSize: CGSize {
    CGSize(
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
          Text(text)
            .font(.system(size: 20))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
      }
    }
    .frame(width: scaledSize.width, height: scaledSize.height)
    .rotationEffect(.degrees(layer.rotation))
    .position(
      x: scaledPosition.x + scaledSize.width / 2,
      y: scaledPosition.y + scaledSize.height / 2
    )
    .opacity(layer.opacity)
  }
}
