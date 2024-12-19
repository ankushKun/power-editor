//
//  Layer.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI

struct Layer: Identifiable {
    let id = UUID()
    var name: String
    var isVisible: Bool = true
    var isActive: Bool = false
    var position:CGPoint = CGPoint(x: UIScreen.main.bounds.width/2 - 50, y: UIScreen.main.bounds.width/2 - 50)
    var size:CGSize = CGSize(width: 100, height: 100)
    var maintainAspectRatio:Bool = true
    var content: LayerContent
  
//  static func == (lhs: Layer, rhs: Layer) -> Bool {
//    lhs.id == rhs.id
//  }
}

enum LayerContent {
    case color(Color)
    case image(Image)
    case text(String)
}
