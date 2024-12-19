//
//  TopMenuView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//
import SwiftUI

struct TopMenuView: View {
  @Binding var isSidebarVisible: Bool
  
    var body: some View {
        HStack {
          Button(action: {
            isSidebarVisible.toggle()
          }) {
            Label("Layers", systemImage: "square.3.layers.3d.top.filled")
              .font(.system(size: 20))
          }
          
          Spacer()
          Button(action:{}) {
              Label("Export", systemImage: "square.and.arrow.up")
              .font(.system(size: 20))
            }
        }
        .padding(10)
        .background(.black)
    }
}
