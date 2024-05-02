//
//  Like.swift
//  Tandy
//
//  Created by Luke Thompson on 13/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct NoteLike: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var noteId: String
    var likerId: String
    var timestamp: Date
    
    static func == (lhs: NoteLike, rhs: NoteLike) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(noteId)
        hasher.combine(likerId)
    }

}


struct NoteLikeSnapshot: Equatable {
    let noteLike: NoteLike
    let snapshot: DocumentSnapshot

    static func == (lhs: NoteLikeSnapshot, rhs: NoteLikeSnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.noteLike == rhs.noteLike && lhs.snapshot == rhs.snapshot
    }
}
