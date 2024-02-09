//
//  File.swift
//  Tandy
//
//  Created by Luke Thompson on 26/11/2023.
//

import FirebaseFirestore

class UserService: ObservableObject {
    private var userDocumentListeners: [ListenerRegistration] = []
    private var clientUserListener: ListenerRegistration? = nil
    private var db = Firestore.firestore()
    @Published var clientUser: User
    @Published var otherUsers: [String: User] = [:]

    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian"]
    
    init(clientUser: User) {
        self.clientUser = clientUser
        print(clientUser.name)
        findOtherUsersFromConversations()
        setupClientUserListener()
    }

    func findOtherUsersFromConversations() {
        db.collection("conversations")
          .whereField("participants", arrayContains: clientUser.id)
          .getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let documents = querySnapshot?.documents else {
                print("Error fetching conversations: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            for document in documents {
                let conversationId = document.documentID
                let participants = document.get("participants") as? [String] ?? []
                if let otherUserId = participants.first(where: { $0 != self.clientUser.id }) {
                    self.setupListener(for: otherUserId, in: conversationId)
                }
            }
        }
    }
    
    private func setupClientUserListener() {
        let clientUserDocumentRef = db.collection("users").document(clientUser.id)

        clientUserListener = clientUserDocumentRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }

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
            }
        }
    }

    private func setupListener(for userId: String, in conversationId: String) {
        let userDocumentRef = db.collection("users").document(userId)
        let listener = userDocumentRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user data for user \(userId): \(error.localizedDescription)")
                return
            }

            guard let snapshot = documentSnapshot, snapshot.exists,
                  let updatedUser = try? snapshot.data(as: User.self) else {
                print("User document snapshot for user \(userId) is nil or doesn't exist.")
                return
            }

            // Update the other user in the dictionary
            DispatchQueue.main.async {
                self.otherUsers[conversationId] = updatedUser
            }
        }
        userDocumentListeners.append(listener)
    }
    
    deinit {
        // Remove the clientUser listener
        clientUserListener?.remove()
        
        // Remove other listeners
        userDocumentListeners.forEach { $0.remove() }
    }

}
