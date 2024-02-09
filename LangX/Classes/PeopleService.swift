//
//  RecommendedViewModel.swift
//  LanguageApp
//
//  Created by Luke Thompson on 23/11/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore

class PeopleService: ObservableObject {
    var authManager: AuthManager
    @Published var recommendedUsers: [User] = []
    @Published var followedUsers: [User] = []
    @Published var searchText: String = ""
    private var db = Firestore.firestore()
    private var clientUser: User? = nil // changed
    private var targetLanguages: [String] = []
    
    init(authManager: AuthManager) {
        self.authManager = authManager
    }
    
    func fetchRecommendedUsers() {
        var query: Query = db.collection("users")

        // Trim leading and trailing spaces from searchText
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)

        if !trimmedSearchText.isEmpty {
            let searchTextLowercased = trimmedSearchText.lowercased()
            let endOfSearchText = searchTextLowercased + "\u{f8ff}"
            query = query.whereField("name_lower", isGreaterThanOrEqualTo: searchTextLowercased)
                         .whereField("name_lower", isLessThan: endOfSearchText)
        } else {
            query = query.whereField("nativeLanguages", arrayContainsAny: self.targetLanguages)
        }

        query.limit(to: 20).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                return
            }
            
            var users: [User] = []
            for document in querySnapshot!.documents {
                do {
                    let user = try document.data(as: User.self)
                    users.append(user)
                } catch let error {
                    print("Error decoding user: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.recommendedUsers = users
            }
        }
    }
    
    func fetchFollowedUsers() {
        guard let clientUser = clientUser else {
             print("Client user is not available")
             return
         }

         // Fetch follow relationships where clientUser is the follower
         db.collection("follows")
            .whereField("followerUserId", isEqualTo: clientUser.id)
           .getDocuments { [weak self] (snapshot, error) in
             guard let self = self else { return }
             if let error = error {
                 print("Error getting follows: \(error.localizedDescription)")
                 return
             }

             guard let documents = snapshot?.documents else {
                 print("No follows found")
                 return
             }

             // Clear the current followedUsers array
             self.followedUsers.removeAll()

             // Fetch each followed user's data
             for document in documents {
                 let followedUserId = document.data()["followedUserId"] as? String ?? ""
                 
                 // Fetch the user profile for each followed user
                 self.db.collection("users").document(followedUserId).getDocument { (userSnapshot, userError) in
                     guard let snapshot = userSnapshot, snapshot.exists,
                           let updatedClientUser = try? snapshot.data(as: User.self) else {
                         print("Client user document snapshot is nil or doesn't exist.")
                         return
                     }
                     // Update the clientUser object
                     DispatchQueue.main.async {
                         self.followedUsers.append(updatedClientUser)
                     }
                 }
             }
         }
     }
}
