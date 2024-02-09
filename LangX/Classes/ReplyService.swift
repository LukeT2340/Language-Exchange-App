//
//  ReplyService.swift
//  Tandy
//
//  Created by Luke Thompson on 14/12/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

class ReplyService: ObservableObject {
    @Published var replies: [Reply] = []
    private var db = Firestore.firestore()
    private var clientUserId: String
    var isSubmittingReply = false

    init (clientUserId: String) {
        self.clientUserId = clientUserId
    }
    
    func submitReply(commentId: String, replyText: String, completion: @escaping (Bool, Error?) -> Void) {
        isSubmittingReply = true

        // Prepare the data for the new reply
        let newReplyData: [String: Any] = [
            "commentId": commentId,
            "replierId": clientUserId,
            "likeCount": 0,
            "mentionId": "", // Modify as needed
            "reportCount": 0,
            "replyText": replyText,
            "timestamp": Timestamp(date: Date())
        ]

        // Add a new document to the 'replies' collection
        db.collection("replies").addDocument(data: newReplyData) { [weak self] error in
            guard let self = self else { return }

            self.isSubmittingReply = false
            if let error = error {
                print("Error adding reply: \(error)")
                completion(false, error)
            } else {
                print("Reply successfully added")
                completion(true, nil)
            }
        }
    }
}
