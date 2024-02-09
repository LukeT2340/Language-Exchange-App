//
//  SendImagesAndVideos.swift
//  Tandy
//
//  Created by Luke Thompson on 10/1/2024.
//

import SwiftUI
import AudioToolbox
import Photos
import TLPhotoPicker
import AVFoundation

extension MainService {
    func createTemporaryImageMessage(image: UIImage, senderId: String, receiverId: String, conversationId: String) -> Message {
        return Message(
            id: UUID().uuidString,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: Date(),
            conversationId: conversationId,
            hasBeenRead: false,
            messageType: .image,
            temporaryImage: image,
            isUploaded: false
        )
    }
    
    func createTemporaryVideoMessage(thumbnail: UIImage, senderId: String, receiverId: String, conversationId: String) -> Message {
        return Message(
            id: UUID().uuidString,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: Date(),
            conversationId: conversationId,
            hasBeenRead: false,
            messageType: .video,
            temporaryImage: thumbnail,
            isUploaded: false
            )
    }
    
    func sendMedia(asset: TLPHAsset) {
        guard let clientUser = clientUser,
              let chattingWithUserId = chattingWithUserId,
              let chattingInConversationId = chattingInConversationId else {
            return
        }
        if asset.type == .photo {
            getUIImage(from: asset) { [weak self] image in
                guard let self = self, let image = image else { return }
                let tempMessage = self.createTemporaryImageMessage(
                    image: image,
                    senderId: clientUser.id,
                    receiverId: chattingWithUserId,
                    conversationId: chattingInConversationId
                )
                self.messages[chattingWithUserId]?.append(tempMessage)
                self.uploadImageAndUpdateMessage(image, for: tempMessage)
            }
        } else if asset.type == .video {
            getThumbnailImage(for: asset) {[weak self] image in
                guard let self = self, let image = image else { return }
                var tempMessage = self.createTemporaryVideoMessage(
                    thumbnail: image,
                    senderId: clientUser.id,
                    receiverId: chattingWithUserId,
                    conversationId: chattingInConversationId
                )
                self.messages[chattingWithUserId]?.append(tempMessage)
                self.uploadThumbnail(image) { result in
                    switch result {
                    case .success(let thumbnailURL):
                        tempMessage.thumbnailURL = thumbnailURL
                        self.getVideoURL(from: asset) { localURL in
                            if let localURL = localURL {
                                self.uploadVideo(url: localURL) { result in
                                    switch result {
                                    case .success(let url):
                                        self.updateMessage(message: tempMessage, withMediaURL: url)
                                    case .failure(let error):
                                        print("Error uploading video: \(error.localizedDescription)")
                                        // Handle the error case
                                        // Add upload failed in the future
                                    }
                                }
                            } else {
                                print("Failed to generate local file url")
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func getVideoURL(from asset: TLPHAsset, completion: @escaping (URL?) -> Void) {
        guard let phAsset = asset.phAsset else {
            completion(nil)
            return
        }

        if phAsset.mediaType == .video {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { (avAsset, _, _) in
                guard let urlAsset = avAsset as? AVURLAsset else {
                    completion(nil)
                    return
                }

                // Copy the video file to the app's directory
                let fileManager = FileManager.default
                let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentDirectory.appendingPathComponent(urlAsset.url.lastPathComponent)

                do {
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        try fileManager.removeItem(at: destinationURL)
                    }
                    try fileManager.copyItem(at: urlAsset.url, to: destinationURL)
                    completion(destinationURL) // Return the new URL
                } catch {
                    print("Error copying file: \(error)")
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }


    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        compressVideo(sourceUrl: url) { result in
            switch result {
            case .success(let compressedUrl):
                // Now upload compressedUrl to Firebase
                let videoRef = self.storage.child("videos/\(UUID().uuidString).mov")

                videoRef.putFile(from: compressedUrl, metadata: nil) { metadata, error in
                    guard let metadata = metadata else {
                        completion(.failure(error ?? NSError(domain: "uploadError", code: -1, userInfo: nil)))
                        return
                    }
                    
                    videoRef.downloadURL { (downloadURL, error) in
                        if let downloadURL = downloadURL {
                            completion(.success(downloadURL))
                        } else {
                            completion(.failure(error ?? NSError(domain: "downloadURLerror", code: -1, userInfo: nil)))
                        }
                    }
                }
            case .failure(let error):
                print("Video compression error: \(error.localizedDescription)")
                // Handle compression error
            }
        }

    }
    
    func uploadImageAndUpdateMessage(_ image: UIImage, for message: Message) {
        if let imageData = image.jpegData(compressionQuality: 0.4) {
            uploadImageData(imageData) { result in
                switch result {
                case .success(let url):
                    self.updateMessage(message: message, withMediaURL: url)
                case .failure(let error):
                    print(error)
                    // Handle the error
                }
            }
        }
    }
    
    func uploadThumbnail(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.4) {
            uploadImageData(imageData) { result in
                completion(result)
            }
        }
    }

    func compressVideo(sourceUrl: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let asset = AVAsset(url: sourceUrl)

        // Generate a unique filename for the output
        let uniqueFileName = UUID().uuidString + ".mov"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let outputUrl = documentDirectory.appendingPathComponent(uniqueFileName)

        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {
            completion(.failure(NSError(domain: "CompressionError", code: -1, userInfo: nil)))
            return
        }

        exportSession.outputURL = outputUrl
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                guard let outputUrl = exportSession.outputURL else {
                    completion(.failure(NSError(domain: "CompressionError", code: -1, userInfo: nil)))
                    return
                }
                completion(.success(outputUrl))
            case .failed, .cancelled:
                completion(.failure(exportSession.error ?? NSError(domain: "CompressionError", code: -1, userInfo: nil)))
            default:
                break
            }
        }
    }

    
    func updateMessage(message: Message, withMediaURL url: URL) {
        var updatedMessage = message
        updatedMessage.mediaURL = url
        
        // Determine the document reference
        let documentRef = db.collection("messages").document(updatedMessage.id ?? UUID().uuidString)


        updatedMessage.id = documentRef.documentID
        if let index = self.messages[message.receiverId]?.firstIndex(where: { $0.temporaryImage == message.temporaryImage }) {
            self.messages[message.receiverId]?[index].id = updatedMessage.id
        }

        // Update Firestore and local messages array
        do {
            try documentRef.setData(from: updatedMessage) { [weak self] error in
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
    }




    func uploadImageData(_ imageData: Data, completion: @escaping (Result<URL, Error>) -> Void) {
        // Define the path in the storage
        let imageId = UUID().uuidString
        let imageRef = storage.child("images/\(imageId).jpg")

        // Perform the upload
        let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                // Handle the error
                completion(.failure(error ?? NSError(domain: "uploadError", code: -1, userInfo: nil)))
                return
            }

            // Retrieve the download URL
            imageRef.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                }
            }
        }

        // Optionally, you can monitor the upload progress
        // uploadTask.observe(.progress) { snapshot in
        //     // Update progress UI here if needed
        // }
    }
    
    func getUIImage(from asset: TLPHAsset, completion: @escaping (UIImage?) -> Void) {
        guard let phAsset = asset.phAsset else {
            completion(nil)
            return
        }

        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true // Allow access to iCloud photos
        options.deliveryMode = .highQualityFormat // Request the high-quality image
        options.isSynchronous = false // Asynchronous loading

        // Use a reasonable target size instead of the full resolution to save memory
        let targetSize = CGSize(width: 1024, height: 1024)
        
        // Add a progress handler if needed
        options.progressHandler = { progress, error, stop, info in
            DispatchQueue.main.async {
                // Update UI with progress information
                // progress is a Double indicating the progress of the download (0.0 to 1.0)
            }
        }

        manager.requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, info in
            // Check if the image was delivered or if there's an error
            let isDegraded = (info?[PHImageResultIsDegradedKey] as? Bool) ?? false
            if isDegraded {
                // The returned 'image' is a low-res 'degraded' image and a high-res image will be delivered later.
                return
            }
            if let error = info?[PHImageErrorKey] as? Error {
                print("Error loading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Call the completion handler with the image
            completion(image)
        }
    }
    
    func getThumbnailImage(for asset: TLPHAsset, completion: @escaping (UIImage?) -> Void) {
        guard let phAsset = asset.phAsset else {
            completion(nil)
            return
        }

        if phAsset.mediaType == .video {
            let manager = PHImageManager.default()
            let options = PHVideoRequestOptions()
            options.version = .current
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat

            // Request the thumbnail image.
            manager.requestAVAsset(forVideo: phAsset, options: options) { (avAsset, audioMix, info) in
                if let avAsset = avAsset as? AVURLAsset {
                    let generator = AVAssetImageGenerator(asset: avAsset)
                    generator.appliesPreferredTrackTransform = true

                    let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
                    do {
                        let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                        let image = UIImage(cgImage: imageRef)
                        DispatchQueue.main.async {
                            completion(image)
                        }
                    } catch {
                        print("Error generating thumbnail: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        } else {
            // If it's not a video, you can handle accordingly.
            completion(nil)
        }
    }
}
