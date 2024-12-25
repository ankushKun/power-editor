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
  @State var deleteAlertVisible:Bool = false
  
  func isLayerActive() -> Bool {
    return layers.contains(where: \.isActive)
  }
  
  func getActiveLayerIndex() -> Int? {
    return layers.firstIndex(where: \.isActive)
  }
  
  func deleteActiveLayer() {
    guard let index = getActiveLayerIndex() else { return }
    print("deleted layer", index)
    layers.remove(at: index)
  }
  
  var body: some View {
    HStack{
      VStack(alignment: .leading, spacing: 0) {
        HStack
        {
          Image(systemName: "square.3.layers.3d").font(.system(size: iconSize))
          Text("Layers").font(.headline).padding(.leading, 10)
          Spacer()
          Button(action:{
            isSidebarVisible.toggle()
          }) {
            Image(systemName: "xmark").font(.system(size: iconSize))
          }
        }.padding(.leading,10).padding(.trailing,15)
        
        
        
        List($layers,editActions: .move) { $layer in
          // Add layers dynamically
          //          ForEach($layers) { $layer in
          HStack() {
            Button(action:{
              // loop through all layers and set them to false
              // for the active layer set isActive to true
              for i in layers.indices {
                layers[i].isActive = (layers[i].id == layer.id)
              }
              print(layers)
            }){
              Text(layer.name)
                .padding(.top,5)
                .padding(.bottom,5)
                .frame(
                  maxWidth: .infinity,
                  alignment: .leading
                )
            }.buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action:{layer.isLocked.toggle()}){
              Image(systemName: (layer.isLocked ? "lock":"lock.open")).font(.system(size: iconSize/1.25))
            }.buttonStyle(PlainButtonStyle())
            
            Button(action:{layer.isVisible.toggle()}){
              Image(systemName: (layer.isVisible ? "eye":"eye.slash"))
                .font(.system(size: iconSize/1.5))
            }.buttonStyle(PlainButtonStyle())
          }.listRowBackground(layer.isActive ? .gray.opacity(0.3) : Color.clear)
          //          }
        }.listStyle(.plain)
        
        if isLayerActive(), let activeIndex = getActiveLayerIndex(), activeIndex >= 0 {
          VStack(alignment: .leading,spacing: 5) {
            HStack{
              Spacer()
              //              Button(action:{deleteAlertVisible = true}){
              //                Image(systemName: "trash")
              //                  .foregroundStyle(.red)
              //                  .font(.system(size: iconSize/1.3))
              //              }.alert("Are you sure you want to delete the layer? This action is irreversible", isPresented: $deleteAlertVisible){
              //                Button("Delete", role:.destructive) {
              //                  deleteActiveLayer()
              //                }
              //              }
            }.padding(.trailing,7)
            
            HStack(spacing:5){
              TextField("",
                        text: Binding(
                          get: {
                            layers[activeIndex].name
                          },
                          set: { value in
                            layers[activeIndex].name = value
                          })
              )
              .padding(5)
              .background(.white).foregroundStyle(.black)
            }
            .padding(.leading,5)
            .padding(.trailing,5)
            
            HStack(spacing: 5){
              Text("Opacity")
              Slider(
                value: Binding(get: {layers[activeIndex].opacity}, set: { value in
                  layers[activeIndex].opacity = value
                }),
                in: 0...1
              )
              Text("\(Int(layers[activeIndex].opacity*100))%")
            }.padding(.leading,5).padding(.trailing,5)
            
          }
          .frame(maxWidth: .infinity)
        }
        Rectangle().frame(maxHeight: 50).foregroundStyle(.clear)
        
      }
      .foregroundColor(.white)
      .background(.black.opacity(0.85))
      
      if isSidebarVisible{
        Rectangle()
          .foregroundColor(.clear)
          .frame(maxWidth: 100, maxHeight: .infinity)
          .contentShape(Rectangle())
        
          .onTapGesture {
            isSidebarVisible.toggle()
          }.transition(.move(edge: .leading))
      }
      
    }.background(.black.opacity(0.5))
    
  }
}
