//
//  Check and Create Conversations.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// Check/Create conversation
extension MainService {
    func ensureConversationExists(with otherUserId: String, completion: @escaping (Bool, Conversation?) -> Void) {
        guard let currentUserId = authManager.firebaseUser?.uid else {
            completion(false, nil)
            return
        }
        
        // Query the 'conversations' collection
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    completion(false, nil)
                } else {
                    var conversationFound: Conversation? = nil
                    for document in snapshot!.documents {
                        let conversation = try? document.data(as: Conversation.self)
                        if let conversation = conversation, conversation.participants.contains(otherUserId) {
                            conversationFound = conversation
                            break
                        }
                    }
                    
                    if let conversation = conversationFound {
                        // Conversation exists
                        if let conversationId = conversation.id {
                            self?.chattingInConversationId = conversationId
                            print("Set current conversation Id to \(self?.chattingInConversationId)")
                        }
                        self?.chattingWithUserId = otherUserId
                        completion(true, conversation)
                    } else {
                        // Create new conversation
                        self?.createConversation(with: otherUserId, completion: completion)
                        self?.reachedBeginningOfChatHistory[otherUserId] = true
                    }
                }
            }
    }
    
    private func createConversation(with otherUserId: String, completion: @escaping (Bool, Conversation?) -> Void) {
        print("Creating conversation")
        guard let currentUserId = authManager.firebaseUser?.uid else {
            completion(false, nil)
            return
        }
        
        let newConversation = Conversation(participants: [currentUserId, otherUserId], timestamp: Date())
        var ref: DocumentReference? = nil
        ref = db.collection("conversations").addDocument(data: newConversation.dictionary) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(false, nil)
            } else {
                if let newId = ref?.documentID {
                    var createdConversation = newConversation
                    createdConversation.id = newId
                    self.chattingInConversationId = newId
                    print("Set current conversation Id to \(newId)")
                    self.chattingWithUserId = otherUserId
                    completion(true, createdConversation)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    func searchForPartner() {
        guard !searchingForPartner else {
            print("Already searching for partner")
            return
        }
        
        guard let clientId = clientUser?.id else {
            print("Client user ID is unavailable")
            return
        }
        
        let usersRef = db.collection("users")
        
        var systemMessageSent = false // Flag to track if the system message has been sent

        // Update searchingForPartner to true in Firestore for the client user
        usersRef.document(clientId).updateData(["searchingForPartner": true]) { error in
            if let error = error {
                print("Error updating client user: \(error.localizedDescription)")
                return
            }
            
            if let targetLanguageKeys = self.clientUser?.targetLanguages.keys {
                let targetLanguageArray: [String] = Array(targetLanguageKeys)
                
                self.languagePartnerListener = usersRef
                    .whereField("searchingForPartner", isEqualTo: true)
                    .whereField("nativeLanguages", arrayContainsAny: targetLanguageArray)
                    .addSnapshotListener { [weak self] querySnapshot, error in
                        guard let self = self else { return }
                        guard let documents = querySnapshot?.documents else {
                            print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                            self.updateSearchingForPartner(false, userId: clientId)
                            return
                        }
                        
                        let users = documents.compactMap { document -> User? in
                            try? document.data(as: User.self)
                        }

                        for user in users {
                            if !self.otherUsers.contains(where: { $0.id == user.id }) {
                                if clientId < user.id { // Alphabetical comparison
                                    DispatchQueue.main.async {
                                        self.ensureConversationExists(with: user.id) { [weak self] success, conversation in
                                            guard let self = self, let convId = conversation?.id, success else { return }
                                            self.chattingInConversationId = ""
                                            // Send the system message and update relevant flags
                                            self.sendStartConversationSystemMessage(receiverId: user.id, conversationId: convId)
                                            self.sendStartConversationSystemMessage(receiverId: clientId, conversationId: convId)
                                            self.removeUserListener()
                                            self.updateSearchingForPartner(false, userId: user.id)
                                            self.updateSearchingForPartner(false, userId: clientId)
                                        }
                                    }
                                    break // Exit the loop to prevent further iterations
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func stopSearchingForPartner() {
        guard let clientId = clientUser?.id else {
            print("Client user ID is unavailable")
            return
        }
        
        removeUserListener()
        updateSearchingForPartner(false, userId: clientId)
    }
    
    private func updateSearchingForPartner(_ searching: Bool, userId: String) {
        let usersRef = db.collection("users")
        usersRef.document(userId).updateData(["searchingForPartner": searching]) { error in
            if let error = error {
                print("Error updating client user: \(error.localizedDescription)")
            }
        }
    }
    
    func removeUserListener() {
        languagePartnerListener?.remove()
    }
    
}
