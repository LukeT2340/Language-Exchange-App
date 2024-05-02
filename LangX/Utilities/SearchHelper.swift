//
//  SearchHelper.swift
//  Tandy
//
//  Created by Luke Thompson on 26/12/2023.
//

import FirebaseFirestore

// Used to search for other users on the app
class SearchHelper: ObservableObject {
    private var db = Firestore.firestore()
    @Published var users: [User] = []
    @Published var isLoadingUsers = false
    @Published var searchText = ""
    
    // Search for users with name or id that contains the searchText
    func searchUsers() {
        if isLoadingUsers {
            return
        }
        isLoadingUsers = true
        users = []
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmedSearchText.isEmpty else {
            isLoadingUsers = false
            return
        }

        let searchTextLowercased = trimmedSearchText.lowercased()
        let endOfSearchText = searchTextLowercased + "\u{f8ff}"

        // Set a limit for the number of results
        let resultsLimit = 8

        // Query for names with limit
        let nameQuery = db.collection("users")
            .whereField("name_lower", isGreaterThanOrEqualTo: searchTextLowercased)
            .whereField("name_lower", isLessThan: endOfSearchText)
            .limit(to: resultsLimit)

        // Query for user IDs that start with the search text, with limit
        let idQuery = db.collection("users")
            .whereField("id", isGreaterThanOrEqualTo: searchTextLowercased)
            .whereField("id", isLessThan: endOfSearchText)
            .limit(to: resultsLimit)

        // Perform both queries
        let group = DispatchGroup()
        var users = [User]()
        var seenUserIds = Set<String>()

        group.enter()
        fetchUsers(from: nameQuery) { fetchedUsers in
            for user in fetchedUsers where !seenUserIds.contains(user.id) {
                users.append(user)
                seenUserIds.insert(user.id)
            }
            group.leave()
        }

        group.enter()
        fetchUsers(from: idQuery) { fetchedUsers in
            for user in fetchedUsers where !seenUserIds.contains(user.id) {
                users.append(user)
                seenUserIds.insert(user.id)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            self.users.append(contentsOf: users)
            self.isLoadingUsers = false
        }
    }

    // Used by the searchUsers function to query specific fields in the users database.
    private func fetchUsers(from query: Query, completion: @escaping ([User]) -> Void) {
        query.getDocuments { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents, err == nil else {
                DispatchQueue.main.async {
                    self.isLoadingUsers = false
                }
                completion([])
                return
            }

            let users = documents.compactMap { document in
                try? document.data(as: User.self)
            }
            completion(users)
        }
    }

}
