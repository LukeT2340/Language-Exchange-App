//
//  LoginMenuButtonModifier.swift
//  LangLeap
//
//  Created by Luke Thompson on 16/11/2023.
//

import SwiftUI

// Custom Button Modifier
struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, maxWidth: 280)
            .padding()
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
            .shadow(color: .black.opacity(0.5), radius: 4, x: -2, y: -2) // Added contrasting shadow
            .background(Color(red: 25 / 255, green: 20 / 255, blue: 61 / 255))
            .cornerRadius(40)
            .font(.body)
    }
}


// Extension to easily apply the modifier
extension View {
    func buttonStyle() -> some View {
        self.modifier(ButtonModifier())
    }
}
