import SwiftUI

struct EmailSignUpView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isAgreeToTerms: Bool = false
    @State private var isAnimating = false
    @State private var activeAlert: Bool = false
    @State private var errorMessage = ""
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Bar with Back Button
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Spacer() // Spacer to push everything up
            
            VStack(spacing: 20) {
                Spacer()
                HStack {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .opacity(isAnimating ? 1.0 : 0.8)
                        .onAppear() {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                isAnimating.toggle()
                            }
                        }
                    
                    Text(NSLocalizedString("App-Name", comment: "App name"))
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary)
                }
                
                // Email
                TextField(NSLocalizedString("Email-Placeholder", comment: "Email placeholder"), text: $email)
                    .padding()
                    .background(Color.blue.opacity(0.2)) // Match the button color
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                
                // Password
                SecureField(NSLocalizedString("Password-Placeholder", comment: "Password placeholder"), text: $password)
                    .padding()
                    .background(Color.blue.opacity(0.2)) // Match the button color
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            HStack {
                Button(action: {
                    self.isAgreeToTerms.toggle()
                }) {
                    Image(systemName: isAgreeToTerms ? "checkmark.square" : "square")
                        .foregroundColor(isAgreeToTerms ? .blue : .gray)
                }
                
                Text(NSLocalizedString("Accept-Conditions", comment: "I agree to the Terms and Conditions"))
                    .foregroundColor(.primary)
                    .font(.callout)
                    .onTapGesture {
                        self.isAgreeToTerms.toggle()
                    }
                
                Spacer() // Pushes the contents to the left
                
                NavigationLink(destination: TermsAndConditionsView()) {
                    Text(NSLocalizedString("View-Terms", comment: "View Terms"))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            HStack {
                Spacer()
                
                // Google sign-in button
                Button(action: {
                    // Add action for Google sign-in
                }) {
                    Image("googleIcon") // Replace with your Google image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                Spacer() // This will space the buttons evenly
                
                // WeChat sign-in button
                Button(action: {
                    // Add action for WeChat sign-in
                }) {
                    Image(systemName: "applelogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                }
                
                Spacer() // This will space the buttons evenly
                
                // Apple sign-in button
                Button(action: {
                    // Add action for Apple sign-in
                }) {
                    Image("wechatIcon") // Replace with your Apple image name
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Text(authManager.errorMessage)
                .foregroundColor(.red)
    
            Spacer()
            
            // Register Button with Right Arrow
            Button(action: {
                authManager.registerUser(email: email, password: password)
            }) {
                if !authManager.isSigningUp {
                    Label(
                        title: { Text(NSLocalizedString("Register-Button", comment: "Register button")) },
                        icon: { Image(systemName: "arrow.right.circle") }
                    )
                    .buttonStyle()
                    .frame(width: 100)
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal)
            .padding(.bottom)
            .disabled(!isAgreeToTerms) // Disable button if terms not agreed
            .onTapGesture {
                if !isAgreeToTerms {
                    // Set error message and show alert if user is not 18
                    self.errorMessage = NSLocalizedString("Error: Not Agree Terms", comment: "You must be at least 18 years old to use this app.")
                    self.activeAlert = true
                }
            }
            
        }
        .padding()
        .background(
            colorScheme == .dark ?
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        // Excluding the button's frame from the tap gesture to dismiss the keyboard
        .contentShape(Rectangle())
        .onAppear {
            self.authManager.errorMessage = ""
        }
        .navigationBarBackButtonHidden(true)
        
        
        
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
