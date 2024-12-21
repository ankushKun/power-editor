//
//  Power_EditorApp.swift
//  Power Editor
//
//  Created by Ankush Singh on 18/12/24.
//

import SwiftUI

@main
struct PowerEditorApp: App {
     var body: some Scene {
       WindowGroup {
         MainView().environmentObject(OptionsModel())
       }
     }
}

#Preview {
  MainView().environmentObject(OptionsModel())
}
