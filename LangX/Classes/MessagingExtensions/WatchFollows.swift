//
//  watchFollows.swift
//  Tandy
//
//  Created by Luke Thompson on 8/1/2024.
//

import Foundation
import AudioToolbox
import SwiftUI

// WatchFollows
extension MainService {
    func setupFollowListener() {
        guard let clientUser = clientUser else {
            return
        }
        let collection = db.collection("follows")

        // Listen only for new documents added to the collection
        followerListener = collection
            .whereField("followedUserId", isEqualTo: clientUser.id)
            .whereField("hasBeenSeen", isEqualTo: false)
                              .addSnapshotListener { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for follows updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            for document in snapshot.documents {
                guard let newFollow = try? document.data(as: Follow.self) else {
                    print("Error parsing follow document: \(document)")
                    continue
                }

                // Handle the new follow
                self.handleNewFollow(newFollow)
            }
        }
    }

    private func handleNewFollow(_ follow: Follow) {
        let usersCollection = db.collection("users")

        usersCollection.document(follow.followerUserId).getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            do {
                let user = try document.data(as: User.self)
                if !self.followedById.contains(user.id) {
                    self.followedById.append(user.id)
                    self.unseenFollows.append(follow)
                    self.fetchUserAndSetupListener(withId: follow.followerUserId)
                    if self.selectedTab != .home {
                        self.banners.append(Banner(
                            id: UUID().uuidString,
                            title: String(format: NSLocalizedString("NewFollow", comment: ""), user.name),
                            text: String(format: NSLocalizedString("NewFollowText", comment: ""), user.name),
                            linkType: .follow,
                            timeStamp: Date(),
                            otherUserId: user.id
                        ))
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            self.banners.removeFirst()
                        }
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
}
