//
//  NoteService.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

class NoteService: ObservableObject {
    @Published var users: [User] = []
    @Published var hasLikedNote: [String: Bool] = [:]
    @Published var notes: [Note] = []
    @Published var isLikingNote = false
    @Published var isLoadingNotes = false
    private var db = Firestore.firestore()
    private var lastFetchedDocument: DocumentSnapshot?
    
    
    /*
    func likeNote(noteId: String) {
        guard !isLikingNote else { return }
        isLikingNote = true
        self.hasLikedNote[noteId] = true
        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                self.notes[index].likeCount += 1
            }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("noteLikes")
                             .whereField("noteId", isEqualTo: noteId)
                             .whereField("likerId", isEqualTo: clientUserId)

        noteLikeRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, documents.isEmpty {
                // No existing like found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Create a new like
                    let newLikeRef = db.collection("noteLikes").document()
                    transaction.setData(["noteId": noteId, "likerId": self.clientUserId], forDocument: newLikeRef)

                    // Increment the likes count on the note
                    let noteRef = db.collection("notes").document(noteId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingNote = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedNote[noteId] = false
                        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                                self.notes[index].likeCount -= 1
                            }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingNote = false
                print("User has already liked this note or an error occurred.")
            }
        }
    }

    func unlikeNote(noteId: String) {
        guard !isLikingNote else { return }
        isLikingNote = true
        self.hasLikedNote[noteId] = false
        // Decrement the local like count
        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
            self.notes[index].likeCount -= 1
        }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("noteLikes")
                             .whereField("noteId", isEqualTo: noteId)
                             .whereField("likerId", isEqualTo: clientUserId)

        noteLikeRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Existing like found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Remove the like
                    let likeRef = documents.first!.reference
                    transaction.deleteDocument(likeRef)

                    // Decrement the likes count on the note
                    let noteRef = db.collection("notes").document(noteId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(-1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingNote = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedNote[noteId] = true
                        // Decrement the local like count
                        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                            self.notes[index].likeCount += 1
                        }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingNote = false
                print("User has not liked this note or an error occurred.")
            }
        }
    }
     */
}
