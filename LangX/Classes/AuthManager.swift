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
import Combine

// Used as an environmental variable throughout the app to track the login status of the user
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
    @Published var isSendCodeButtonDisabled: Bool = false
    @Published var countdown: Int = 60
    private var verificationID: String?
    private var timer: AnyCancellable?
    
    static let shared = AuthManager()

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
    
    // This function is called when the user re-opens the app.
    @objc private func appMovedToForeground() {
        updateLastOnline() // Updates the user's lastOnline field in firebase
        startOnlineStatusUpdates() // Continue to periodically update lastOnline
    }
    
    @objc private func appMovedToBackground() {
        stopOnlineStatusUpdates() // Stop last online status updates
    }
    
    // Once the mobile authentication code is sent, we start this timer
    private func startSendCodeCooldown() {
        isSendCodeButtonDisabled = true
        countdown = 60

        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.countdown > 0 {
                    self.countdown -= 1
                } else {
                    self.isSendCodeButtonDisabled = false
                    self.timer?.cancel()
                }
            }
    }
    
    // Send one time password to the user's phone number
    func sendOTP(phoneNumber: String, completion: @escaping (Error?) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("Error verifying phone number:", error.localizedDescription)
                completion(error)
                return
            }
            
            guard let verificationID = verificationID else {
                let error = NSError(domain: "Verification", code: -1, userInfo: [NSLocalizedDescriptionKey: "Verification ID is nil"])
                print("Error verifying phone number: Verification ID is nil")
                completion(error)
                return
            }
            
            self.verificationID = verificationID
            self.startSendCodeCooldown()
            completion(nil)
        }
    }

    // Check to see if the entered OTP is correct. Then logs the user in if it is correct.
    func verifyOTP(otp: String, completion: @escaping (Error?) -> Void) {
        guard let verificationID = verificationID else {
            completion(FirebaseAuthError.missingVerificationID)
            return
        }
        isLoggingIn = true
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otp)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(error)
                self.isLoggingIn = false
                print(error.localizedDescription)
                return
            }
            self.checkIfAccountIsSetup {
                self.isUserAuthenticated = true
                self.isLoggingIn = false
                completion(nil)
            }
        }
    }
    
    // Handle google sign-in
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

    // Handle sign in with app request
    func signInWithAppleRequest(_ request: ASAuthorizationOpenIDRequest) {
        nonce = randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    // Handle sign in with app completion
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
    
    // Sign user out
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
            
        } catch let signOutError as NSError {
            // Handle the error
            print("Error signing out: \(signOutError.localizedDescription)")
            isLoggingOut = false
        }
    }

    // Updates the user's lastOnline field in firebase every 30 seconds
    func startOnlineStatusUpdates() {
        onlineStatusTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.updateLastOnline()
        }
    }
    
    // Stops last online status updates
    func stopOnlineStatusUpdates() {
        onlineStatusTimer?.invalidate()
    }
    
    // Updates the user's lastOnline field in firebase
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
    
    // Checks to see if the user has setup their account (username, languages, bio, etc)
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
    
    private func isAccountSetup(completion: @escaping (Bool) -> Void) {
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

enum FirebaseAuthError: Error {
    case missingVerificationID
}

