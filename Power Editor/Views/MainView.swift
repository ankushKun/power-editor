//
//  MainView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//


import SwiftUI

struct MainView: View {
  @State private var isSidebarVisible: Bool = false
  @State private var layers: [Layer] = [
    Layer(name: "Blue Layer",position: CGPoint(x:10,y:10), content: .color(.blue)),
    Layer(name: "Red Layer", position:CGPoint(x:280, y:280), content: .color(.red)),
    Layer(name: "Text Layer", content: .text("Hello, World!"))
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
