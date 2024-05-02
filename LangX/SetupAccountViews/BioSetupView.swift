//
//  BioSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 9/12/2023.
//


import SwiftUI

struct BioSetupView: View {
    @ObservedObject var setupViewModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var activeAlert: ActiveAlert?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    private var bioCharacterCount: Int {
        setupViewModel.userObject.bio.count
    }

    private var isBioWithinCharacterLimit: Bool {
        bioCharacterCount <= 200 // Assuming a limit of 200 characters
    }
    
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
            Text(NSLocalizedString("Ask-Bio", comment: "Ask bio"))
                .font(.title)
                .padding(.bottom, 5)
            
            Text(NSLocalizedString("Bio-Placeholder", comment: "Bio placeholder"))
                .font(.subheadline)
                .padding()
            
            HStack {
                Text(NSLocalizedString("Bio-Label", comment: "Bio"))
                    .font(.subheadline)
                    .padding(.leading)
                    .bold()
                
                Spacer()
                
                Text("\(bioCharacterCount)/200")
                    .font(.subheadline)
                    .foregroundColor(isBioWithinCharacterLimit ? .green : .red)
                    .padding(.trailing)
                    .animation(nil)
            }
            
            TextEditor(text: $setupViewModel.userObject.bio)
                .frame(height: 180)
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .cornerRadius(8)
                .padding(.bottom)
                .padding(.trailing)
                .padding(.leading)
            
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
                
                Button(action: {
                    Task {
                        let registrationSuccessful = await setupViewModel.createUserProfileData()
                    }
                }) {
                    if !setupViewModel.creatingUserProfile {
                        Text(NSLocalizedString("Complete-Setup-Button", comment: "Complete setup button"))
                    } else {
                        ProgressView()
                    }
                }
                .buttonStyle()
                .frame(width: 120)
                .disabled(bioCharacterCount > 200 || setupViewModel.creatingUserProfile)

            
            }
            .padding()
        }
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
            )
        .background(colorScheme == .light ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.95, green: 0.98, blue: 1.00), // Very light pastel blue
                            Color(red: 0.85, green: 0.90, blue: 0.95)  // Slightly deeper pastel blue
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ) : LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.18, green: 0.23, blue: 0.28), // Slightly lighter dark slate blue
                            Color(red: 0.28, green: 0.33, blue: 0.38)  // A bit lighter and softer slate blue
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
        )
        .navigationBarHidden(true)
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

