//
//  IndexView.swift
//  LangX
//
//  Created by Luke Thompson on 11/2/2024.
//

import Foundation
import SwiftUI

struct IndexView_Previews: PreviewProvider {
    static var previews: some View {
        IndexView().environmentObject(AuthManager())
    }
}

struct IndexView: View {
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                NavigationLink(destination: LoginMenuView().environmentObject(authManager)) {
                    Text(LocalizedStringKey("Login"))
                        .buttonStyle()

                }

                NavigationLink(destination: RegisterMenuView().environmentObject(authManager)) {
                    Text(LocalizedStringKey("Register"))
                        .buttonStyle()

                }
            }
        }
    }
}
