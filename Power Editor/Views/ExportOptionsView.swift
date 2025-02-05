import SwiftUI

struct ExportOptionsView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var options: OptionsModel
  
  // Define dimension options as a static property
  private static let dimensionOptions = [
    ("Square", 1080, 1080, "square.fill"),
    ("Story", 1080, 1920, "rectangle.portrait.fill"),
    ("HD", 1280, 720, "rectangle.fill"),
    ("Full HD", 1920, 1080, "rectangle.fill")
  ]
  
  // Define grid columns as a property
  private let gridColumns = [
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  private var dimensionButtons: some View {
    LazyVGrid(columns: gridColumns, spacing: 16) {
      ForEach(Self.dimensionOptions, id: \.0) { name, width, height, icon in
        DimensionButton(
          name: name,
          width: width,
          height: height,
          icon: icon,
          action: {
            options.canvasSize.width = Double(width)
            options.canvasSize.height = Double(height)
          }
        )
      }
    }
    .padding(.vertical, 8)
  }
  
  var body: some View {
    NavigationView {
      Form {
        CanvasSizeSection(options: options)
        Section(header: Text("Common Dimensions")) {
          dimensionButtons
        }
      }
      .navigationTitle("Canvas Settings")
      .navigationBarItems(trailing: Button("Done") { dismiss() })
    }
  }
}

private struct CanvasSizeSection: View {
  @ObservedObject var options: OptionsModel
  
  var body: some View {
    Section(header: Text("Canvas Size")) {
      DimensionField(
        label: "Width:",
        value: Binding(
          get: { String(Int(options.canvasSize.width)) },
          set: { if let val = Double($0) { options.canvasSize.width = val }}
        )
      )
      DimensionField(
        label: "Height:",
        value: Binding(
          get: { String(Int(options.canvasSize.height)) },
          set: { if let val = Double($0) { options.canvasSize.height = val }}
        )
      )
    }
  }
}

private struct DimensionField: View {
  let label: String
  let value: Binding<String>
  
  var body: some View {
    HStack {
      Text(label)
        .foregroundColor(.secondary)
      TextField("", text: value)
        .keyboardType(.numberPad)
        .textFieldStyle(RoundedBorderTextFieldStyle())
      Text("px")
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 4)
  }
}

private struct DimensionButton: View {
  let name: String
  let width: Int
  let height: Int
  let icon: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.title2)
          .foregroundColor(.blue)
        Text(name)
          .font(.headline)
        Text("\(width)×\(height)")
          .font(.caption)
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 12)
      .background(Color.blue.opacity(0.1))
      .cornerRadius(12)
    }
  }
}
