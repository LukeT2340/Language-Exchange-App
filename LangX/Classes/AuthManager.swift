//
//  NewAuthManager.swift
//  LangX
//
//  Created by Luke Thompson on 13/1/2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthManager: ObservableObject {
    @Published var isSigningUp: Bool = false
    @Published var isUserAuthenticated: Bool = false
    @Published var isUserAccountSetupCompleted: Bool = false
    @Published var isAppInitializing: Bool = false
    @Published var firebaseUser: Firebase.User?
    @Published var isLoggingIn: Bool = false
    @Published var isLoggingOut: Bool = false
    @Published var nonce = ""
    @Published var isPhoneNumberBound: Bool = true // for testing
    private var db = Firestore.firestore()
    private var onlineStatusTimer: Timer?
    
    init() {
        self.isAppInitializing = true
        self.firebaseUser = Auth.auth().currentUser
        self.isUserAuthenticated = firebaseUser != nil
        
        if isUserAuthenticated {
            checkIfAccountIsSetup() {
                DispatchQueue.main.async {
                    self.isAppInitializing = false
                }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.isAppInitializing = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    
    @objc private func appMovedToForeground() {
        print("App is back to foreground")
        updateLastOnline()
        startOnlineStatusUpdates()
    }
    
    
    @objc private func appMovedToBackground() {
        // Code to execute when the app goes to background
        print("App moved to background")
        // Call any functions you need here, such as updateLastOnline
        stopOnlineStatusUpdates()
    }
 
    func emailLogin(email: String, password: String) {
        isLoggingIn = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let user = authResult?.user {
                    print(user.uid)
                    self?.firebaseUser = user
                    DispatchQueue.main.async {
                        self?.checkIfAccountIsSetup() {
                            self?.isUserAuthenticated = true
                            self?.isLoggingIn = false
                        }
                    }
                }
            self?.isLoggingIn = false
        }
    }
    
    // Email Validation Function
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    // Password Complexity Validation Function
    func isPasswordComplex(_ password: String) -> Bool {
        // Example: Password should be at least 8 characters, including uppercase, lowercase, number, and special character
        let passwordRegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z])(?=.*[!@#$&*]).{8,}"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: password)
    }
    
    func emailRegister(email: String, password: String) {
        isSigningUp = true
        // Validate Email
        guard isValidEmail(email) else {
            isSigningUp = false
            return
        }

        // Validate Password Complexity
        guard isPasswordComplex(password) else {
            isSigningUp = false
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let user = authResult?.user {
                    // Handle successful registration
                    self?.firebaseUser = user
                    self?.isUserAuthenticated = true
                    self?.checkIfAccountIsSetup() {
                        self?.isSigningUp = false
                    }
                }
            }
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        isLoggingIn = true
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [unowned self] result, error in
          guard error == nil else {
                // Handle the error
                print(error?.localizedDescription ?? "Unknown error")
                isLoggingIn = false
                return
            }
            
            guard let user = result?.user,
              let idToken = user.idToken?.tokenString
            else {
                isLoggingIn = false
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                if let error = error {
                    self?.isLoggingIn = false
                    print(error.localizedDescription)
                    return
                }
                // User is signed in, update your UI accordingly
                DispatchQueue.main.async {
                    self?.firebaseUser = authResult?.user
                    self?.isAccountSetup() {result in
                        self?.isUserAccountSetupCompleted = result
                        self?.isUserAuthenticated = true
                        self?.isLoggingIn = false
                    }
                }
            }
        }
    }

    func signInWithAppleRequest(_ request: ASAuthorizationOpenIDRequest) {
        nonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    func signInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        isLoggingIn = true
        switch result {
        case .success(let user):
            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("credential 23")
                isLoggingIn = false
                return
            }
            guard let token = credential.identityToken else {
                print("error with token 27")
                isLoggingIn = false
                return
            }
            
            guard let tokenString = String(data: token, encoding: .utf8) else {
                print("error with tokenString 31")
                isLoggingIn = false
                return
            }
            
            let credwtion = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
            
            Task {
                do {
                    try await Auth.auth().signIn(with: credwtion)
                    DispatchQueue.main.async {
                        self.isUserAuthenticated = true
                        self.isLoggingIn = false
                    }
                } catch {
                    print("error 45")
                    self.isLoggingIn = false
                }
            }
        case .failure(let failure):
            print(failure.localizedDescription)
            self.isLoggingIn = false
        }
    }
    
    func signOut() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()
            
            // Sign out from Google Sign-In
            GIDSignIn.sharedInstance.signOut()
            
            // Update your UI accordingly
            DispatchQueue.main.async {
                self.isUserAuthenticated = false
                self.isLoggingOut = false
            }
            
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            // Handle the error
            print("Error signing out: \(signOutError.localizedDescription)")
            isLoggingOut = false
        }
    }

    func startOnlineStatusUpdates() {
        onlineStatusTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateLastOnline()
        }
    }
    
    func stopOnlineStatusUpdates() {
        onlineStatusTimer?.invalidate()
    }
    
    func updateLastOnline() {
        guard let userID = firebaseUser?.uid, isUserAccountSetupCompleted else {
            print("No current user found or account setup not completed")
            return
        }

        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userID)

        userDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Document exists, proceed to update lastOnline
                userDocRef.setData(["lastOnline": Date()], merge: true) { error in
                    if let error = error {
                        print("Error updating last online: \(error)")
                    } else {
                        // Successfully updated last online
                    }
                }
            } else {
                // Document does not exist, create it or handle according to your app's logic
                print("User document does not exist. Consider creating it or handling this case accordingly.")
            }
        }
    }


    // Function to send a verification code to the user's phone
    func startAuth(countryCode: String, phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure the country code starts with '+'
        let formattedCountryCode = countryCode.hasPrefix("+") ? countryCode : "+\(countryCode)"
        
        // Remove leading zeros from phone number
        let trimmedPhoneNumber = phoneNumber.trimmingCharacters(in: CharacterSet(charactersIn: "0"))
        
        // Combine country code and phone number
        let fullPhoneNumber = formattedCountryCode + trimmedPhoneNumber
        print("startAuth called with phoneNumber: \(fullPhoneNumber)")

        // Send verification code using Firebase
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { verificationID, error in
            print("Firebase response received") // Debugging line
            if let error = error {
                print("Error: \(error.localizedDescription)") // Debugging line
                completion(.failure(error))
            } else if let verificationID = verificationID {
                print("Verification ID: \(verificationID)") // Debugging line
                completion(.success(verificationID))
            } else {
                print("Unexpected scenario encountered") // Debugging line
                completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])))
            }
        }
    }

    func sendVerificationCode(phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                return
            }
            guard let verificationID = verificationID else {
                print("Verification ID not received.")
                return
            }
            print("Verification ID: \(verificationID)")
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
        }
    }
    
    // Function to verify the code entered by the user
    func verifyCode(verificationCode: String) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )

        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                // Handle the error
                print(error.localizedDescription)
                return
            }
            
            self.firebaseUser = authResult?.user
            DispatchQueue.main.async {
                self.checkIfAccountIsSetup() {
                    self.isUserAuthenticated = true
                    self.isLoggingIn = false
                }
            }
        }
    }

    func isAccountSetup(completion: @escaping (Bool) -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let userRef = db.collection("users").document(firebaseUser.uid)

        userRef.getDocument { document, error in
            if let error = error {
                print("Error getting user: \(error)")
                completion(false)
            } else if let document = document, document.exists {
                completion(true)
            } else {
                print("Document does not exist")
                completion(false)
            }
        }

    }
    
    func checkIfAccountIsSetup(completion: @escaping () -> Void) {
        guard let firebaseUser = Auth.auth().currentUser else {
            self.isUserAccountSetupCompleted = false
            completion()
            return
        }
        
        isAccountSetup() { result in
            self.isUserAccountSetupCompleted = result
            if result {
                self.startOnlineStatusUpdates()
            }
            completion()
        }
    }
}

extension AuthManager {
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

}

