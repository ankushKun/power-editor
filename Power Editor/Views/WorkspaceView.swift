//
//  WorkspaceView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI

struct WorkspaceView: View {
  @Binding var layers: [Layer]
  @State var initialPosition: CGPoint = .zero
  @State var initialSize: CGSize = .zero
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  func deactivateLayers(){
    layers.enumerated().forEach { index, _ in
      layers[index].isActive = false
    }
  }
  
  var body: some View {
    VStack(spacing: 0){
      Rectangle()
        .onTapGesture {deactivateLayers()}
        .foregroundStyle(.gray)
        .zIndex(0)
      
      ZStack(alignment: .center) {
        // Render each visible layer
        ForEach(
          Array(layers.enumerated().filter { $0.element.isVisible }).reversed(),
          id: \.element.id
        ) {
          index,
          _ in
          // Layer Item
          ZStack {
            switch layers[index].content {
              case .color(let color):
                Rectangle().fill(color)
              case .image(let image):
                image.resizable()
              case .text(let text):
                Text(text).font(.system(size: 20)).foregroundColor(.black).multilineTextAlignment(.center)
            }
          }
          //          .padding(2)
          //          .border(layers[index].isActive ? .blue : Color.clear)
          .frame(width: layers[index].size.width,height: layers[index].size.height)
          .position(
            x: layers[index].position.x + layers[index].size.width/2,
            y: layers[index].position.y + layers[index].size.height/2
          )
          .gesture(
            TapGesture()
              .onEnded {
                // keep only current layer active and the rest inactive
                let activeIndex = layers.firstIndex { $0.id == layers[index].id }!
                layers.enumerated().forEach { index, _ in
                  layers[index].isActive = index == activeIndex
                }
              }
          )
          .gesture(
            DragGesture()
              .onChanged { value in
                //                print(value)
                if layers[index].isActive {
                  if initialPosition == .zero {
                    initialPosition = layers[index].position
                  }
                  layers[index].position.x = initialPosition.x - value.startLocation.x + value.location.x
                  layers[index].position.y = initialPosition.y - value.startLocation.y + value.location.y
                }
              }
              .onEnded{value in
                initialPosition = .zero
              }
          )
          .overlay(
            ZStack{
              if layers[index].isActive {
                Rectangle()
                  .foregroundStyle(.clear).border(.blue)
                  .frame(
                    width: layers[index].size.width,
                    height: layers[index].size.height
                  )
                  .position(
                    x: layers[index].position.x + layers[index].size.width/2,
                    y: layers[index].position.y + layers[index].size.height/2
                  )
                Rectangle()
                  .border(.blue)
                  .frame(width: 15, height: 15)
                  .position(
                    x: layers[index].position.x + layers[index].size.width,
                    y: layers[index].position.y + layers[index].size.height
                  )
                  .gesture(
                    DragGesture().onChanged{value in
                      let dragDistX = value.location.x - value.startLocation.x
                      let dragDistY = value.location.y - value.startLocation.y
                      print(dragDistX, dragDistY)
                      
                      if initialSize == .zero {
                        initialSize = layers[index].size
                      }
                      
                      if layers[index].maintainAspectRatio {
                        // Calculate the scaling factor while maintaining aspect ratio
                        let aspectRatio = initialSize.width / initialSize.height
                        let scalingFactor = max(dragDistX, dragDistY)
                        
                        // Apply the scaling factor proportionally
                        let newWidth = max(20, initialSize.width + scalingFactor)
                        let newHeight = max(20, newWidth / aspectRatio)
                        
                        layers[index].size = CGSize(width: newWidth, height: newHeight)
                      }else{
                        
                        layers[index].size = CGSize(
                          width: max(20,initialSize.width + dragDistX),
                          height: max(20,initialSize.height + dragDistY)
                        )
                      }
                      
                    }.onEnded{value in
                      initialSize = .zero
                    }
                  )
              }
            })
          
          
        }
      }.background(.white)
        .frame(width:screenWidth,height:screenWidth)
        .onTapGesture {deactivateLayers()}
        .zIndex(1)
      
      Rectangle()
        .onTapGesture {deactivateLayers()}
        .foregroundStyle(.gray)
        .zIndex(0)
    }.background(.gray)
  }
}
