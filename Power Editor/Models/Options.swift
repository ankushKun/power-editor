//
//  Options.swift
//  Power Editor
//
//  Created by Ankush Singh on 21/12/24.
//

import SwiftUI

enum Tool: String,CaseIterable {
  case move, rotate
  
  var icon: String {
    switch self {
      case .move: return "arrow.up.and.down.and.arrow.left.and.right"
      case .rotate: return "rotate.right"
    }
  }
}

class OptionsModel: ObservableObject {
  @Published var maintainAspectRatio: Bool = true
  @Published var activeTool: Tool = .move
}
