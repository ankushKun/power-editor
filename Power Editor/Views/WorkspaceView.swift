//
//  WorkspaceView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//

import SwiftUI
import CoreGraphics

struct WorkspaceView: View {
  @Binding var layers: [Layer]
  @EnvironmentObject var options: OptionsModel
  
  @State var initialPosition: CGPoint = .zero
  @State var initialSize: CGSize = .zero
  @State var initialRotation: Double = .zero
  @State var startAngle: Double = .zero
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  func deactivateLayers() {
    layers.enumerated().forEach { index, _ in
      layers[index].isActive = false
    }
  }
  
  func calculateRotationAngle(layerCenter: CGPoint, currentPoint: CGPoint) -> Double {
    // Calculate the angle between the vertical line from the center and the line to the current point
    let deltaX = currentPoint.x - layerCenter.x
    let deltaY = currentPoint.y - layerCenter.y
    
    // Calculate angle in radians and convert to degrees
    let angle = atan2(deltaX, -deltaY) * (180 / .pi)
    
    // Normalize angle to 0-360 range
    return angle >= 0 ? angle : angle + 360
  }
  
  func rotatePoint(point: CGPoint, around center: CGPoint, angle: Double) -> CGPoint {
    // Convert angle to radians
    let angleInRadians = angle * .pi / 180
    
    // Translate point to origin
    let translatedX = point.x - center.x
    let translatedY = point.y - center.y
    
    // Rotate point
    let rotatedX = translatedX * cos(angleInRadians) - translatedY * sin(angleInRadians)
    let rotatedY = translatedX * sin(angleInRadians) + translatedY * cos(angleInRadians)
    
    // Translate back
    return CGPoint(
      x: rotatedX + center.x,
      y: rotatedY + center.y
    )
  }
  
  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .onTapGesture { deactivateLayers() }
        .foregroundStyle(.gray)
        .zIndex(0)
      
