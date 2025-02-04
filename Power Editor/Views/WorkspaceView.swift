//
//  WorkspaceView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//

import SwiftUI
import CoreGraphics

private extension View {
  func calculateRotationAngle(layerCenter: CGPoint, currentPoint: CGPoint) -> Double {
    let deltaX = currentPoint.x - layerCenter.x
    let deltaY = currentPoint.y - layerCenter.y
    let angle = atan2(deltaX, -deltaY) * (180 / .pi)
    return angle >= 0 ? angle : angle + 360
  }
  
  func rotatePoint(point: CGPoint, around center: CGPoint, angle: Double) -> CGPoint {
    let angleInRadians = angle * .pi / 180
    let translatedX = point.x - center.x
    let translatedY = point.y - center.y
    let rotatedX = translatedX * cos(angleInRadians) - translatedY * sin(angleInRadians)
    let rotatedY = translatedX * sin(angleInRadians) + translatedY * cos(angleInRadians)
    return CGPoint(x: rotatedX + center.x, y: rotatedY + center.y)
  }
}

struct WorkspaceView: View {
  @Binding var layers: [Layer]
  @EnvironmentObject var options: OptionsModel
  
  @State private var initialPosition: CGPoint = .zero
  @State private var initialSize: CGSize = .zero 
  @State private var initialRotation: Double = .zero
  @State private var startAngle: Double = .zero
  
  // Constants for transform controls
  private let controlSize: CGFloat = 16
  private let controlBorderWidth: CGFloat = 2
  private let minLayerSize: CGFloat = 20
  
  var screenWidth: CGFloat { UIScreen.main.bounds.width }
  
  // Scale factor based on canvas size
  var scaleFactor: CGFloat {
    screenWidth / options.canvasSize.width
  }
  
  // Actual control size accounting for canvas scale
  var adjustedControlSize: CGFloat {
    controlSize / scaleFactor
  }
  
  func deactivateLayers() {
    layers.enumerated().forEach { index, _ in
      layers[index].isActive = false
    }
  }
  
  func calculateRotationAngle(layerCenter: CGPoint, currentPoint: CGPoint) -> Double {
    let deltaX = currentPoint.x - layerCenter.x
    let deltaY = currentPoint.y - layerCenter.y
    let angle = atan2(deltaX, -deltaY) * (180 / .pi)
    return angle >= 0 ? angle : angle + 360
  }
  
  func rotatePoint(point: CGPoint, around center: CGPoint, angle: Double) -> CGPoint {
    let angleInRadians = angle * .pi / 180
    let translatedX = point.x - center.x
    let translatedY = point.y - center.y
    let rotatedX = translatedX * cos(angleInRadians) - translatedY * sin(angleInRadians)
    let rotatedY = translatedX * sin(angleInRadians) + translatedY * cos(angleInRadians)
    return CGPoint(x: rotatedX + center.x, y: rotatedY + center.y)
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
        ) { index, _ in
          LayerView(
            layer: layers[index],
            index: index,
            layers: $layers,
            initialPosition: $initialPosition,
            initialSize: $initialSize,
            initialRotation: $initialRotation,
            startAngle: $startAngle,
            controlSize: adjustedControlSize
          )
          .environmentObject(options)
        }
      }
      .contentShape(Rectangle())
      .background(.white)
      .frame(width: options.canvasSize.width, height: options.canvasSize.height)
      .frame(
        minWidth: screenWidth,
        idealWidth: screenWidth,
        maxWidth: screenWidth,
        minHeight: screenWidth,
        idealHeight: screenWidth,
        maxHeight: screenWidth
      )
      .scaleEffect(scaleFactor)
      .onTapGesture { deactivateLayers() }
      .zIndex(1)
      
      Rectangle()
        .onTapGesture { deactivateLayers() }
        .foregroundStyle(.gray)
        .zIndex(0)
    }
    .background(.gray)
  }
}

// MARK: - Layer View
private struct LayerView: View {
  let layer: Layer
  let index: Int
  @Binding var layers: [Layer]
  @Binding var initialPosition: CGPoint
  @Binding var initialSize: CGSize
  @Binding var initialRotation: Double
  @Binding var startAngle: Double
  let controlSize: CGFloat
  
