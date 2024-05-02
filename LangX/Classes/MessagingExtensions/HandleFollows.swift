//
//  HandleFollows.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// Handle Follows
extension MainService {
    func isFollowing(followedUserId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let clientUser = clientUser else {
            print("client user not found")
            return
        }
        // Reference to the 'Follows' collection where follow relationships are stored
        let followsCollection = db.collection("follows")
        
        // Query for a specific follow relationship
        let query = followsCollection
            .whereField("followerUserId", isEqualTo: clientUser.id)
            .whereField("followedUserId", isEqualTo: followedUserId)
        
        // Perform the query
        query.getDocuments { snapshot, error in
            if let error = error {
                // If there's an error, pass it to the completion handler
                completion(false, error)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                // If we find a document, it means the clientUser is following the followedUserId
                completion(true, nil)
            } else {
                // No documents found, clientUser is not following the followedUserId
                completion(false, nil)
            }
        }
    }
    
    func follow(userId: String) {
        guard let clientUser = clientUser else {
            print("Client user not found")
            return
        }
        
        guard !processingFollow else { return }
        processingFollow = true
        
        let followsCollection = db.collection("follows")
        let followQuery = followsCollection
            .whereField("followerUserId", isEqualTo: clientUser.id)
            .whereField("followedUserId", isEqualTo: userId)
        
        followQuery.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, documents.isEmpty {
                // No existing follow found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Create a new follow
                    let newFollowRef = followsCollection.document()
                    transaction.setData(["followedUserId": userId, "followerUserId": clientUser.id, "timestamp": Date(), "hasBeenSeen": false], forDocument: newFollowRef)
                    
                    // Increment the follower count on the user
                    let userRef = self.db.collection("users").document(userId)
                    transaction.updateData(["followerCount": FieldValue.increment(Int64(1))], forDocument: userRef)
                    
                    return nil
                }) { _, error in
                    self.processingFollow = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.processingFollow = false
                print("User has already followed this person or an error occurred.")
            }
        }
    }
    
    
    
    func unfollow(userId: String) {
        guard let clientUser = clientUser else {
            print("Client user not found")
            return
        }
        
        guard !processingFollow else { return }
        processingFollow = true
        
        let followsCollection = db.collection("follows")
        let followQuery = followsCollection
            .whereField("followerUserId", isEqualTo: clientUser.id)
            .whereField("followedUserId", isEqualTo: userId)
        
        followQuery.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Follow relationship found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Attempt to delete the follow document
                    let followDocumentRef = documents.first!.reference
                    transaction.deleteDocument(followDocumentRef)
                    
                    // Decrement the follower count on the user
                    let userRef = self.db.collection("users").document(userId)
                    transaction.updateData(["followerCount": FieldValue.increment(Int64(-1))], forDocument: userRef)
                    
                    return nil
                }) { _, error in
                    self.processingFollow = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.processingFollow = false
                print("User has not followed this person or an error occurred.")
            }
        }
    }
    
}