      ZStack(alignment: .center) {
        ForEach(
          Array(layers.enumerated().filter { $0.element.isVisible }).reversed(),
          id: \.element.id
        ) {
          index,
          _ in
          LayerContentView(layer: layers[index])
            .gesture(
              TapGesture()
                .onEnded {
                  if (layers[index].isLocked) {return}
                  let activeIndex = layers.firstIndex { $0.id == layers[index].id }!
                  layers.enumerated().forEach { idx, _ in
                    layers[idx].isActive = idx == activeIndex
                  }
                }
            )
            .highPriorityGesture(
              DragGesture(minimumDistance: 1)
                .onChanged { value in
                  if (layers[index].isLocked) {return}
                  if layers[index].isActive {
                    if initialPosition == .zero {
                      initialPosition = layers[index].position
                    }
                    layers[index].position.x = initialPosition.x - value.startLocation.x + value.location.x
                    layers[index].position.y = initialPosition.y - value.startLocation.y + value.location.y
                  }
                }
                .onEnded { _ in
                  initialPosition = .zero
                }
            )
            .overlay(
              ZStack {
                if layers[index].isActive && !layers[index].isLocked {
                  Rectangle()
                    .foregroundStyle(.clear).border(.blue)
                    .frame(
                      width: layers[index].size.width,
                      height: layers[index].size.height
                    )
                    .rotationEffect(.degrees(layers[index].rotation))
                    .position(
                      x: layers[index].position.x + layers[index].size.width / 2,
                      y: layers[index].position.y + layers[index].size.height / 2
                    )
                  //
                  let layerCenter = CGPoint(
                    x: layers[index].position.x + layers[index].size.width / 2,
                    y: layers[index].position.y + layers[index].size.height / 2
                  )
                  
                  let cornerPoint = CGPoint(
                    x: layers[index].position.x + layers[index].size.width,
                    y: layers[index].position.y + layers[index].size.height
                  )
                  
                  let rotatedCorner = rotatePoint(
                    point: cornerPoint,
                    around: layerCenter,
                    angle: layers[index].rotation
                  )
                  // tooltip icon
                  Group{
                    switch options.activeTool {
                      case .move:
                        Rectangle()
                          .foregroundStyle(.white.opacity(0.9))
                          .border(.blue)
                      case .rotate:
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                          .foregroundColor(.blue)
                          .background(.white.opacity(0.9))
                          .cornerRadius(10)
                    }
                  }
                  .frame(width: 15, height: 15)
                  // this rotates in place instead of moving to the corner of rotated item
                  .rotationEffect(.degrees(layers[index].rotation))
                  .position(x: rotatedCorner.x, y: rotatedCorner.y)
                  .highPriorityGesture(
                    DragGesture(minimumDistance: 1)
                      .onChanged { value in
                        let dragDistX = value.location.x - value.startLocation.x
                        let dragDistY = value.location.y - value.startLocation.y
                        
                        switch options.activeTool {
                          case .move:
                            
                            if initialSize == .zero {
                              initialSize = layers[index].size
                            }
                            
                            if options.maintainAspectRatio {
                              let aspectRatio = initialSize.width / initialSize.height
                              let scalingFactor = max(dragDistX, dragDistY)
                              
                              let newWidth = max(20, initialSize.width + scalingFactor)
                              let newHeight = max(20, newWidth / aspectRatio)
                              
                              layers[index].size = CGSize(width: newWidth, height: newHeight)
                            } else {
                              layers[index].size = CGSize(
                                width: max(20, initialSize.width + dragDistX),
                                height: max(20, initialSize.height + dragDistY)
                              )
                            }
                          case .rotate:
                            // calculate degree of rotation based on drag distance on x and y axis
                            // add code here
                            let layerCenter = CGPoint(
                              x: layers[index].position.x + layers[index].size.width / 2,
                              y: layers[index].position.y + layers[index].size.height / 2
                            )
                            
                            if startAngle == 0 {
                              startAngle = calculateRotationAngle(
                                layerCenter: layerCenter,
                                currentPoint: value.startLocation
                              )
                              initialRotation = layers[index].rotation
                            }
                            
                            let currentAngle = calculateRotationAngle(
                              layerCenter: layerCenter,
                              currentPoint: value.location
                            )
                            
                            // Calculate the difference in angle and add to initial rotation
                            var angleDiff = currentAngle - startAngle
                            
                            // Ensure smooth rotation when crossing 0/360 degrees
                            if angleDiff > 180 {
                              angleDiff -= 360
                            } else if angleDiff < -180 {
                              angleDiff += 360
                            }
                            
                            // Update layer rotation
                            layers[index].rotation = initialRotation + angleDiff
                        }
                        
                      }.onEnded { _ in
                        initialSize = .zero
                        initialRotation = .zero
                        startAngle = .zero
                      }
                  )
                }
              }
            )
        }
      }
      .contentShape(Rectangle())
      .background(.white)
      .frame(width: screenWidth, height: screenWidth)
      .frame(minWidth: screenWidth, idealWidth: screenWidth, maxWidth: screenWidth, minHeight: screenWidth, idealHeight: screenWidth, maxHeight: screenWidth)
      .onTapGesture { deactivateLayers() }
      .zIndex(1)
      
      Rectangle()
        .onTapGesture { deactivateLayers() }
        .foregroundStyle(.gray)
        .zIndex(0)
    }
    .background(.gray)
  }
  
  // Extracted ZStack content for a specific layer
  public func layerContent(for index: Int) -> some View {
    ZStack {
      switch layers[index].content {
        case .color(let color):
          Rectangle().fill(color)
        case .image(let image):
          image.resizable()
        case .text(let text):
          Text(text)
            .font(.system(size: 20))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
      }
    }
    .frame(width: layers[index].size.width, height: layers[index].size.height)
    .position(
      x: layers[index].position.x + layers[index].size.width / 2,
      y: layers[index].position.y + layers[index].size.height / 2
    )
  }
}
