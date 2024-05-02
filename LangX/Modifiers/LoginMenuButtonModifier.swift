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
            .padding()
            .background(.white)
            .cornerRadius(20)
            .font(.system(size: 18))
            .foregroundColor(Color("AccentColor"))
            .lineLimit(1)
    }
}


// Extension to easily apply the modifier
extension View {
    func buttonStyle() -> some View {
        self.modifier(ButtonModifier())
    }
}
