//
//  Follow.swift
//  Tandy
//
//  Created by Luke Thompson on 4/1/2024.
//

import SwiftUI
import FirebaseFirestore

struct Follow: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var followedUserId: String
    var followerUserId: String
    var hasBeenSeen: Bool
    var timestamp: Date
    
    static func == (lhs: Follow, rhs: Follow) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        // Add properties to the hasher that should determine uniqueness
        hasher.combine(followedUserId)
        hasher.combine(followerUserId)
    }

}


struct FollowSnapshot: Equatable {
    let follow: Follow
    let snapshot: DocumentSnapshot

    static func == (lhs: FollowSnapshot, rhs: FollowSnapshot) -> Bool {
        // Implement the equality check here based on your requirements.
        // For example, you can compare the message objects.
        return lhs.follow == rhs.follow && lhs.snapshot == rhs.snapshot
    }
}
