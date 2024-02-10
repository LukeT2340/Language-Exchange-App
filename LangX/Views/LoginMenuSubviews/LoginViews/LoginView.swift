//
//  EmailLoginView.swift
//  LangLeap
//
//  Created by Luke Thompson on 12/11/2023.
//

import SwiftUI
import Firebase

import SwiftUI
import Firebase

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    // Left Button
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
                Spacer()
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
                
                Spacer()
                
                HStack {
                    Button(action: {
                        //authManager.sendPasswordReset()
                    }) {
                        Text(NSLocalizedString("Forgot Password?", comment: "Forgot password?"))
                            .foregroundColor(colorScheme == .dark ? .white : .blue)
                            .font(.callout)
                            .padding(.top, 5)
                    }


                    Spacer()
                    
                    // Register Button with Right Arrow
                    Button(action: {
                        authManager.emailLogin(email: email, password: password)
                    }) {
                        if !authManager.isLoggingIn {
                            Label(
                                title: { Text(NSLocalizedString("Login-Button", comment: "Login button")) },
                                icon: { Image(systemName: "arrow.right.circle") }
                            )
                            .buttonStyle()
                            .frame(width: 100)
                        } else {
                            ProgressView()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .padding()
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
            .navigationBarBackButtonHidden(true)
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
