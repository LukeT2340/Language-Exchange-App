//
//  ModifyNotification.swift
//  Tandy
//
//  Created by Luke Thompson on 7/1/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AudioToolbox

// Modify Notifications
extension MainService {
    func updateBadgeCount() {
        UIApplication.shared.applicationIconBadgeNumber = self.totalUnreadMessages
    }
    
    func updateNotificationCount() {
        // Update the user's notification count
        if let userId = clientUser?.id {
            let userRef = db.collection("users").document(userId)
            userRef.getDocument { documentSnapshot, error in
                if let document = documentSnapshot, var data = document.data() {
                    userRef.updateData(["notifications": self.totalUnreadMessages]) { error in
                        if let error = error {
                            print("Error updating notifications count: \(error)")
                        } else {
                            print("Notifications count updated successfully")
                        }
                    }
                }
            }
        }
    }
}
