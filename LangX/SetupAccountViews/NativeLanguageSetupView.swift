//
//  NativeLanguageSetupView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct NativeLanguageSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var showAlert = false
    @State private var navigateToNextView = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            navBar
            Text(LocalizedStringKey("Ask-Native-Languages-Text"))
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
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarBackButtonHidden()
        .onAppear {
            setupAccountModel.removeDuplicateLanguages()
        }
    }
    
    private var navBar: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
                .background(.ultraThinMaterial.opacity(0.6))
                .frame(height: 60)
            
            Text(LocalizedStringKey("Language-Goals"))
                .font(.system(size: 22))
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .shadow(radius: 10)
    }
    
    private var languagesScrollView: some View {
        ScrollView {
            VStack {
                ForEach(setupAccountModel.localizedLanguages.filter { languageInfo in
                    // Only show languages that are not in languagesToLearn
                    setupAccountModel.userObject.targetLanguages[languageInfo.identifier] == nil
                }, id: \.identifier) { languageInfo in
                    NativeLanguageSelectableRow(
                        language: languageInfo.name,
                        flagImageName: languageInfo.flag,
                        action: {
                            // This closure is called when a row is tapped
                            if let index = setupAccountModel.userObject.nativeLanguages.firstIndex(of: languageInfo.identifier) {
                                setupAccountModel.userObject.nativeLanguages.remove(at: index) // Deselect
                            } else {
                                setupAccountModel.userObject.nativeLanguages.append(languageInfo.identifier) // Select
                            }
                        },
                        isSelected: setupAccountModel.userObject.nativeLanguages.contains(languageInfo.identifier)
                    )
                }
            }
        }
        .padding(.horizontal)
        .shadow(radius: 2)
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
            NavigationLink(destination: ProfileInformationSetupView(setupAccountModel: setupAccountModel), isActive: $navigateToNextView) {
                EmptyView()
            }
            Button(action: {
                if setupAccountModel.userObject.nativeLanguages.isEmpty {
                    showAlert = true
                } else {
                    navigateToNextView = true  
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
                    title: Text(NSLocalizedString("Error-Alert", comment: "Error alert")),
                    message: Text(NSLocalizedString("No-Mother-Languages-Selected", comment: "No mother languages selected")),
                    dismissButton: .default(Text("OK"))
                )
            }

        }
        .padding()
    }
}

struct NativeLanguageSetupView_Previews: PreviewProvider {
    static var previews: some View {
        NativeLanguageSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
