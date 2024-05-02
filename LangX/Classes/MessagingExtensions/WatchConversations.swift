//
//  WatchConversations.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// WatchConversations
extension MainService {
    func fetch10RecentConversations(for clientUserId: String, completion: @escaping ([Conversation]) -> Void) {
        print("fetch10recentconversations called")
        // Assuming there's a 'conversations' collection which contains a 'lastMessage' subcollection or field
        let conversationsRef = db.collection("conversations")
        
        // Define the query to fetch conversations where the clientUserId is a participant and order by the last message timestamp
        let query = conversationsRef
            .whereField("participants", arrayContains: clientUserId)
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching conversations: \(error)")
                completion([])
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion([])
                return
            }
            
            var fetchedConversations = [Conversation]()
            for document in documents {
                do {
                    // Assuming you have a Conversation model that is Codable
                    let conversation = try document.data(as: Conversation.self)
                    fetchedConversations.append(conversation)
                } catch {
                    print("Error decoding conversation: \(error)")
                }
            }
            
            completion(fetchedConversations)
        }
    }
    
    func setupConversationsListener(for clientUserId: String) {
        print("Setting up listener for new conversations")
        conversationsListener = db.collection("conversations")
            .whereField("participants", arrayContains: clientUserId)
            .whereField("timestamp", isGreaterThan: initializationTimestamp)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                for document in documents {
                    do {
                        let conversation = try document.data(as: Conversation.self)
                        self.handleConversation(conversation, clientUserId: clientUserId)
                    } catch {
                        print("Error decoding conversation: \(error)")
                    }
                }
            }
    }
    
    private func handleConversation(_ conversation: Conversation, clientUserId: String) {
        print("Handling conversation")
        let participants = conversation.participants
        
        for participantId in participants where participantId != clientUserId {
            // Check if the participant is not already being processed and is not in otherUsers
            self.fetchUserAndSetupListener(withId: participantId)
            if let conversationId = conversation.id {
                self.fetchRecent30MessagesAndListenForUpdates(conversationId: conversationId, otherUserId: participantId) {_ in}
            }
        }
    }
    
    
}
