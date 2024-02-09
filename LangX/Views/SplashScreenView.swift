//
//  SplashScreenView.swift
//  Tandy
//
//  Created by Luke Thompson on 26/11/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Spacer()
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
            Text(NSLocalizedString("App-Name", comment: "App name"))
                .font(.system(size: 35, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            colorScheme == .dark ?
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.2, blue: 0.3), Color.gray]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.7, green: 0.9, blue: 1.0), Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
    }
}
