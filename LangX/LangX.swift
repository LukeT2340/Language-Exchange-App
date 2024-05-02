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
    @StateObject var appSettings = AppSettings()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            mainView
                .environmentObject(authManager)
                .environmentObject(appSettings)
                .animation(.default, value: authManager.isUserAuthenticated)
                .animation(.default, value: authManager.isUserAccountSetupCompleted)
                .animation(.easeInOut, value: authManager.isAppInitializing)
                .animation(.easeInOut, value: authManager.isUserAuthenticated)
                .animation(.easeInOut, value: authManager.isUserAccountSetupCompleted)
                .accentColor(Color("AccentColor"))
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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        requestNotificationAuthorization(application: application)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Setting APNS token for Firebase is handled internally, no need to set it explicitly
        print("APNS Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
        uploadFCMToken(fcmToken: Messaging.messaging().fcmToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Process the notification payload here
        completionHandler(.noData)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle deep linking or custom URL schemes here
        return false
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "none")")
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

        usersRef.setData(["fcmToken": token], merge: true) { error in
            if let error = error {
                print("Error updating FCM token in Firestore: \(error.localizedDescription)")
            } else {
                print("FCM token updated successfully in Firestore.")
            }
        }
    }

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

