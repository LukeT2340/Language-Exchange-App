//
//  SettingsView.swift
//  Tandy
//
//  Created by Luke Thompson on 4/1/2024.
//

import SwiftUI
import Firebase
import Kingfisher

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    
    @State private var notificationsEnabled = false // place-holders
    @State private var darkModeEnabled = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            navigationBarView
            settingsOptionsView
        }
    }
    
    private var navigationBarView: some View {
        HStack {
            // Left Button
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor) // Consistent color for icons
            }
            .padding(.leading, 15)
            Spacer()
            Text(NSLocalizedString("Settings", comment: "Settings"))
            Spacer()
        }
        .shadow(radius: 5) // Optional shadow for depth
        .background(colorScheme == .dark ? Color.black : Color.white)
        .padding(.vertical, 5)
    }
    
    private var settingsOptionsView: some View {
        VStack {
            Form {
                 Section(header: Text("Preferences")) { // Placeholder settings
                     Toggle(isOn: $notificationsEnabled) {
                         Text("Enable Notifications")
                     }
                     
                     Toggle(isOn: $darkModeEnabled) {
                         Text("Dark Mode")
                     }
                 }
                 
                 Section(header: Text("Account")) {
                     Button("Log Out") {
                         authManager.logout() { loggedOut, Error in
                             if loggedOut {
                                 self.presentationMode.wrappedValue.dismiss()
                             } else {
                                 print("Error logging out: \(String(describing: Error))")
                             }
                         }
                     }
                 }
             }
        }
    }
}
