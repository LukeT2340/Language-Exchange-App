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
            .frame(maxWidth: 300, maxHeight: 50)
            .foregroundColor(.white)
            .background(Color(red: 51/255, green: 200/255, blue: 255/255))
            .cornerRadius(8)
            .font(.body)
    
    }
}


// Extension to easily apply the modifier
extension View {
    func buttonStyle() -> some View {
        self.modifier(ButtonModifier())
    }
}
