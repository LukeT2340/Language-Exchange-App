//
//  RegisterMenuView.swift
//  LangX
//
//  Created by Luke Thompson on 11/2/2024.
//

import SwiftUI
import Firebase
import _AuthenticationServices_SwiftUI
import GoogleSignInSwift

struct RegisterMenuView: View {
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var keyboardResponder = KeyboardResponder()
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        VStack (spacing: 15) {            
            Spacer()
            
            VStack (alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("Email-Placeholder"))
                    .fontWeight(.medium)
                TextField(NSLocalizedString("Email-Placeholder", comment: "Email placeholder"), text: $email)
                    .simultaneousGesture(TapGesture().onEnded {
                        
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.5), lineWidth: 1)
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .frame(width: 300)
            }
            
            
            VStack (alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey("Email-Placeholder"))
                    .fontWeight(.medium)
                SecureField(NSLocalizedString("Password-Placeholder", comment: "Password placeholder"), text: $password)
                    .simultaneousGesture(TapGesture().onEnded {
                        
                    })
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.5), lineWidth: 1)
                    )
                    .frame(width: 300)
            }
            
            
            // Register Button with Right Arrow
            Button(action: {
                authManager.emailRegister(email: email, password: password)
                hideKeyboard()
            }) {
                if !authManager.isSigningUp {
                    Text(NSLocalizedString("Register-Button", comment: "Register button"))
                        .fontWeight(.medium)
                        .buttonStyle()
                } else {
                    ProgressView()
                        .buttonStyle()
                }
            }
            if !keyboardResponder.isVisible {
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray)
                    Spacer()
                    
                    Text("OR")
                        .foregroundColor(Color.primary)
                        .fontWeight(.light)
                        .padding(.horizontal, 10)
                    
                    Spacer()
                    
                    // Right divider
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray)
                }
                .padding()
                
                Button(action: {
                    guard let rootViewController = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                        print("Unable to find a root view controller.")
                        return
                    }
                    authManager.signInWithGoogle(presentingViewController: rootViewController)
                }) {
                    HStack (alignment: .center) {
                        Image("googleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(NSLocalizedString("Use-Google-Button", comment: "Sign in with google"))
                            .foregroundColor(.black)
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 3) // Border
                    )
                    .background(Color.white)
                    .cornerRadius(8)
                    .font(.system(size: 19))
                }
                
                // Continue with Apple
                Button(action: {
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "applelogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                        
                        Text(NSLocalizedString("Use-Apple-Button", comment: "Sign in with apple"))
                        Spacer()
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .font(.system(size: 19))
                    
                }
                
                // WeChat Sign-In Button
                Button(action: {
                    
                }) {
                    HStack (alignment: .center) {
                        Image("wechatIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text(NSLocalizedString("Use-Wechat-Button", comment: "Sign in with wechat"))
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .frame(width: 300, height: 50)
                    .background(Color(red: 45/255, green: 193/255, blue: 0))
                    .cornerRadius(8)
                    .font(.system(size: 19))
                }
                
                
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: keyboardResponder.isVisible)
        .navigationTitle(LocalizedStringKey("Register"))
        .onTapGesture {
            self.hideKeyboard()
        }
        
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


