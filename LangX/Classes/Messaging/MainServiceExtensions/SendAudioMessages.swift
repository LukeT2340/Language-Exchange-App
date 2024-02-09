//
//  SendAudioMessages.swift
//  Tandy
//
//  Created by Luke Thompson on 10/1/2024.
//

import SwiftUI
import AudioToolbox
import AVFoundation

extension MainService {
    func sendAudioMessage(with localURL: URL, duration: TimeInterval?) {
        guard let clientUser = clientUser else {
            return
        }
        guard let receiverId = chattingWithUserId else {
            return
        }
        guard let conversationId = chattingInConversationId else {
            return
        }
        guard let duration = duration else {
            return
        }
        var tempMessage = createTemporaryAudioMessage(localAudioURL: localURL, duration: duration, senderId: clientUser.id, receiverId: receiverId, conversationId: conversationId)
        messages[receiverId]?.append(tempMessage)
        uploadAudio(url: localURL) {result in
            switch result {
            case .success(let url):
                let documentRef = self.db.collection("messages").document(tempMessage.id ?? UUID().uuidString)
                tempMessage.id = documentRef.documentID
                if let index = self.messages[receiverId]?.firstIndex(where: { $0.localAudioURL == localURL}) {
                    self.messages[receiverId]?[index].id = tempMessage.id
                }
                tempMessage.localAudioURL = nil
                tempMessage.mediaURL = url
                do {
                    try documentRef.setData(from: tempMessage) { [weak self] error in
                        guard let self = self else { return }
                        if let error = error {
                            print("Error sending message: \(error.localizedDescription)")
                            return
                        }
                        
                        // Mark as uploaded
                        documentRef.updateData(["isUploaded": true]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                } catch {
                    print("Error setting data: \(error.localizedDescription)")
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func createTemporaryAudioMessage(localAudioURL: URL, duration: TimeInterval, senderId: String, receiverId: String, conversationId: String) -> Message {
        return Message(
            id: UUID().uuidString,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: Date(),
            conversationId: conversationId,
            hasBeenRead: false,
            messageType: .audio,
            localAudioURL: localAudioURL,
            duration: duration,
            isUploaded: false
            )
    }
    
    func uploadAudio(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
          let audioRef = storage.child("audios/\(url.lastPathComponent)")

          // Upload the file
          let uploadTask = audioRef.putFile(from: url, metadata: nil) { metadata, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }

              audioRef.downloadURL { url, error in
                  if let error = error {
                      completion(.failure(error))
                  } else if let url = url {
                      completion(.success(url))
                  }
              }
          }

    }
}
