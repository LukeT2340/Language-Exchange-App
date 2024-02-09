//
//  Note.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import FirebaseFirestore

struct Note: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var authorId: String
    var authorNativeLanguages: [String]
    var title: String
    var textContent: String
    var tags: [String]
    var location: String?
    var likeCount: Int
    var commentCount: Int
    var reportCount: Int
    var mentionedUserIDs: [String]
    var timestamp: Date
    var isPublic: Bool
    var mediaURLs: [URL]

    static func ==(lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(textContent)
        hasher.combine(authorId)
        hasher.combine(timestamp)
    }

}


struct NoteSnapshot: Equatable {
    let note: Note
    let snapshot: DocumentSnapshot

    static func == (lhs: NoteSnapshot, rhs: NoteSnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.note == rhs.note && lhs.snapshot == rhs.snapshot
    }
}
