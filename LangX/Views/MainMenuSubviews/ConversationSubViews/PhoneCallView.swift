//
//  phoneCallView.swift
//  Tandy
//
//  Created by Luke Thompson on 6/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct PhoneCallView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            CallUIViewRepresentable()
                .frame(height: 300)
        }
    }
}
