//
//  SexSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 9/12/2023.
//

import SwiftUI

struct SexSetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var activeAlert: ActiveAlert?
    @State private var errorMessage: String = ""
    @State private var selectedSex: String = NSLocalizedString("Male", comment: "Sex Option") // Default value
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        VStack {
            HStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .onAppear() {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isAnimating.toggle()
                        }
                    }
                    .frame(width: 70)
                Spacer()
            }
            
            Text(NSLocalizedString("Ask-Sex", comment: "Ask sex")) // Label text
                .font(.title)
                .padding(.bottom, 5) // Optional: Adjust padding as needed
            
            // Picker for Sex
            Picker(NSLocalizedString("Sex", comment: "Sex"), selection: $selectedSex) {
                ForEach(setupViewModel.localizedSexOptions, id: \.self) { localizedOption in
                    Text(localizedOption).tag(localizedOption)
                }
            }
            .onChange(of: selectedSex) { newValue in
                setupViewModel.selectSex(localizedSelection: newValue)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Spacer()
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left") // System-provided name for a left-pointing arrow
                        Text(NSLocalizedString("Back-Button", comment: "Back button"))
                    }
                }
                .buttonStyle() // Apply any custom button style you have
                .frame(width: 120)
                Spacer()
                // Navigation Link
                NavigationLink(destination: UsernameSetupView(setupViewModel: setupViewModel)) {
                    HStack {
                        Text(NSLocalizedString("Next-Button", comment: "Next button"))
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle()
                .frame(width: 120)
            }
            .padding()
        }
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        .navigationBarHidden(true)
    }
}

