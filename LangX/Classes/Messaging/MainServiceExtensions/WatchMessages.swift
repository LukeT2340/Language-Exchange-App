//
//  WatchMessages.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// WatchMessages
extension MainService {
    func fetchRecent30MessagesAndListenForUpdates(conversationId: String, otherUserId: String, completion: @escaping (Bool) -> Void) {
        print("Fetching messages and setting up listener for \(conversationId)")
        let messagesRef = db.collection("messages")
        
        // Define the initial query to fetch the most recent 30 messages
        let initialQuery = messagesRef
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: true)
            .limit(to: 30)
        
        // Execute the initial query
        initialQuery.getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting messages: \(error)")
                completion(false)
                return
            }
            
            var earliestTimestamp: Date = Date()
            
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Process the fetched messages
                let last30Messages = documents.reversed().compactMap { document -> Message? in
                    return try? document.data(as: Message.self)
                }
                DispatchQueue.main.async {
                    self?.messages[otherUserId] = last30Messages
                }
                
                // Determine the timestamp to start listening for updates
                earliestTimestamp = last30Messages.first?.timestamp ?? earliestTimestamp
            }
            
            // Start listening for updates after the last message's timestamp or current time if no messages
            self?.startListeningForAllMessageChanges(conversationId: conversationId, otherUserId: otherUserId, since: earliestTimestamp)
            
            completion(true)
        }
    }
    
    
    private func startListeningForAllMessageChanges(conversationId: String, otherUserId: String, since latestTimestamp: Date) {
        let messagesRef = db.collection("messages")
        
        // Convert Date to Firestore Timestamp
        let latestFirestoreTimestamp = Timestamp(date: latestTimestamp)
        
        // Setup the listener for all message changes (new, modified, deleted)
        messagesRef
            .whereField("conversationId", isEqualTo: conversationId)
            .whereField("timestamp", isGreaterThan: latestFirestoreTimestamp)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                if let error = error {
                    print("Error listening for message changes: \(error)")
                    return
                }
                
                guard let self = self, let documentChanges = querySnapshot?.documentChanges else {
                    return
                }
                
                for change in documentChanges {
                    switch change.type {
                    case .added:
                        if let message = try? change.document.data(as: Message.self) {
                            DispatchQueue.main.async {
                                self.updateMessage(message: message, userId: otherUserId)
                            }
                            // Check if the conversation is currently open and mark the message as read
                            if self.chattingInConversationId == conversationId && message.receiverId == clientUser?.id {
                                self.markMessageAsRead(message)
                            } else if message.receiverId == clientUser?.id && selectedTab != 0, message.messageType == .text {
                                let user = otherUsers.first(where: {$0.id == message.senderId})!
                                self.banners.append(Banner(
                                    id: UUID().uuidString,
                                    title: String(format: NSLocalizedString("NewMessageFrom", comment: ""), user.name),
                                    text: message.textContent!,
                                    linkType: .message,
                                    timeStamp: Date(),
                                    otherUserId: otherUserId,
                                    imageURL: user.profileImageUrl
                                ))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.banners.removeFirst()
                                }
                            }
                            
                            if message.receiverId == clientUser?.id && !isLoadingOlderMessages && !message.hasBeenRead {
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                        }
                    case .modified:
                        if let message = try? change.document.data(as: Message.self) {
                            DispatchQueue.main.async {
                                self.updateMessage(message: message, userId: otherUserId)
                            }
                        }
                    case .removed:
                        if let message = try? change.document.data(as: Message.self) {
                            DispatchQueue.main.async {
                                self.removeMessage(message: message, userId: otherUserId)
                            }
                        }
                    }
                }
                
                
                // Refresh UI here if needed
            }
    }
    
    // Helper methods to update or remove a message
    private func updateMessage(message: Message, userId: String) {
        DispatchQueue.main.async {
            if let index = self.messages[userId]?.firstIndex(where: { $0.id == message.id }) {
                if message.messageType == .image || message.messageType == .video || message.messageType == .audio {
                    self.messages[userId]?[index].isUploaded = message.isUploaded
                    self.messages[userId]?[index].hasBeenRead = message.hasBeenRead
                    self.messages[userId]?[index].isDeleted = message.isDeleted
                    self.messages[userId]?[index].mediaURL = message.mediaURL
                } else {
                    self.messages[userId]?[index] = message
                }
            } else {
                self.messages[userId]?.append(message)
            }
        }
    }
    
    
    private func removeMessage(message: Message, userId: String) {
        messages[userId]?.removeAll(where: { $0.id == message.id })
    }
    
    func loadMoreMessages(for otherUserId: String) {
        guard !isLoadingOlderMessages else {
            print("Already loading old messages")
            return
        }
        
        if reachedBeginningOfChatHistory[otherUserId] ?? false {
            print("Reached beginning of chat history")
            return
        }
        
        isLoadingOlderMessages = true
        guard let currentMessages = messages[otherUserId], !currentMessages.isEmpty else {
            print("No existing messages for this conversation.")
            return
        }
        
        let earliestTimestamp = currentMessages.first?.timestamp
        let conversationId = currentMessages.first?.conversationId
        // Query Firestore for 20 messages before the earliest message
        db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: true)
            .start(after: [earliestTimestamp])
            .limit(to: 30)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching previous messages: \(error)")
                    self.isLoadingOlderMessages = false
                    return
                }
                
                guard let newDocuments = querySnapshot?.documents else {
                    print("Error: No new documents found")
                    self.isLoadingOlderMessages = false
                    return
                }
                
                guard let newDocuments = querySnapshot?.documents, !newDocuments.isEmpty else {
                    reachedBeginningOfChatHistory[otherUserId] = true
                    self.isLoadingOlderMessages = false
                    return
                }
                
                let newMessages = newDocuments.reversed().compactMap { document -> Message? in
                    return try? document.data(as: Message.self)
                }
                
                if newMessages.count < 30 {
                    self.reachedBeginningOfChatHistory[otherUserId] = true
                }
                
                DispatchQueue.main.async {
                    // Prepend these new messages to the existing ones in the dictionary
                    for message in newMessages {
                        // Check if the message is not already marked as read
                        if !message.hasBeenRead && message.receiverId == self.clientUser?.id {
                            // Update the local message object
                            var updatedMessage = message
                            updatedMessage.hasBeenRead = true
                            
                            // Update the message in Firestore
                            if let messageId = updatedMessage.id {
                                let messageRef = self.db.collection("messages").document(messageId)
                                messageRef.updateData(["hasBeenRead": true]) { error in
                                    if let error = error {
                                        print("Error marking message \(messageId) as read: \(error)")
                                    } else {
                                        print("Message \(messageId) successfully marked as read")
                                    }
                                }
                            }
                        }
                    }
                    self.messages[otherUserId] = newMessages + currentMessages
                    self.isLoadingOlderMessages = false
                    // Handle any UI updates here
                }
            }
    }
    
}

