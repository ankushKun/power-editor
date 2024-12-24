//
//  ToastView.swift
//  Power Editor
//
//  Created by Ankush Singh on 25/12/24.
//

import SwiftUI


struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.5))
            .shadow(radius: 5)
            .foregroundColor(.white)
            .cornerRadius(8)
            .transition(.opacity)
    }
}
