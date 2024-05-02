//
//  EmailLoginView.swift
//  LangLeap
//
//  Created by Luke Thompson on 12/11/2023.
//

import SwiftUI

struct LoginScreen: View {
    @StateObject private var keyboardResponder = KeyboardResponder()
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    
    @State var phoneNumber = ""
    @State var code = ""
    @State private var selectedRegion = NSLocalizedString("Country", comment: "country")
    @State var termsAccepted = true
    @State var sendingCode = false
    @State var isValidPhoneNumber = false
    @State var error = ""
    @State var isRegistering = false
    @FocusState var isCodeFieldFocus
    let regionCodes: [Country] = [
        Country(name: NSLocalizedString("United States", comment: ""), phoneCode: "+1"),
        Country(name: NSLocalizedString("United Kingdom", comment: ""), phoneCode: "+44"),
        Country(name: NSLocalizedString("Canada", comment: ""), phoneCode: "+1"),
        Country(name: NSLocalizedString("Australia", comment: ""), phoneCode: "+61"),
        Country(name: NSLocalizedString("China", comment: ""), phoneCode: "+86"),
    ]
    
    var body: some View {
            VStack {
                ScrollView {
                    textFields
                    registerAndLoginButtons
                        .onTapGesture {
                            self.hideKeyboard()
                        }
                }
                Spacer()
                additionalLoginOptions
                    .animation(.easeInOut, value: keyboardResponder.isVisible)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.9), Color("Background1").opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.65)
            .blendMode(.multiply)
            
        )
        .navigationTitle("Register/Login")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.white)
                .fontWeight(.medium)
        })
        .navigationBarBackButtonHidden(true)
        
    }
    
    private var textFields: some View {
        VStack (spacing: 15) {
            HStack {
                Image(systemName: "phone")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 20))
                TextField(LocalizedStringKey("Phone number"), text: $phoneNumber)
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber) { newNumber in
                        isValidPhoneNumber = isValidPhoneNumber(regionCode: selectedRegion, phoneNumber: newNumber)
                    }
                Menu {
                    ForEach(regionCodes, id: \.self) { country in
                        Button(action: {
                            selectedRegion = country.phoneCode
                        }) {
                            HStack {
                                Text("\(country.phoneCode) \(country.name)")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedRegion)
                        Image(systemName: "chevron.down")
                    }
                }
                .onChange(of: selectedRegion) { newRegion in
                    isValidPhoneNumber = isValidPhoneNumber(regionCode: newRegion, phoneNumber: phoneNumber)
                }
            }
            Divider()
            HStack {
                Image(systemName: "key")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 20))
                TextField(LocalizedStringKey("Code"), text: $code)
                    .keyboardType(.numberPad)
                    .focused($isCodeFieldFocus)
                Button(action: {
                    sendingCode = true
                    self.hideKeyboard()
                    authManager.sendOTP(phoneNumber: "\(selectedRegion)\(phoneNumber)") { error in
                        sendingCode = false
                        if let error = error {
                            let englishError = error.localizedDescription.localized("en")
                            
                            if englishError.contains("We have blocked all requests from this device due to") {
                                self.error = "Requests-too-frequent"
                            } else if englishError.contains("TOO_LONG") || englishError.contains("TOO_SHORT"){
                                self.error = "Phone-number-incorrect"
                            } else {
                                self.error = ""
                            }
                        } else {
                            isCodeFieldFocus = true
                        }
                    }
                }) {
                    if sendingCode {
                        LoadingView()
                    }
                    Text(authManager.isSendCodeButtonDisabled ?
                         String(format: NSLocalizedString("Code sent", comment: ""), authManager.countdown) :
                            NSLocalizedString("Get code", comment: ""))
                    
                }
                .disabled(!isValidPhoneNumber || sendingCode || authManager.isSendCodeButtonDisabled)

            }
            
            if !error.isEmpty {
                Text(LocalizedStringKey(error))
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .padding()
    }
    
    @ViewBuilder
    private var registerAndLoginButtons: some View {
        Button(action: {
            self.hideKeyboard()
            if termsAccepted {
                error = ""
                isRegistering = true
                authManager.verifyOTP(otp: code) { error in
                    if let error = error {
                        self.error = "Authentication-code-incorrect"
                    }
                    isRegistering = false
                }
            } else {
                error = NSLocalizedString("Please accept the terms and condtions.", comment: "")
            }
        }) {
            Group {
                if authManager.isLoggingIn {
                    WhiteLoadingView()
                    
                } else {
                    Text(LocalizedStringKey("Register/Login"))
                }
            }
            .foregroundColor(.white)
            .fontWeight(.medium)
            .padding(.vertical, 12)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(Color("AccentColor"))
            .cornerRadius(30)
            .opacity(code.count != 6 || !isValidPhoneNumber ? 0.7 : 1.0)
            .disabled(code.count != 6 || !isValidPhoneNumber)
        }
        .padding(.horizontal)
        .disabled(isRegistering || code.count != 6)

        HStack {
            Button(action: {termsAccepted.toggle()}) {
                Image(systemName: termsAccepted ? "checkmark.circle.fill": "circle")
                    .foregroundColor(.white)
            }
            Text(LocalizedStringKey("I've accepted the"))
                .foregroundColor(.white)
            NavigationLink(destination: EmptyView()) {
                Text(LocalizedStringKey("Terms and Conditions"))
                    .foregroundColor(.white)
                    .underline()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var additionalLoginOptions: some View {
        if !keyboardResponder.isVisible {
            HStack {
                Rectangle()
                    .frame(height: 0.8)
                    .foregroundColor(.white)
                Spacer()
                Text(LocalizedStringKey("or log in with"))
                    .foregroundColor(.white)
                Spacer()
                Rectangle()
                    .frame(height: 0.8)
                    .foregroundColor(.white)
            }
            .padding()
            Spacer()
            HStack {
                Spacer()
                Button(action: {}) {
                    Image("GoogleIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Button(action: {}) {
                    Image("FacebookIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Button(action: {}) {
                    Image("WechatIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Spacer()
                Button(action: {}) {
                    Image("AppleIcon")
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            .padding(.horizontal, 50)
        }
    }
    
    func isValidPhoneNumber(regionCode: String, phoneNumber: String) -> Bool {
        let trimmedRegionCode = regionCode.replacingOccurrences(of: "+", with: "")
        let combinedPhoneNumber = "\(trimmedRegionCode)\(phoneNumber)"
        let isValidLength = (8...16).contains(combinedPhoneNumber.count)
        return combinedPhoneNumber.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil && isValidLength
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}

struct RegisterScreenPreviews: PreviewProvider {
    static var previews: some View {
        let appSettings = AppSettings()
        let authManager = AuthManager()
        LoginScreen().environmentObject(appSettings).environmentObject(authManager)
    }
}

struct Country: Hashable {
    var name: String
    var phoneCode: String
}
