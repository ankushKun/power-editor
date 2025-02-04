//
//  MainView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI

let iconSize: CGFloat = 25
let initialCanvasSize: CGSize = CGSize(width: 1000, height: 1000)

struct MainView: View {
  @State private var isSidebarVisible: Bool = false
  @State private var layers: [Layer] = [
    Layer(name: "Red Layer",
          position: CGPoint(x: 10, y: 10),
          size: CGSize(width:initialCanvasSize.width/10,height:initialCanvasSize.height/10),
          content: .color(.red)
         ),
    Layer(
      name: "Text Layer", 
      position: CGPoint(x: initialCanvasSize.width/2 - initialCanvasSize.width/20, y: initialCanvasSize.height/2 - initialCanvasSize.height/20),
      size: CGSize(width: initialCanvasSize.width/10, height: initialCanvasSize.height/10),
      content: .text("💪 Power Editor")
    ),
    Layer(
      name: "Blue Layer",
      position: CGPoint(x: initialCanvasSize.width - initialCanvasSize.width/10, y: initialCanvasSize.height - initialCanvasSize.height/10),
      size: CGSize(width: initialCanvasSize.width/10, height: initialCanvasSize.height/10),
      content: .color(.blue)
    )
  ]
  
  
  var body: some View {
    ZStack(alignment: .leading) {
      // Main Content
      VStack(spacing: 0) {
        TopMenuView(layers:$layers,isSidebarVisible: $isSidebarVisible).zIndex(5)
        WorkspaceView(layers: $layers).zIndex(1)
        ToolbarView(layers:$layers).zIndex(5)
      }.background(.gray)
      
      // Sidebar
      if isSidebarVisible {
        SidebarView(isSidebarVisible: $isSidebarVisible, layers:$layers)
          .transition(.move(edge: .leading))
          .zIndex(10)
      }
    }
    .animation(.easeInOut, value: isSidebarVisible) // Smooth transition
  }
}
