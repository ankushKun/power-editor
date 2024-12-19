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
  
  var body: some View {
    HStack{
      VStack(alignment: .leading) {
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
              
              Button(action:{
                layer.isVisible.toggle()
              }){
                if layer.isVisible {
                  Image(systemName: "eye").font(.system(size: iconSize/1.5))
                }else{
                  Image(systemName: "eye.slash").font(.system(size: iconSize/1.5))
                }
              }.buttonStyle(PlainButtonStyle())
            }.listRowBackground(layer.isActive ? .gray.opacity(0.3) : Color.clear)
//          }
        }.listStyle(.plain)
        
        HStack(alignment: .bottom) {
          
        }
        .padding(.bottom,14).padding(.leading,10)
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
