//
//  LayerContentView.swift
//  Power Editor
//
//  Created by Ankush Singh on 19/12/24.
//


import SwiftUI

struct LayerContentView: View {
  var layer: Layer

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
    .frame(width: layer.size.width, height: layer.size.height)
    .rotationEffect(.degrees(layer.rotation))
    .position(
      x: layer.position.x + layer.size.width / 2,
      y: layer.position.y + layer.size.height / 2
    )
    
    .opacity(layer.opacity)
  }
}
