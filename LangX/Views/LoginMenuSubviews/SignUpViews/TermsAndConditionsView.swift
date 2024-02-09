//
//  TermsAndConditionsView.swift
//  Tandy
//
//  Created by Luke Thompson on 7/12/2023.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        ScrollView {
            Text("Your Terms and Conditions go here...")
                .padding()
        }
        .navigationTitle(NSLocalizedString("Terms-Title", comment: "Terms and Conditions"))
    }
}

