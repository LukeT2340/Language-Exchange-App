//
//  KeyboardResponder.swift
//  Tandy
//
//  Created by Luke Thompson on 4/12/2023.
//

import SwiftUI

// Used to track whether the keyboard is open or not
class KeyboardResponder: ObservableObject {
    private var notificationCenter: NotificationCenter
    @Published var isVisible: Bool = false
    
    init(center: NotificationCenter = .default) {
        notificationCenter = center
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        isVisible = true
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        isVisible = false
    }
}