  @EnvironmentObject var options: OptionsModel
  
  private var layerCenter: CGPoint {
    CGPoint(
      x: layer.position.x + layer.size.width / 2,
      y: layer.position.y + layer.size.height / 2
    )
  }
  
  var body: some View {
    LayerContentView(layer: layer)
      .gesture(tapGesture)
      .highPriorityGesture(dragGesture)
      .overlay(
        ZStack {
          if layer.isActive && !layer.isLocked {
            // Selection border
            Rectangle()
              .stroke(.blue, lineWidth: 1)
              .frame(width: layer.size.width, height: layer.size.height)
              .rotationEffect(.degrees(layer.rotation))
              .position(layerCenter)
            
            // Transform control
            TransformControl(
              layer: layer,
              controlSize: controlSize,
              onDrag: handleTransformDrag
            )
          }
        }
      )
  }
  
  private var tapGesture: some Gesture {
    TapGesture()
      .onEnded {
        guard !layer.isLocked else { return }
        let activeIndex = layers.firstIndex { $0.id == layer.id }!
        layers.enumerated().forEach { idx, _ in
          layers[idx].isActive = idx == activeIndex
        }
      }
  }
  
  private var dragGesture: some Gesture {
    DragGesture(minimumDistance: 1)
      .onChanged { value in
        guard !layer.isLocked && layer.isActive else { return }
        if initialPosition == .zero {
          initialPosition = layer.position
        }
        layers[index].position.x = initialPosition.x - value.startLocation.x + value.location.x
        layers[index].position.y = initialPosition.y - value.startLocation.y + value.location.y
      }
      .onEnded { _ in
        initialPosition = .zero
      }
  }
  
  private func handleTransformDrag(_ value: DragGesture.Value) {
    switch options.activeTool {
    case .move:
      handleResizeDrag(value)
    case .rotate:
      handleRotateDrag(value)
    }
  }
  
  private func handleResizeDrag(_ value: DragGesture.Value) {
    if initialSize == .zero {
      initialSize = layer.size
    }
    
    let dragDistX = value.location.x - value.startLocation.x
    let dragDistY = value.location.y - value.startLocation.y
    
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
  }
  
  private func handleRotateDrag(_ value: DragGesture.Value) {
    if startAngle == 0 {
      startAngle = calculateRotationAngle(
        layerCenter: layerCenter,
        currentPoint: value.startLocation
      )
      initialRotation = layer.rotation
    }
    
    let currentAngle = calculateRotationAngle(
      layerCenter: layerCenter,
      currentPoint: value.location
    )
    
    var angleDiff = currentAngle - startAngle
    
    if angleDiff > 180 {
      angleDiff -= 360
    } else if angleDiff < -180 {
      angleDiff += 360
    }
    
    layers[index].rotation = initialRotation + angleDiff
  }
}

// MARK: - Transform Control
private struct TransformControl: View {
  let layer: Layer
  let controlSize: CGFloat
  let onDrag: (DragGesture.Value) -> Void
  
  @EnvironmentObject var options: OptionsModel
  
  private var cornerPoint: CGPoint {
    let center = CGPoint(
      x: layer.position.x + layer.size.width / 2,
      y: layer.position.y + layer.size.height / 2
    )
    
    let corner = CGPoint(
      x: layer.position.x + layer.size.width,
      y: layer.position.y + layer.size.height
    )
    
    return rotatePoint(
      point: corner,
      around: center,
      angle: layer.rotation
    )
  }
  
  var body: some View {
    Group {
      switch options.activeTool {
      case .move:
        Rectangle()
          .fill(.white.opacity(0.9))
          .border(.blue, width: 2)
      case .rotate:
        Image(systemName: "arrow.trianglepath.2.circle.fill")
          .font(.system(size: controlSize * 0.8))
          .foregroundColor(.blue)
          .background(Circle().fill(.white.opacity(0.9)))
      }
    }
    .frame(width: controlSize, height: controlSize)
    .position(cornerPoint)
    .highPriorityGesture(
      DragGesture(minimumDistance: 1)
        .onChanged(onDrag)
        .onEnded { _ in }
    )
  }
}
