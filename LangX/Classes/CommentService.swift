//
//  CommentService.swift
//  Tandy
//
//  Created by Luke Thompson on 14/12/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

class CommentService: ObservableObject {
    @Published var comments: [NoteComment] = []
    @Published var userInformation: [String: User] = [:]
    @Published var hasLikedComment: [String: Bool] = [:]
    @Published var isLikingComment = false
    @Published var keyboardText: String = ""
    @Published var isCommenting = false
    private var db = Firestore.firestore()
    private var clientUserId: String
    private var noteId: String
    
    init (clientUserId: String, noteId: String) {
        self.clientUserId = clientUserId
        self.noteId = noteId
    }
    
    func fetchComments() {
        db.collection("noteComments")
            .whereField("noteId", isEqualTo: noteId)
            .order(by: "likeCount", descending: true)
            .limit(to: 20)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting comments: \(error)")
                } else {
                    if let snapshot = querySnapshot {
                        DispatchQueue.main.async {
                            self.comments = snapshot.documents.compactMap { document in
                                try? document.data(as: NoteComment.self)
                            }
                            self.fetchUserInformation()
                            self.fetchLikesStatus()
                        }
                    }
                }
            }
    }
    
    private func fetchLikesStatus() {
        let noteLikesRef = db.collection("commentLikes").whereField("likerId", isEqualTo: clientUserId)

        noteLikesRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let err = err {
                print("Error getting likes: \(err)")
            } else {
                // Reset the hasLikedNote dictionary
                self.hasLikedComment = [:]

                // Iterate through each document in the snapshot
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let commentId = data["commentId"] as? String {
                        // Set the like status for each note
                        self.hasLikedComment[commentId] = true
                    }
                }

                // Update the UI by calling a method to refresh the view, if necessary
            }
        }
    }
    
    func fetchUserInformation() {
        let userIds = Set(comments.map { $0.commenterId })
        for userId in userIds {
            db.collection("users").document(userId).getDocument { (document, error) in
                if let document = document, let user = try? document.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.userInformation[userId] = user
                    }
                }
            }
        }
    }
    
    func submitComment() {
        let trimmedString = keyboardText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString == "" {
            return
        }
        isCommenting = true
        let timestamp = Timestamp(date: Date())

        // Prepare the data for the new comment
        let newCommentData: [String: Any] = [
            "noteId": noteId,
            "commenterId": clientUserId,
            "commentText": trimmedString,
            "likeCount": 0,
            "mentionedUserIDs": [String](),
            "reportCount": 0,
            "timestamp": timestamp
        ]

        // Add a new document to the 'noteComments' collection
        var ref: DocumentReference? = nil
        ref = self.db.collection("noteComments").addDocument(data: newCommentData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Error adding comment: \(error)")
                self.isCommenting = false
                // Handle the error appropriately
            } else {
                print("Comment successfully added")

                // Create a NoteComment object with the Firestore-generated ID
                let newComment = NoteComment(
                    id: ref?.documentID, // Use the Firestore-generated ID
                    noteId: self.noteId,
                    commenterId: self.clientUserId,
                    likeCount: 0,
                    mentionedUserIDs: [],
                    reportCount: 0,
                    commentText: trimmedString,
                    timestamp: timestamp.dateValue()
                )

                DispatchQueue.main.async {
                    self.comments.insert(newComment, at: 0) // Adding to the top of the list
                    self.keyboardText = "" // Resetting the comment text
                    self.isCommenting = false
                    self.fetchUserInformation()
                }
            }
        }
    }
    
    func likeComment(commentId: String) {
        guard !isLikingComment else { return }
        isLikingComment = true
        self.hasLikedComment[commentId] = true
        if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                self.comments[index].likeCount += 1
            }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("commentLikes")
                             .whereField("commentId", isEqualTo: noteId)
                             .whereField("likerId", isEqualTo: clientUserId)

        noteLikeRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, documents.isEmpty {
                // No existing like found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Create a new like
                    let newLikeRef = db.collection("commentLikes").document()
                    transaction.setData(["commentId": commentId, "likerId": self.clientUserId], forDocument: newLikeRef)

                    // Increment the likes count on the note
                    let noteRef = db.collection("noteComments").document(commentId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingComment = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedComment[commentId] = false
                        if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                                self.comments[index].likeCount -= 1
                            }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingComment = false
                print("User has already liked this note or an error occurred.")
            }
        }
    }

    func unlikeComment(commentId: String) {
        guard !isLikingComment else { return }
        isLikingComment = true
        self.hasLikedComment[commentId] = false
        // Decrement the local like count
        if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
            self.comments[index].likeCount -= 1
        }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("commentLikes")
                             .whereField("commentId", isEqualTo: commentId)
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
                    let noteRef = db.collection("noteComments").document(commentId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(-1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingComment = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedComment[commentId] = true
                        // Decrement the local like count
                        if let index = self.comments.firstIndex(where: { $0.id == commentId }) {
                            self.comments[index].likeCount += 1
                        }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingComment = false
                print("User has not liked this note or an error occurred.")
            }
        }
    }
    
}
