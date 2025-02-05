//
//  SidebarView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//
import SwiftUI

struct SidebarView: View {
  let iconSize: CGFloat = 25
  @Binding var isSidebarVisible: Bool
  @Binding var layers: [Layer]
  @State var deleteAlertVisible: Bool = false
  @State var editingLayerId: UUID? = nil
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  func deleteActiveLayer() {
    guard let index = getActiveLayerIndex() else { return }
    layers.remove(at: index)
  }
  
  var body: some View {
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 0) {
        // Header
        HStack {
          Label("Layers", systemImage: "square.3.layers.3d")
            .font(.headline)
            .foregroundStyle(.white)
          
          Spacer()
          
          Button(action: { isSidebarVisible.toggle() }) {
            Image(systemName: "xmark")
              .font(.system(size: iconSize*0.75))
              .foregroundStyle(.white)
          }
        }
        .padding()
        .background(.black)
        
        // Layer List
        List($layers, editActions: .move) { $layer in
          VStack(spacing: 4) {
            // Existing layer header
            HStack(spacing: 12) {
              if editingLayerId == layer.id {
                TextField("Layer Name", text: $layer.name)
                  .textFieldStyle(.plain)
                  .foregroundStyle(.white)
                  .onSubmit { editingLayerId = nil }
              } else {
                Button(action: {
                  for i in layers.indices {
                    layers[i].isActive = (layers[i].id == layer.id)
                  }
                }) {
                  Text(layer.name)
                    .padding(.vertical, 8)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .onTapGesture(count: 2) {
                  editingLayerId = layer.id
                }
              }
              
              HStack(spacing: 16) {
                // Add duplicate button
                Button(action: {
                  let newLayer = Layer(
                    name: "\(layer.name) Copy",
                    isVisible: layer.isVisible,
                    isActive: false,
                    isLocked: layer.isLocked,
                    opacity: layer.opacity,
                    position: CGPoint(x: layer.position.x + 20, y: layer.position.y + 20),
                    rotation: layer.rotation,
                    size: layer.size,
                    content: layer.content
                  )
                  // Insert after current layer
                  if let index = layers.firstIndex(where: { $0.id == layer.id }) {
                    layers.insert(newLayer, at: index + 1)
                  }
                }) {
                  Image(systemName: "plus.square.on.square")
                    .foregroundStyle(.gray)
                }
                .buttonStyle(.plain)
                
                // Existing lock button
                Button(action: { layer.isLocked.toggle() }) {
                  Image(systemName: layer.isLocked ? "lock.fill" : "lock.open.fill")
                    .foregroundStyle(layer.isLocked ? .blue : .gray)
                }
                .buttonStyle(.plain)
                
                // Existing visibility button
                Button(action: { layer.isVisible.toggle() }) {
                  Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash.fill")
                    .foregroundStyle(layer.isVisible ? .blue : .gray)
                }
                .buttonStyle(.plain)
              }
            }
            
            // Add opacity slider
            if layer.isActive {
              HStack {
                Image(systemName: "circle.lefthalf.filled")
                  .foregroundStyle(.gray)
                Slider(value: $layer.opacity, in: 0...1)
                  .frame(width: 100)
                Text("\(Int(layer.opacity * 100))%")
                  .foregroundStyle(.gray)
                  .font(.caption)
              }
              .padding(.horizontal)
              .padding(.bottom, 4)
              .frame(width:.infinity)
            }
          }
          .listRowBackground(layer.isActive ? Color.blue.opacity(0.2) : Color.clear)
        }
        .listStyle(.plain)
        
        Spacer(minLength: 50)
      }
      .frame(width: 300)
      .background(.black.opacity(0.95))
      
      if isSidebarVisible {
        Rectangle()
          .foregroundColor(.clear)
          .frame(maxWidth: .infinity)
          .contentShape(Rectangle())
          .onTapGesture {
            isSidebarVisible.toggle()
          }
          .transition(.opacity)
      }
    }
    .background(.black.opacity(0.3))
  }
}
