//
//  CommentLike.swift
//  Tandy
//
//  Created by Luke Thompson on 14/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct CommentLike: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var commentId: String
    var likerId: String
    var timestamp: Date
    
    static func == (lhs: CommentLike, rhs: CommentLike) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(commentId)
        hasher.combine(likerId)
    }
}

struct CommentLikeSnapshot: Equatable {
    let commentLike: CommentLike
    let snapshot: DocumentSnapshot

    static func == (lhs: CommentLikeSnapshot, rhs: CommentLikeSnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.commentLike == rhs.commentLike && lhs.snapshot == rhs.snapshot
    }
}
