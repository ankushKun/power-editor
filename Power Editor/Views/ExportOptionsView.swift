import SwiftUI

struct ExportOptionsView: View {
  @Environment(\.dismiss) var dismiss
  @ObservedObject var options: OptionsModel
  
  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Canvas Size")) {
          HStack {
            Text("Width:")
            TextField("Width", text: Binding(
              get: { String(Int(options.canvasSize.width)) },
              set: { if let val = Double($0) { options.canvasSize.width = val }}
            ))
            .keyboardType(.numberPad)
          }
          
          HStack {
            Text("Height:")
            TextField("Height", text: Binding(
              get: { String(Int(options.canvasSize.height)) },
              set: { if let val = Double($0) { options.canvasSize.height = val }}
            ))
            .keyboardType(.numberPad)
          }
        }
        
        Section(header: Text("Common Dimensions")) {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach([
                (1080, 1080), // Square
                (1080, 1920), // Story
                (1200, 630),  // Facebook
                (1280, 720),  // HD
                (1920, 1080)  // Full HD
              ], id: \.0) { width, height in
                Button(action: {
                  options.canvasSize.width = Double(width)
                  options.canvasSize.height = Double(height)
                }) {
                  VStack {
                    Text("\(width)×\(height)")
                      .font(.caption)
                    Text(width == height ? "Square" :
                         width == 1080 && height == 1920 ? "Story" :
                         width == 1200 ? "Facebook" :
                         width == 1280 ? "HD" : "Full HD")
                      .font(.caption2)
                  }
                  .padding(8)
                  .background(Color.blue.opacity(0.1))
                  .cornerRadius(8)
                }
              }
            }
            .padding(.vertical, 4)
          }
        }
      }
      .navigationTitle("Canvas Settings")
      .navigationBarItems(trailing: Button("Done") { dismiss() })
    }
  }
} 
