//
//  FetchClientUser.swift
//  LangX
//
//  Created by Luke Thompson on 13/1/2024.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

extension MainService {
    func fetchClient(completion: @escaping (User) -> Void) {
        guard let userId = authManager.firebaseUser?.uid else {
            print("No current user logged in")
            return
        }

        db.collection("users").document(userId).getDocument { [weak self] (document, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    return
                }

                if let document = document {
                    if document.exists {
                        do {
                            let fetchedUser = try document.data(as: User.self)
                            completion(fetchedUser)
                            print("User details fetched")
                        } catch {
                            print("Error decoding user: \(error)")
                        }
                    } else {
                        print("User document does not exist")
                    }
                } else {
                    print("Document snapshot is nil")
                }

            }
        }
    }

}
