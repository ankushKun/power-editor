import SwiftUI

struct TextLayer:Codable {
  var text: String
  var textStyle: TextStyle

  init(text: String, textStyle: TextStyle) {
    self.text = text
    self.textStyle = textStyle
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(text, forKey: .text)
    try container.encode(textStyle, forKey: .textStyle)
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    text = try container.decode(String.self, forKey: .text)
    textStyle = try container.decode(TextStyle.self, forKey: .textStyle)
  }

  enum CodingKeys: String, CodingKey {
    case text, textStyle
  }

  func toTextLayer() -> TextLayer {
    return TextLayer(text: text, textStyle: textStyle)
  }

  func toText() -> String {
    return text
  }

  func toTextStyle() -> TextStyle {
    return textStyle
  }
}

struct TextStyle: Codable {
  var size: Double
  var weight: Font.Weight
  var isItalic: Bool
  var color: Color
  var fontFamily: String
  
  init(size: Double = 20, weight: Font.Weight = .regular, isItalic: Bool = false, color: Color = .black, fontFamily: String = "Helvetica Neue") {
    self.size = size
    self.weight = weight
    self.isItalic = isItalic
    self.color = color
    self.fontFamily = fontFamily
  }
}

extension TextStyle {
  enum CodingKeys: String, CodingKey {
    case size, weight, isItalic, color, fontFamily
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(size, forKey: .size)
    try container.encode(weight.description, forKey: .weight)
    try container.encode(isItalic, forKey: .isItalic)
    try container.encode(ColorComponents(color: color), forKey: .color)
    try container.encode(fontFamily, forKey: .fontFamily)
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    size = try container.decode(Double.self, forKey: .size)
    let weightString = try container.decode(String.self, forKey: .weight)
    weight = Font.Weight.from(string: weightString)
    isItalic = try container.decode(Bool.self, forKey: .isItalic)
    let components = try container.decode(ColorComponents.self, forKey: .color)
    color = components.toColor()
    fontFamily = try container.decode(String.self, forKey: .fontFamily)
  }
}

extension Font.Weight {
  static func from(string: String) -> Font.Weight {
    switch string {
    case "Ultra Light": return .ultraLight
    case "Light": return .light
    case "Regular": return .regular
    case "Medium": return .medium
    case "Semibold": return .semibold
    case "Bold": return .bold
    case "Heavy": return .heavy
    default: return .regular
    }
  }

  public var description: String {
    switch self {
    case .ultraLight: return "Ultra Light"
    case .light: return "Light"
    case .regular: return "Regular"
    case .medium: return "Medium"
    case .semibold: return "Semibold"
    case .bold: return "Bold"
    case .heavy: return "Heavy"
    default: return "Regular"
    }
  }
}
