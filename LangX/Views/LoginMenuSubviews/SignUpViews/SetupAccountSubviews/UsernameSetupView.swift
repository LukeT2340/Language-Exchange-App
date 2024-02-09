//
//  UsernameSetupView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

enum ActiveAlert: Identifiable {
    case logoutConfirmation, inputError
    
    var id: Int {
        hashValue
    }
}

struct UsernameSetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showingImagePicker = false
    @State private var activeAlert: ActiveAlert?
    @State private var inputImage: UIImage?
    @State private var profileImage: Image?
    @State private var isAnimating = false

    @State private var errorMessage: String = ""
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
            Text(NSLocalizedString("Setup Username and Choose Profile Picture", comment: "Set up your username and profile picture."))
                .font(.title)
                .foregroundColor(colorScheme == .dark ? .gray : .black)
                .padding(.bottom, 30)
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .cornerRadius(5)
                
                if let profileImage = profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(5)
                        .clipShape(Rectangle())
                } else {
                    Text(NSLocalizedString("Select Profile Picture", comment: "Select Profile Picture"))
                        .foregroundColor(.gray)
                        .frame(width: 90, height: 90)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .onTapGesture {
                showingImagePicker = true
            }
            
            // Username TextField
            TextField("Username", text: $setupViewModel.username)
                .padding()
                .background(Color.blue.opacity(0.2)) // Match the button color
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
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
                NavigationLink(destination: TargetLanguageSetupView(setupViewModel: setupViewModel)) {
                    HStack {
                        Text(NSLocalizedString("Next-Button", comment: "Next button"))
                        Image(systemName: "arrow.right") // System name for right arrow icon
                    }
                }
                .buttonStyle()
                .frame(width: 120)
                .disabled(setupViewModel.username.isEmpty || profileImage == nil || setupViewModel.username.replacingOccurrences(of: " ", with: "").count < 4)
                .simultaneousGesture(TapGesture().onEnded {
                    validateInput()
                })
            }
            .simultaneousGesture(TapGesture().onEnded {
                setupViewModel.profileImage = inputImage // Set the selected image in the ViewModel
            })
            .padding()
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .logoutConfirmation:
                return Alert(
                    title: Text(NSLocalizedString("Confirm Logout", comment: "Confirm logout")),
                    message: Text(NSLocalizedString("Are you sure you want to log out?", comment: "Are you sure you want to log out?")),
                    primaryButton: .destructive(Text(NSLocalizedString("Logout", comment: "Logout"))) {
                        authManager.logout() { _, _ in}
                    },
                    secondaryButton: .cancel()
                )
            case .inputError:
                return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(isPresented: $showingImagePicker, selectedImage: $inputImage)
        }
        .onChange(of: inputImage) { _ in
            loadImage()
        }
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
            )
        .navigationBarHidden(true)
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        profileImage = Image(uiImage: inputImage)
    }
    
    func validateInput() {
        let trimmedUsername = setupViewModel.username.replacingOccurrences(of: " ", with: "")

        if trimmedUsername.isEmpty {
            errorMessage = NSLocalizedString("Error: Enter Username", comment: "Error: Enter Username")
            activeAlert = .inputError
            return
        }

        if trimmedUsername.count < 4 {
            errorMessage = "用户名太短，请输入四个字母以上的用户名" // "The username is too short, please enter a username with more than 4 characters."
            activeAlert = .inputError
            return
        }
        
        let allowedCharacterSet = CharacterSet.letters // Only letters are allowed
        if !trimmedUsername.unicodeScalars.allSatisfy(allowedCharacterSet.contains) {
            errorMessage = NSLocalizedString("Error: Invalid Username Characters", comment: "Error: Username contains invalid characters")
            activeAlert = .inputError
            return
        }
        
        let spacePattern = " {2,}"
        if let _ = trimmedUsername.range(of: spacePattern, options: .regularExpression) {
            errorMessage = NSLocalizedString("Error: Successive Spaces", comment: "Error: Username has successive spaces")
            activeAlert = .inputError
            return
        }
        
        if profileImage == nil {
            errorMessage = NSLocalizedString("Error: Enter Profile Picture", comment: "Error: Enter Profile Picture")
            activeAlert = .inputError
            return
        }

        // If validation passes, assign the trimmed username back to the view model
        setupViewModel.username = setupViewModel.username.trimmingCharacters(in: .whitespacesAndNewlines)
        setupViewModel.profileImage = inputImage
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
