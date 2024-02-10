//
//  TargetLanguageSetupView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct TargetLanguageSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var showAlert = false
    @State private var navigateToNextView = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack (alignment: .center) {
            Text(LocalizedStringKey("Ask-Target-Languages-Text"))
                .font(.system(size: 18))
                .fontWeight(.light)
                .padding(.bottom)
            Spacer()
            languagesScrollView
            navigationButtons

        }
        .padding(.vertical)
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
    
    private var navigationBar: some View {
        HStack {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .hidden()
            
            Spacer()
            
            Text(LocalizedStringKey("Select-Target-Languages-Text"))
                .font(.system(size: 25))
                .fontWeight(.medium)
            Spacer()
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
        }
        .padding(.horizontal)
    }
    
    private var languagesScrollView: some View {
        ScrollView {
            VStack {
                ForEach(setupAccountModel.localizedLanguages, id: \.identifier) { languageInfo in
                    TargetLanguageSelectableRow(language: languageInfo.name, flagImageName: languageInfo.flag, fluencyLevel: $setupAccountModel.userObject.targetLanguages[languageInfo.identifier]) {
                        if let _ = setupAccountModel.userObject.targetLanguages[languageInfo.identifier] {
                            // Remove the language
                            setupAccountModel.userObject.targetLanguages[languageInfo.identifier] = nil
                        } else {
                            // Add with initial level
                            setupAccountModel.userObject.targetLanguages[languageInfo.identifier] = 1
                        }
                    }
                }
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left") // System-provided name for a left-pointing arrow
                    Text(NSLocalizedString("Back-Button", comment: "Back button"))
                }
            }
            .buttonStyle()
            .frame(width: 120)
            Spacer()
            NavigationLink(destination: NativeLanguageSetupView(setupAccountModel: setupAccountModel), isActive: $navigateToNextView) {
                  EmptyView()
              }
            Button(action: {
                if setupAccountModel.userObject.targetLanguages.isEmpty {
                    showAlert = true
                } else {
                    navigateToNextView = true  // Activate the NavigationLink
                }
            }) {
                HStack {
                    Text(NSLocalizedString("Next-Button", comment: "Next button"))
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle()
            .frame(width: 120)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Alert")),
                    message: Text(NSLocalizedString("Error: Select Target Language", comment: "Please select at least one language to learn.")),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.vertical)

        }
        .padding(.horizontal)
    }
}

struct TargetLanguageSetupView_Previews: PreviewProvider {
    static var previews: some View {
        TargetLanguageSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
