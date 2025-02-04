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
          HStack(spacing: 12) {
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
            
            HStack(spacing: 16) {
              Button(action: { layer.isLocked.toggle() }) {
                Image(systemName: layer.isLocked ? "lock.fill" : "lock.open.fill")
                  .foregroundStyle(layer.isLocked ? .blue : .gray)
              }
              .buttonStyle(.plain)
              
              Button(action: { layer.isVisible.toggle() }) {
                Image(systemName: layer.isVisible ? "eye.fill" : "eye.slash.fill")
                  .foregroundStyle(layer.isVisible ? .blue : .gray)
              }
              .buttonStyle(.plain)
            }
          }
          .listRowBackground(layer.isActive ? Color.blue.opacity(0.2) : Color.clear)
        }
        .listStyle(.plain)
        
        // Layer Properties
        if isLayerActive(), let activeIndex = getActiveLayerIndex(), activeIndex >= 0 {
          VStack(spacing: 16) {
            TextField("Layer Name", 
                     text: Binding(
                       get: { layers[activeIndex].name },
                       set: { layers[activeIndex].name = $0 }
                     )
            )
            .foregroundStyle(.black)
            .background(.white)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
              Text("Opacity")
                .font(.subheadline)
                .foregroundStyle(.gray)
              
              HStack {
                Slider(
                  value: Binding(
                    get: { layers[activeIndex].opacity },
                    set: { layers[activeIndex].opacity = $0 }
                  ),
                  in: 0...1
                )
                .tint(.blue)
                
                Text("\(Int(layers[activeIndex].opacity * 100))%")
                  .foregroundStyle(.white)
                  .frame(width: 45)
              }
            }
            .padding(.horizontal)
          }
          .padding(.vertical)
          .background(.black.opacity(0.5))
        }
        
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
