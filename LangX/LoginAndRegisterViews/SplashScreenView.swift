//
//  SplashScreenView.swift
//  Tandy
//
//  Created by Luke Thompson on 26/11/2023.
//

import SwiftUI

// Shown when app opens / things are loading
struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Spacer()
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 180)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.9), Color("Background1").opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
