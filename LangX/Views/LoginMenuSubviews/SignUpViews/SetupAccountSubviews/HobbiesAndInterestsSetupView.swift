//
//  HobbiesAndInterestsSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 10/12/2023.
//

import SwiftUI

struct HobbiesAndInterestsSetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var activeAlert: ActiveAlert?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    private var hobbiesAndInterestsCharacterCount: Int {
        setupViewModel.bio.count
    }

    private var areHobbiesAndInterestsWithinCharacterLimit: Bool {
        hobbiesAndInterestsCharacterCount <= 200 // Assuming a limit of 200 characters
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
            Text(NSLocalizedString("Ask-Hobbies-Interests", comment: "Ask hobbies and interests"))
                .font(.title)
                .padding(.bottom, 5)
            
            Text(NSLocalizedString("Hobbies-Interests-Placeholder", comment: "Hobbies and interests placeholder"))
                .font(.subheadline)
                .padding()
            
            HStack {
                Text(NSLocalizedString("Hobbies-Interests-Label", comment: "Hobbies and interests label"))
                    .font(.subheadline)
                    .padding(.leading)
                    .bold()
                
                Spacer()
                
                Text("\(hobbiesAndInterestsCharacterCount)/200")
                    .font(.subheadline)
                    .foregroundColor(areHobbiesAndInterestsWithinCharacterLimit ? .green : .red)
                    .padding(.trailing)
                    .animation(nil)
            }
            
            TextEditor(text: $setupViewModel.hobbiesAndInterests)
                .frame(height: 180)
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
                
                NavigationLink(destination: BioSetupView(setupViewModel: setupViewModel)) {
                    Text(NSLocalizedString("Next-Button", comment: "Next-Button"))
                    Image(systemName: "arrow.right")
                }
                .buttonStyle()
                .frame(width: 120)
                .disabled(hobbiesAndInterestsCharacterCount > 200)

            
            }
            .padding()
        }
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
            )
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        .navigationBarHidden(true)
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


