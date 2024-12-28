//
//  Layer.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI

//extension CGPoint: Codable {
//  public func encode(to encoder: Encoder) throws {
//    var container = encoder.unkeyedContainer()
//    try container.encode(x)
//    try container.encode(y)
//  }
//  
//  public init(from decoder: Decoder) throws {
//    var container = try decoder.unkeyedContainer()
//    let x = try container.decode(Double.self)
//    let y = try container.decode(Double.self)
//    self.init(x: x, y: y)
//  }
//}
//
//extension CGSize: Codable {
//  public func encode(to encoder: Encoder) throws {
//    var container = encoder.unkeyedContainer()
//    try container.encode(width)
//    try container.encode(height)
//  }
//  
//  public init(from decoder: Decoder) throws {
//    var container = try decoder.unkeyedContainer()
//    let width = try container.decode(Double.self)
//    let height = try container.decode(Double.self)
//    self.init(width: width, height: height)
//  }
//}


struct Layer: Identifiable, Codable {
  let id: UUID
  var name: String
  var isVisible: Bool
  var isActive: Bool
  var isLocked: Bool
  var opacity: Double
  var position: CGPoint
  var rotation: Double
  var size: CGSize
  var content: LayerContent
  
  init(name: String,
       isVisible: Bool = true,
       isActive: Bool = false,
       isLocked: Bool = false,
       opacity: Double = 1.0,
       position: CGPoint = CGPoint(x: UIScreen.main.bounds.width/2 - 50, y: UIScreen.main.bounds.width/2 - 50),
       rotation: Double = 0.0,
       size: CGSize = CGSize(width: 100, height: 100),
       content: LayerContent) {
    self.id = UUID()
    self.name = name
    self.isVisible = isVisible
    self.isActive = isActive
    self.isLocked = isLocked
    self.opacity = opacity
    self.position = position
    self.rotation = rotation
    self.size = size
    self.content = content
  }
}

struct ColorComponents: Codable {
  let red: Double
  let green: Double
  let blue: Double
  let opacity: Double
  
  init(color: Color) {
    let resolver = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    resolver.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    self.red = Double(red)
    self.green = Double(green)
    self.blue = Double(blue)
    self.opacity = Double(alpha)
  }
  
  func toColor() -> Color {
    Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
  }
}

// Make LayerContent conform to Codable
enum LayerContent: Codable {
  case color(Color)
  case image(Image)
  case text(String)
  
  private enum ContentType: String, Codable {
    case color, image, text
  }
  
  private enum CodingKeys: String, CodingKey {
    case type, text, color
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
      case .color(let color):
        try container.encode(ContentType.color.rawValue, forKey: .type)
        let components = ColorComponents(color: color)
        try container.encode(components, forKey: .color)
        
      case .text(let text):
        try container.encode(ContentType.text.rawValue, forKey: .type)
        try container.encode(text, forKey: .text)
        
      case .image:
        try container.encode(ContentType.image.rawValue, forKey: .type)
    }
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    
    switch type {
      case ContentType.color.rawValue:
        if let components = try? container.decode(ColorComponents.self, forKey: .color) {
          self = .color(components.toColor())
        } else {
          // Fallback for old files that might not have color components
          self = .color(.blue)
        }
        
      case ContentType.text.rawValue:
        let text = try container.decode(String.self, forKey: .text)
        self = .text(text)
        
      case ContentType.image.rawValue:
        self = .image(Image(systemName: "photo"))
        
      default:
        throw DecodingError.dataCorruptedError(
          forKey: .type,
          in: container,
          debugDescription: "Invalid type: \(type)"
        )
    }
  }
}
