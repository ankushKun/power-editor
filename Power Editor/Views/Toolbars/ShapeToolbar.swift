import SwiftUI

struct ShapeToolbar: View {
  @Binding var layer: Layer
  @State private var shape: ShapeType = .rectangle
  @State private var color: Color = .black
  
  private let availableShapes: [ShapeType] = [.rectangle, .circle]
  
  private func shapeIcon(_ type: ShapeType) -> String {
    switch type {
    case .rectangle: return "rectangle.fill"
    case .circle: return "circle.fill"
    }
  }
  
  private var shapeSelector: some View {
    VStack(spacing: 4) {
      Text("Shape").font(.caption).foregroundStyle(.gray)
      Menu {
        ForEach(availableShapes, id: \.self) { shapeType in
          Button(action: { updateShape(shapeType) }) {
            Label(shapeType.rawValue.capitalized, 
                  systemImage: shapeIcon(shapeType))
          }
        }
      } label: {
        Image(systemName: shapeIcon(shape))
          .font(.system(size: 16))
          .foregroundStyle(.white)
          .frame(width: 30, height: 30)
          .background(Color.blue.opacity(0.2))
          .cornerRadius(6)
      }
    }
  }
  
  private func updateShape(_ newShape: ShapeType) {
    shape = newShape
    if case .shape(let shapeLayer) = layer.content {
      layer.content = .shape(ShapeLayer(shape: newShape, color: shapeLayer.color))
    }
  }
  
  var body: some View {
    HStack(spacing: 10) {
      if case .shape(let shapeLayer) = layer.content {
        shapeSelector
        
        Divider().frame(height: 30)
        
        VStack(spacing: 4) {
          Text("Fill Color").font(.caption).foregroundStyle(.gray)
          ColorPicker("", selection: Binding(
            get: { shapeLayer.color },
            set: { layer.content = .shape(ShapeLayer(shape: shape, color: $0)) }
          ))
          .labelsHidden()
          .frame(width: 30, height: 30)
        }
      }
    }
    .padding(.horizontal, 5)
  }
}
