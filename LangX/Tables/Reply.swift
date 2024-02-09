//
//  Reply.swift
//  Tandy
//
//  Created by Luke Thompson on 14/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct Reply: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var commentId: String
    var replierId: String
    var likeCount: Int
    var mentionId: String?
    var reportCount: Int
    var replyText: String
    var timestamp: Date
    
    static func == (lhs: Reply, rhs: Reply) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(commentId)
        hasher.combine(replierId)
        hasher.combine(timestamp)
    }
}

struct ReplySnapshot: Equatable {
    let reply: Reply
    let snapshot: DocumentSnapshot

    static func == (lhs: ReplySnapshot, rhs: ReplySnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.reply == rhs.reply && lhs.snapshot == rhs.snapshot
    }
}
