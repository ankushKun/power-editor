import SwiftUI

struct TextToolbar: View {
  @Binding var layer: Layer
  @State private var fontSize: Double = 20
  @State private var fontWeight: Font.Weight = .regular
  @State private var textColor: Color = .black
  @State private var isItalic: Bool = false
  @State private var fontFamily: String = "Helvetica Neue"
  
  private let availableFonts = [
    "Helvetica Neue", // default font
    "Arial",
    "Georgia",
    "Times New Roman",
    "Avenir Next",
    "Futura",
    "Palatino",
    "Courier New"
  ]
  
  private func updateTextStyle() {
    if case .text(let textLayer) = layer.content {
      layer.content = .text(TextLayer(
        text: textLayer.text,
        textStyle: TextStyle(
          size: fontSize,
          weight: fontWeight,
          isItalic: isItalic,
          color: textColor,
          fontFamily: fontFamily
        )
      ))
    }
  }
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        if case .text(_) = layer.content {
          // Text Input
          VStack(alignment: .leading, spacing: 4) {
            Text("Text")
              .font(.caption)
              .foregroundStyle(.gray)
            TextField("Enter text...", text: Binding(get: {
              if case .text(let textLayer) = layer.content {
                return textLayer.text
              }
              return ""
            }, set: { newValue in
              if case .text(let textLayer) = layer.content {
                layer.content = .text(TextLayer(
                  text: newValue,
                  textStyle: textLayer.textStyle
                ))
              }
            }))
            .padding(2)
            .background(.white)
            .foregroundStyle(.black)
            .cornerRadius(6)
            .frame(width: 200)
          }
          
          Divider()
            .frame(height: 30)
          
          // Font Size Control
          VStack(spacing: 4) {
            Text("Size: \(Int(fontSize))")
              .font(.caption)
              .foregroundStyle(.gray)
            HStack(spacing: 8) {
              Text("10")
                .font(.caption2)
                .foregroundStyle(.gray)
              Slider(value: $fontSize, in: 10...100)
                .frame(width: 100)
              Text("100")
                .font(.caption2)
                .foregroundStyle(.gray)
            }
          }
          
          Divider()
            .frame(height: 30)
          
          // Font Style Controls
          VStack(spacing: 4) {
            Text("Style")
              .font(.caption)
              .foregroundStyle(.gray)
            HStack(spacing: 12) {
              Menu {
                ForEach([Font.Weight.ultraLight, .light, .regular, .medium, .semibold, .bold, .heavy], id: \.self) { weight in
                  Button(action: { fontWeight = weight }) {
                    Text(weight.description)
                      .fontWeight(weight)
                  }
                }
              } label: {
                Image(systemName: "bold")
                  .font(.system(size: 16))
                  .foregroundStyle(fontWeight != .regular ? .blue : .gray)
                  .frame(width: 30, height: 30)
                  .background(fontWeight != .regular ? Color.blue.opacity(0.2) : Color.clear)
                  .cornerRadius(6)
              }
              
              Button(action: { isItalic.toggle() }) {
                Image(systemName: "italic")
                  .font(.system(size: 16))
                  .foregroundStyle(isItalic ? .blue : .gray)
                  .frame(width: 30, height: 30)
                  .background(isItalic ? Color.blue.opacity(0.2) : Color.clear)
                  .cornerRadius(6)
              }
            }
          }
          
          Divider()
            .frame(height: 30)
          
          // Font Family Menu
          VStack(spacing: 4) {
            Text("Font")
              .font(.caption)
              .foregroundStyle(.gray)
            Menu {
              ForEach(availableFonts, id: \.self) { font in
                Button(action: { 
                  fontFamily = font
                  updateTextStyle()
                }) {
                  Text(font)
                    .font(.custom(font, size: 14))
                }
              }
            } label: {
              Text(fontFamily)
                .font(.custom(fontFamily, size: 14))
                .foregroundStyle(.white)
                .frame(width: 120)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
          }
          
          Divider()
            .frame(height: 30)
          
          // Color Picker
          VStack(spacing: 4) {
            Text("Color")
              .font(.caption)
              .foregroundStyle(.gray)
            ColorPicker("", selection: $textColor)
              .labelsHidden()
              .frame(width: 30, height: 30)
          }
        }
      }
      .padding(.horizontal,5)
    }
    .onChange(of: fontSize) { _ in updateTextStyle() }
    .onChange(of: fontWeight) { _ in updateTextStyle() }
    .onChange(of: isItalic) { _ in updateTextStyle() }
    .onChange(of: textColor) { _ in updateTextStyle() }
    .onAppear {
      if case .text(let textLayer) = layer.content {
        fontSize = textLayer.textStyle.size
        fontWeight = textLayer.textStyle.weight
        textColor = textLayer.textStyle.color
        isItalic = textLayer.textStyle.isItalic
        fontFamily = textLayer.textStyle.fontFamily
      }
    }
  }
}
