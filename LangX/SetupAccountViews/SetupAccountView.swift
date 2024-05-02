//
//  SetupAccountView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct SetupAccountView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var setupAccountModel = SetupAccountModel(authManager: AuthManager())

    init() {
        let appearance = UINavigationBarAppearance()
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .medium)]

        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        NavigationStack {
            //UsernameSetupView(setupViewModel: setupViewModel)
            //SexAndBirthdaySetupView(setupAccountModel: setupAccountModel)
            TargetLanguageSetupView(setupAccountModel: setupAccountModel)
        }
    }
}

