//
//  handleTyping.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

extension MainService {
    func updateUserTypingStatus(isTyping: Bool) {
        guard let clientUser = clientUser else {
            return
        }
        
        let userRef = self.db.collection("users").document(clientUser.id)
        userRef.updateData(["isTyping": isTyping]) { error in
            if let error = error {
                print("Error updating typing status: \(error)")
            }
        }
        
    }
}
