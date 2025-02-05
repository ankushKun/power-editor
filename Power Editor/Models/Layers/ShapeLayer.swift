import SwiftUI

enum ShapeType: String, Codable {
    case rectangle
    case circle
}

struct ShapeLayer: Codable {
  var shape: ShapeType
  var color: Color

  init(shape: ShapeType, color: Color) {
    self.shape = shape
    self.color = color
  } 

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(shape, forKey: .shape)
    try container.encode(ColorComponents(color: color), forKey: .color)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    shape = try container.decode(ShapeType.self, forKey: .shape)
    let components = try container.decode(ColorComponents.self, forKey: .color)
    color = components.toColor()
  }

  enum CodingKeys: String, CodingKey {
    case shape, color
  }

  func toShapeLayer() -> ShapeLayer {
    return ShapeLayer(shape: shape, color: color)
  }

  func toShape() -> ShapeType {
    return shape
  }

  func toColor() -> Color {
    return color
  }
}
