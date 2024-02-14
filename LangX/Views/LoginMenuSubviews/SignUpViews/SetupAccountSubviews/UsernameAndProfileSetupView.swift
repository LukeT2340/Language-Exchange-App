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

struct UserNameAndProfilePictureSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showingImagePicker = false
    @State private var activeAlert: ActiveAlert?
    @State private var isAnimating = false

    @State private var errorMessage: String = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var usernameIsValid = false
    @State private var checkingUsernameIsValid = false
    
    var validInput: Bool {
        if setupAccountModel.profileImage == nil {
            return false
        }
        
        let trimmedUsername = setupAccountModel.userObject.name.replacingOccurrences(of: " ", with: "")
        
        if trimmedUsername.isEmpty {
            return false
        }

        if trimmedUsername.count < 4 {
            return false
        }
        
        let allowedCharacterSet = CharacterSet.letters
        if !trimmedUsername.unicodeScalars.allSatisfy(allowedCharacterSet.contains) {
            return false
        }
        
        let spacePattern = " {2,}"
        if let _ = trimmedUsername.range(of: spacePattern, options: .regularExpression) {
            return false
        }
        return true
    }
    
    var body: some View {
        VStack {
            header
            profilePicture
            username
            Spacer()
            navigationButtons
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .inputError:
                return Alert(title: Text(LocalizedStringKey("Error-Alert")), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            default:
                return Alert(title: Text(LocalizedStringKey("Unknown-Error-Alert")))
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(isPresented: $showingImagePicker, selectedImage: $setupAccountModel.profileImage)
        }
        .padding()
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
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
    }
    
    @ViewBuilder
    private var header: some View {
        Text(LocalizedStringKey("Ask-User-For-Username-And-Profile-Picture-Text"))
            .font(.system(size: 30))
            .fontWeight(.medium)
    }
    
    private var profilePicture: some View {
        ZStack {
            if let profileImage = setupAccountModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipShape(Rectangle())
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
                    .transition(.scale)
            } else {
                Rectangle()
                    .fill(showingImagePicker ? Color.gray.opacity(0.03) : Color.accentColor.opacity(0.07))
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)

                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(Color.gray)
                        .font(.system(size: 50))
                    Text(LocalizedStringKey("Tap-To-Select-Image-Placeholder"))
                        .foregroundColor(Color.gray)
                        .font(.system(size: 16))
                        .padding(5)
                }
            }
        }
        .padding()
        .onTapGesture {
            showingImagePicker = true
        }
        .animation(.default, value: setupAccountModel.profileImage)
    }
    
    @ViewBuilder
    private var username: some View {
        HStack {
            TextField(LocalizedStringKey("Username-Placeholder"), text: $setupAccountModel.userObject.name)
            if checkingUsernameIsValid {
                LoadingView()
            } else if usernameIsValid {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.06))
        .frame(maxWidth: 350)
        .cornerRadius(15)
        .padding(.horizontal)
        .simultaneousGesture(TapGesture().onEnded {
            // This gesture will not interfere with the text field
        }
        )
        .onChange(of: setupAccountModel.userObject.name) { newValue in
            usernameIsValid = isUsernameValid(username: newValue)
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left") // System-provided name for a left-pointing arrow
                    Text(LocalizedStringKey("Back-Button"))
                }
            }
            .buttonStyle() // Apply any custom button style you have
            .frame(width: 120)
            Spacer()
            // Navigation Link
            NavigationLink(destination: TargetLanguageSetupView(setupAccountModel: setupAccountModel)) {
                HStack {
                    Text(LocalizedStringKey("Next-Button"))
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle()
            .frame(width: 120)
            .disabled(!validInput)
            .simultaneousGesture(TapGesture().onEnded {
                validateInput()
            })
        }
        .padding()
    }
    
    func validateInput() {
        if setupAccountModel.profileImage == nil {
            errorMessage = NSLocalizedString("Error: Enter Profile Picture", comment: "Error: Enter Profile Picture")
            activeAlert = .inputError
            return
        }
        
        let trimmedUsername = setupAccountModel.userObject.name.replacingOccurrences(of: " ", with: "")
        
        if trimmedUsername.isEmpty {
            errorMessage = NSLocalizedString("Error: Username Blank", comment: "Error: Username Blank")
            activeAlert = .inputError
            return
        }

        if trimmedUsername.count < 4 {
            errorMessage = NSLocalizedString("Error: Username Too Short", comment: "Error: Username Too Short")
            activeAlert = .inputError
            return
        }
        
        if trimmedUsername.count > 15 {
            errorMessage = NSLocalizedString("Error: Username Too Long", comment: "Error: Username Too Long")
            activeAlert = .inputError
            return
        }
        
        
        let allowedCharacterSet = CharacterSet.letters
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

        // If validation passes, assign the trimmed username back to the view model
        setupAccountModel.userObject.name = setupAccountModel.userObject.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func isUsernameValid(username: String) -> Bool {
        checkingUsernameIsValid = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            checkingUsernameIsValid = false
        }
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the username is empty
        guard !trimmedUsername.isEmpty else { return false }
        
        // Check the length of the username
        guard trimmedUsername.count >= 4 else { return false }
        
        // Check for allowed characters (adjust as needed)
        let allowedCharacterSet = CharacterSet.letters.union(CharacterSet(charactersIn: "_-"))
        guard trimmedUsername.unicodeScalars.allSatisfy(allowedCharacterSet.contains) else { return false }
        
        // Check for successive spaces (optional based on your needs)
        let spacePattern = " {2,}"
        if trimmedUsername.range(of: spacePattern, options: .regularExpression) != nil {
            return false
        }
        
        return true
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct UserNameAndProfilePictureSetupView_Previews: PreviewProvider {
    static var previews: some View {
        UserNameAndProfilePictureSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
