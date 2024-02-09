//
//  NewAuthManager.swift
//  LangX
//
//  Created by Luke Thompson on 13/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AuthManager: ObservableObject {
    @Published var errorMessage: String = ""
    @Published var isInitializing: Bool = false
    @Published var firebaseUser: Firebase.User?
    @Published var isAuthenticated: Bool = false
    @Published var isAccountSetup: Bool = false
    @Published var isLoggingOut: Bool = false
    @Published var isLoggingIn: Bool = false
    @Published var isSigningUp: Bool = false
    private var db = Firestore.firestore()
    private var onlineStatusTimer: Timer?

    init() {
        self.isInitializing = true
        self.firebaseUser = Auth.auth().currentUser
        self.isAuthenticated = firebaseUser != nil
        if self.isAuthenticated {
            isAccountSetup() { success in
                if success {
                    self.isAccountSetup = true
                    self.updateLastOnline()
                    self.startOnlineStatusUpdates()
                } else {
                    self.isAccountSetup = false
                    print("User's account is not setup")
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            self.isInitializing = false
        }

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
    
    // Checks whether there is column in Users collection with the User's email
    func isAccountSetup(completion: @escaping (Bool) -> Void) {
        guard let userEmail = firebaseUser?.email else {
            completion(false)
            return
        }

        db.collection("users")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { [weak self] (querySnapshot, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error checking user in Firestore: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        // Check if any documents match the query, indicating the account exists
                        if let querySnapshot = querySnapshot {
                            let isSetup = !querySnapshot.isEmpty
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
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
        guard let userID = firebaseUser?.uid else {
            print("No current user found")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["lastOnline": Date()], merge: true) { error in
            if let error = error {
                print("Error updating last online: \(error)")
            } else {
                // successful updated last online
            }
        }
    }
    
    func registerUser(email: String, password: String) {
        isSigningUp = true
        // Validate Email
        guard isValidEmail(email) else {
            self.errorMessage = NSLocalizedString("InvalidEmailError", comment: "Invalid email")
            isSigningUp = false
            return
        }

        // Validate Password Complexity
        guard isPasswordComplex(password) else {
            self.errorMessage = NSLocalizedString("PasswordComplexityError", comment: "Invalid password")
            isSigningUp = false
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let nsError = error as NSError? {
                    switch nsError.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        // Email already in use
                        self?.errorMessage = NSLocalizedString("EmailAlreadyInUseError", comment: "Email already in use")
                        // Add other cases here as needed
                    default:
                        self?.errorMessage = nsError.localizedDescription
                    }
                    self?.isSigningUp = false
                } else if let user = authResult?.user {
                    // Handle successful registration
                    self?.firebaseUser = user
                    self?.isAuthenticated = true
                    self?.isAccountSetup() { accountSetup in
                        self?.isAccountSetup = accountSetup ? true : false
                        self?.isSigningUp = false
                    }
                }
            }
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
    
    // Logs user out
    func logout(completion: @escaping (Bool, Error?) -> Void) {
        isLoggingOut = true
        print("Logout function called")
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.isAccountSetup = false
                self.firebaseUser = nil
                self.stopOnlineStatusUpdates()
                self.isLoggingOut = false
                
                // Call completion with success
                completion(true, nil)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            self.isLoggingOut = false

            // Call completion with failure
            completion(false, signOutError)
        }
    }

    func login(email: String, password: String) {
        isLoggingIn = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let user = authResult?.user {
                    self?.firebaseUser = user
                    self?.isAccountSetup() {accountSetup in
                        self?.isAuthenticated = true
                        self?.isAccountSetup = (accountSetup ?  true : false)
                    }
                    self?.isLoggingIn = false
                } else if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.isLoggingIn = false
                
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopOnlineStatusUpdates()
    }
}
