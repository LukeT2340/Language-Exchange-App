//
//  NoteComment.swift
//  Tandy
//
//  Created by Luke Thompson on 14/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct NoteComment: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var noteId: String
    var commenterId: String
    var likeCount: Int
    var mentionedUserIDs: [String]
    var reportCount: Int
    var commentText: String
    var timestamp: Date
    
    static func == (lhs: NoteComment, rhs: NoteComment) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(noteId)
        hasher.combine(commenterId)
        hasher.combine(timestamp)
    }

}


struct NoteCommentSnapshot: Equatable {
    let noteComment: NoteComment
    let snapshot: DocumentSnapshot

    static func == (lhs: NoteCommentSnapshot, rhs: NoteCommentSnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.noteComment == rhs.noteComment && lhs.snapshot == rhs.snapshot
    }
}
