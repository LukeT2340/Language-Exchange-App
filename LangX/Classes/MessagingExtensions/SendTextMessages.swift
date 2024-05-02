//
//  SendMessages.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// Send text Messages
extension MainService {
    func sendTextMessage(text: String) {
        guard let clientUser = clientUser else {
            print("client user not found")
            return
        }
        
        guard let receiverId = chattingWithUserId else {
            print("receiver not found")
            return
        }
        
        guard let conversationId = chattingInConversationId else {
            print("conversation not found")
            return
        }
        
        // Create a new message document as a variable
        var newMessage = Message(
            senderId: clientUser.id,
            receiverId: receiverId,
            timestamp: Date(),
            conversationId: conversationId,
            hasBeenRead: false,
            messageType: .text,
            textContent: text,
            mediaURL: nil,
            duration: nil,
            isUploaded: false
        )
        do {
            // Create a new document reference
            let documentRef = db.collection("messages").document()
            newMessage.id = documentRef.documentID // Set the message's ID
            
            // Add the new message to the Firestore collection
            try documentRef.setData(from: newMessage) { error in
                if let error = error {
                    // Handle the error, e.g., show an alert to the user
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    // Update the upload status to 'uploaded' after successful sending
                    documentRef.updateData(["isUploaded": true]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                            
                            // If conversation is hidden for client user, unhide it
                            if ((clientUser.hiddenConversationIds.contains(conversationId))) {
                                self.unhideConversation(conversationId: conversationId, userId: clientUser.id)
                            }
                            
                            // If conversation is hidden for receiver, unhide it
                            if let receiverUser = self.otherUsers.first(where: { $0.id == receiverId }) {
                                if receiverUser.hiddenConversationIds.contains(conversationId) {
                                    print("No here")
                                    self.unhideConversation(conversationId: conversationId, userId: receiverId)
                                }
                            }
                        }
                    }
                }
            }
        } catch let error {
            // Handle any errors here, like encoding issues
            print("Error adding message: \(error.localizedDescription)")
        }
    }
    
    func sendStartConversationSystemMessage(receiverId: String, conversationId: String) {
        // Create a new message document as a variable
        var newMessage = Message(
            senderId: "0",
            receiverId: receiverId,
            timestamp: Date(),
            conversationId: conversationId,
            hasBeenRead: false,
            messageType: .system,
            textContent: nil,
            mediaURL: nil,
            duration: nil,
            isUploaded: false
        )
        do {
            // Create a new document reference
            let documentRef = db.collection("messages").document()
            newMessage.id = documentRef.documentID // Set the message's ID
            
            // Add the new message to the Firestore collection
            try documentRef.setData(from: newMessage) { error in
                if let error = error {
                    // Handle the error, e.g., show an alert to the user
                    print("Error sending message: \(error.localizedDescription)")
                } else {
                    // Update the upload status to 'uploaded' after successful sending
                    documentRef.updateData(["isUploaded": true]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                    }
                }
            }
        } catch let error {
            // Handle any errors here, like encoding issues
            print("Error adding message: \(error.localizedDescription)")
        }
    }
    
    private func updateLocalMessageStatus(messageId: String, otherUserId: String, newStatus: Bool) {
        if let index = messages[otherUserId]?.firstIndex(where: { $0.id == messageId }) {
            messages[otherUserId]?[index].isUploaded = newStatus
        }
    }
}

