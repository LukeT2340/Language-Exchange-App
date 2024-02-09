//
//  NativeLanguageSetupView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct NativeLanguageSetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var showAlert = false
    @State private var navigateToNextView = false
    
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
            Text(NSLocalizedString("Select-Native-Languages", comment: "Select native languages"))
                .font(.largeTitle)
            Spacer()
            ScrollView {
                VStack {
                    ForEach(setupViewModel.localizedLanguages.filter { languageInfo in
                        // Only show languages that are not in languagesToLearn
                        setupViewModel.languagesToLearn[languageInfo.identifier] == nil
                    }, id: \.identifier) { languageInfo in
                        MotherLanguageSelectableRow(
                            language: languageInfo.name,
                            flagImageName: languageInfo.flag,
                            action: {
                                // This closure is called when a row is tapped
                                if let index = setupViewModel.nativeLanguages.firstIndex(of: languageInfo.identifier) {
                                    setupViewModel.nativeLanguages.remove(at: index) // Deselect
                                } else {
                                    setupViewModel.nativeLanguages.append(languageInfo.identifier) // Select
                                }
                            },
                            isSelected: setupViewModel.nativeLanguages.contains(languageInfo.identifier)
                        )
                    }
                }
            }
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
                NavigationLink(destination: LanguageGoalsSetupView(setupViewModel: setupViewModel), isActive: $navigateToNextView) {
                    EmptyView()
                }
                Button(action: {
                    if setupViewModel.nativeLanguages.isEmpty {
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
                        title: Text(NSLocalizedString("Error: No Languages Selected", comment: "No Languages Selected")),
                        message: Text(NSLocalizedString("Please select at least one mother language", comment: "Please select at least one mother language")),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()
                
            }
        }
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        .navigationBarHidden(true)
    }
}

struct MotherLanguageSelectableRow: View {
    let language: String
    let flagImageName: String
    var action: () -> Void
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(language)
                .font(.title)
            Spacer()
            Image(flagImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
        .contentShape(Rectangle()) // Ensures the tap gesture covers the whole area
        .onTapGesture {
            action()
        }
    }
}
