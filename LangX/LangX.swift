//
//  TandyApp.swift
//  Tandy
//
//  Created by Luke Thompson on 25/11/2023.
//

import SwiftUI
import Firebase
import UserNotifications
import FirebaseMessaging

@main
struct LangX: App {
    @StateObject var authManager = AuthManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate


    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            mainView
                .environmentObject(authManager)
                .animation(.default, value: authManager.isUserAuthenticated)
                .animation(.default, value: authManager.isUserAccountSetupCompleted)
                .animation(.easeInOut, value: authManager.isAppInitializing)
                .animation(.easeInOut, value: authManager.isUserAuthenticated)
                .animation(.easeInOut, value: authManager.isUserAccountSetupCompleted)
                .accentColor(Color(red: 51/255, green: 200/255, blue: 255/255))
        }
    }

    @ViewBuilder
    private var mainView: some View {
        switch (authManager.isAppInitializing, authManager.isUserAuthenticated, authManager.isUserAccountSetupCompleted) {
        case (true, _, _):
            SplashScreenView()
        case (false, true, true):
            MainMenuView(authManager: authManager)
        case (false, true, false):
            SetupAccountView()
        case (false, false, _):
            IndexView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        // Request permission to display alerts and play sounds.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Request Authorization Completion Handler. Granted: \(granted), Error: \(String(describing: error))")
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        Messaging.messaging().apnsToken = deviceToken

        // Call uploadFCMToken here after setting APNS Token
        uploadFCMToken(fcmToken: Messaging.messaging().fcmToken)
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "none")")
        // Call uploadFCMToken here as well
        if let token = fcmToken {
            uploadFCMToken(fcmToken: token)
        }
    }

    func uploadFCMToken(fcmToken: String?) {
        guard let token = fcmToken, let userID = Auth.auth().currentUser?.uid else {
            print("Error: FCM token or user ID is nil")
            return
        }

        let db = Firestore.firestore()
        let usersRef = db.collection("users").document(userID)
        
        usersRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // User document exists, proceed to update the FCM token
                usersRef.setData(["fcmToken": token], merge: true) { error in
                    if let error = error {
                        print("Error updating FCM token in Firestore: \(error.localizedDescription)")
                    } else {
                        print("FCM token updated successfully in Firestore.")
                    }
                }
            } else {
                print("User document does not exist. FCM token not updated.")
                // Handle the case where the user document does not exist.
                // You might want to create a new document or handle this scenario differently based on your app's logic.
            }
        }
    }
    
    // Handle registration error
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    private func requestNotificationAuthorization(application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
}
