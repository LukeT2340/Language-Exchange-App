//
//  ChatView2.swift
//  Tandy
//
//  Created by Luke Thompson on 16/12/2023.
//

import SwiftUI
import FirebaseFirestore
import AVKit

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

