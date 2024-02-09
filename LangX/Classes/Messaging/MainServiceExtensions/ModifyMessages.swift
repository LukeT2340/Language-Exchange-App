//
//  ModifyMessages.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// Modify messages
extension MainService {
    func markMessageAsRead(_ message: Message) {
        if let messageId = message.id {
            let messageRef = db.collection("messages").document(messageId)
            messageRef.updateData(["hasBeenRead": true]) { error in
                if let error = error {
                    print("Error marking message as read: \(error)")
                } else {
                    print("Message marked as read")
                }
            }
        }
    }
    
    func markMessagesAsRead(for otherUserId: String, completion: @escaping (Bool) -> Void) {
        guard var messagesForUser = messages[otherUserId], !messagesForUser.isEmpty else {
            print("No messages found for user \(otherUserId)")
            completion(false)
            return
        }

        let messagesRef = db.collection("messages")
        let group = DispatchGroup()
        var updateSuccess = true
        var updatedMessages = messagesForUser // Copy of the messages array

        for (index, message) in messagesForUser.enumerated() {
            if message.receiverId == clientUser?.id, let messageId = message.id, !message.hasBeenRead {
                group.enter()
                let messageDocument = messagesRef.document(messageId)
                messageDocument.updateData(["hasBeenRead": true]) { [weak self] error in
                    defer { group.leave() }

                    if let error = error {
                        print("Error updating message \(messageId): \(error)")
                        updateSuccess = false
                    } else {
                        print("Message \(messageId) marked as read")
                        updatedMessages[index].hasBeenRead = true // Update the copy
                    }
                }
            }
        }

        group.notify(queue: .main) {
            self.messages[otherUserId] = updatedMessages // Update all messages at once
            completion(updateSuccess)
        }
    }


    
}
