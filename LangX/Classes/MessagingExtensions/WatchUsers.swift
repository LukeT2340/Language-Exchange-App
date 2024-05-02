//
//  WatchUsers.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// WatchUsers
extension MainService {
    func setupClientUserListener(for clientUserId: String) {
        let clientUserDocumentRef = db.collection("users").document(clientUserId)
        
        clientUserListener = clientUserDocumentRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else {
                return
            }
            
            if let error = error {
                print("Error fetching client user data: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = documentSnapshot, snapshot.exists,
                  let updatedClientUser = try? snapshot.data(as: User.self) else {
                print("Client user document snapshot is nil or doesn't exist.")
                return
            }
            
            // Update the clientUser object
            DispatchQueue.main.async {
                self.clientUser = updatedClientUser
                if self.searchingForPartner {
                    self.searchForPartner()
                }
            }
        }
    }
    
    func fetchUserAndSetupListener(withId userId: String) {
        print("Fetching user and setting up listener")
        if !otherUsers.contains(where: { $0.id == userId }) {
            let userDocRef = db.collection("users").document(userId)
            
            // Fetch the initial user data
            userDocRef.getDocument { [weak self] (document, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }
                
                if let document = document, document.exists, let user = try? document.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.otherUsers.append(user)
                        self.messages[user.id] = []
                        print("User '\(user.name)' found and stored")
                    }
                } else {
                    print("User document does not exist.")
                }
            }
            
            // Setup a listener for updates to the user's document
            let listener = userDocRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
                guard let self = self, let snapshot = documentSnapshot, snapshot.exists, let updatedUser = try? snapshot.data(as: User.self) else {
                    print("Error listening for user updates: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                
                DispatchQueue.main.async {
                    if let index = self.otherUsers.firstIndex(where: { $0.id == updatedUser.id }) {
                        self.otherUsers[index] = updatedUser
                        print("User '\(updatedUser.name)' updated")
                    } else {
                        self.otherUsers.append(updatedUser)
                    }
                }
            }
            
            // Store the listener in the dictionary
            userListeners[userId] = listener
        } else {
            print("User already fetched and stored")
        }
    }
    
    
}
