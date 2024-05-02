//
//  ModifyConversations.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// Modify conversations
extension MainService {
    func hideConversation(conversationId: String) {
        guard let clientUser = clientUser else {
            print("client user not found")
            return
        }
        
        // Reference to the user's document
        let userRef = db.collection("users").document(clientUser.id)
        // Add the conversationId to the hiddenConversationIds field
        userRef.updateData([
            "hiddenConversationIds": FieldValue.arrayUnion([conversationId])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Conversation successfully hidden")
            }
        }
    }
    
    func unhideConversation(conversationId: String, userId: String) {
        // Reference to the user's document
        let userRef = db.collection("users").document(userId)
        
        userRef.updateData([
            "hiddenConversationIds": FieldValue.arrayRemove([conversationId])
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Conversation successfully unhidden")
            }
        }
    }
}
