import SwiftUI

struct ColorToolbar: View {
  @Binding var layer: Layer
  @State private var selectedShape: String = "rectangle"
  @State private var fillColor: Color = .blue
  
  private let availableShapes = [
    "rectangle",
    "circle", 
    "triangle"
  ]
  
  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 10) {
        if case .color(let color) = layer.content {
          // Shape Selection
          VStack(spacing: 4) {
            Text("Shape")
              .font(.caption)
              .foregroundStyle(.gray)
            Menu {
              ForEach(availableShapes, id: \.self) { shape in
                Button(action: {
                  selectedShape = shape
                }) {
                  HStack {
                    Image(systemName: shape == "rectangle" ? "rectangle.fill" : 
                                    shape == "circle" ? "circle.fill" : "triangle.fill")
                    Text(shape.capitalized)
                  }
                }
              }
            } label: {
              Image(systemName: selectedShape == "rectangle" ? "rectangle.fill" :
                               selectedShape == "circle" ? "circle.fill" : "triangle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(6)
            }
          }
          
          Divider()
            .frame(height: 30)
          
          // Color Picker
          VStack(spacing: 4) {
            Text("Fill Color")
              .font(.caption)
              .foregroundStyle(.gray)
            ColorPicker("", selection: Binding(get: {
              color
            }, set: { newValue in
              layer.content = .color(newValue)
            }))
            .labelsHidden()
            .frame(width: 30, height: 30)
          }
        }
      }
      .padding(.horizontal, 5)
    }
  }
}