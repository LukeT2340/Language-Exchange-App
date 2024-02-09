//
//  CallUIViewRepresentabke.swift
//  Tandy
//
//  Created by Luke Thompson on 6/12/2023.
//

import SwiftUI

struct CallUIViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> CallUIView {
        // Create the UIView instance here
        return CallUIView()
    }

    func updateUIView(_ uiView: CallUIView, context: Context) {
        // Update the view with new data here, if necessary
    }
}
