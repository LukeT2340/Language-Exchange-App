//
//  RecommendedViewModel.swift
//  LanguageApp
//
//  Created by Luke Thompson on 23/11/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore

// Used to fetch recommended and followed users.
class PeopleService: ObservableObject {
    @Published var recommendedUsers: [User] = []
    @Published var followedUsers: [User] = []
    @Published var searchText: String = ""
    @Published var searchLanguages: [String] = []
    @Published var isLoadingUsers = false
    private var db = Firestore.firestore()
    private var clientUser: User? = nil
    
    // Fetches recommended users
    func fetchRecommendedUsers() {
        isLoadingUsers = true
        var query: Query = db.collection("users")

        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)

        // If the user has ended text into the search field, we find users based on this text. Else we search for users based off of the searched languages
        if !trimmedSearchText.isEmpty {
            let searchTextLowercased = trimmedSearchText.lowercased()
            let endOfSearchText = searchTextLowercased + "\u{f8ff}"
            query = query.whereField("name_lower", isGreaterThanOrEqualTo: searchTextLowercased)
                         .whereField("name_lower", isLessThan: endOfSearchText)
        } else if !searchLanguages.isEmpty {
            query = query.whereField("nativeLanguages", arrayContainsAny: searchLanguages)
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
                self.isLoadingUsers = false
                
            }
        }
    }
    
    // Used to fetch users that the client user is following
    func fetchFollowedUsers() {
        guard let clientUser = clientUser else {
             print("Client user is not available")
             return
         }

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

             self.followedUsers.removeAll()

             for document in documents {
                 let followedUserId = document.data()["followedUserId"] as? String ?? ""
                 
                 self.db.collection("users").document(followedUserId).getDocument { (userSnapshot, userError) in
                     guard let snapshot = userSnapshot, snapshot.exists,
                           let updatedClientUser = try? snapshot.data(as: User.self) else {
                         print("Client user document snapshot is nil or doesn't exist.")
                         return
                     }

                     DispatchQueue.main.async {
                         self.followedUsers.append(updatedClientUser)
                     }
                 }
             }
         }
     }
}
