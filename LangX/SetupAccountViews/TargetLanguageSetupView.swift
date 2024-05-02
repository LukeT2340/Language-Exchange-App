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
    @State private var showLogoutAlert = false
    @State private var showAlert = false
    @State private var navigateToNextView = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack  {
            navBar
            Text(LocalizedStringKey("Ask-Target-Languages-Text"))
                .font(.system(size: 20))
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(radius: 6)
                .padding(.top, 10)
                .padding(.horizontal)
            languagesScrollView
            navigationButtons

        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .alert(isPresented: $showAlert) {
            if showLogoutAlert {
                return Alert(
                    title: Text(LocalizedStringKey("Confirm-Logout-Alert")),
                    message: Text(LocalizedStringKey("Ask-Logout")),
                    primaryButton: .destructive(Text(LocalizedStringKey("Logout-Button"))) {
                        authManager.signOut()
                    },
                    secondaryButton: .cancel() {
                        showLogoutAlert = false
                    }
                )
            } else {
                return Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Alert")),
                    message: Text(NSLocalizedString("Error: Select Target Language", comment: "Please select at least one language to learn.")),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationBarHidden(true)
    }
    
    private var navBar: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
                .background(.ultraThinMaterial.opacity(0.6))
                .frame(height: 60)
            
            Button(action: {
                self.showLogoutAlert.toggle()
                self.showAlert.toggle()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "escape")
                    if !authManager.isLoggingOut {
                        Text(LocalizedStringKey("Logout"))
                    } else {
                        LoadingView()
                    }
                }
                .padding(8)
                .background(.white)
                .cornerRadius(4)
                .font(.system(size: 14))
                .foregroundColor(Color("AccentColor"))
                .padding(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(LocalizedStringKey("Language-Goals"))
                .font(.system(size: 22))
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .shadow(radius: 5)
        
    }
    
    private var languagesScrollView: some View {
        ScrollView(showsIndicators: true) {
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
        .padding(.horizontal)
        .shadow(radius: 2)
    }
    
    private var navigationButtons: some View {
        HStack {
            Spacer()
            NavigationLink(destination: NativeLanguageSetupView(setupAccountModel: setupAccountModel), isActive: $navigateToNextView) {
                  EmptyView()
              }
            Button(action: {
                if setupAccountModel.userObject.targetLanguages.isEmpty {
                    showAlert = true
                } else {
                    navigateToNextView = true
                }
            }) {
                HStack {
                    Text(NSLocalizedString("Next-Button", comment: "Next button"))
                    Image(systemName: "arrow.right")
                        .bold()
                }
            }
            .buttonStyle()
            .frame(width: 120)

        }
        .padding()
    }
}

struct TargetLanguageSetupView_Previews: PreviewProvider {
    static var previews: some View {
        TargetLanguageSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
