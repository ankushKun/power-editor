//
//  ContentView.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
      MainView().environmentObject(OptionsModel())
    }
}

#Preview {
  ContentView()
}
