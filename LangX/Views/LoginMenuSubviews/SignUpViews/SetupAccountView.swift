//
//  SetupAccountView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct SetupAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var setupViewModel = SetupViewModel(authManager: AuthManager())

    
    var body: some View {
        NavigationStack {
            //UsernameSetupView(setupViewModel: setupViewModel)
            BirthdaySetupView(setupViewModel: setupViewModel)
        }
    }
}

