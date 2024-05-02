//
//  Conversation.swift
//  LangLeap
//
//  Created by Luke Thompson on 17/11/2023.
//

import SwiftUI
import FirebaseFirestore

// Defines a conversation between users
struct Conversation: Codable, Identifiable {
    @DocumentID var id: String?
    var participants: [String]  // Array of user IDs
    var timestamp: Date  // Timestamp of the latest message or conversation update
    
    init(id: String? = nil, participants: [String], timestamp: Date) {
        self.id = id
        self.participants = participants
        self.timestamp = timestamp
    }
    
}

extension Conversation: Equatable {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        // Define what makes two Conversation instances "equal"
        // This could be based on a unique identifier or a combination of properties
        return lhs.id == rhs.id
    }
}

extension Conversation {
    var dictionary: [String: Any] {
        return [
            "participants": participants,
            "timestamp": timestamp
        ]
    }
}
