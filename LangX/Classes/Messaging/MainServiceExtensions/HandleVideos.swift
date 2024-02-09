//
//  HandleVideos.swift
//  Tandy
//
//  Created by Luke Thompson on 9/1/2024.
//

import Foundation

extension MainService {
    func downloadVideo(videoURL: URL, messageId: String?, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let messageId = messageId else {
            print("Error: messageId is nil")
            completion(.failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Message ID is nil"])))
            return
        }

        let fileName = messageId + "-" + videoURL.lastPathComponent
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: localURL.path) {
            print("Video already downloaded at \(localURL.path)")
            completion(.success(localURL))
            return
        }

        let configuration = URLSessionConfiguration.default
        let customSession = URLSession(configuration: configuration)

        let downloadTask = customSession.downloadTask(with: videoURL) { tempLocalURL, _, error in
            DispatchQueue.main.async {
                if let tempLocalURL = tempLocalURL {
                    do {
                        let uniqueTempURL = documentDirectory.appendingPathComponent(UUID().uuidString + ".tmp")
                        try FileManager.default.moveItem(at: tempLocalURL, to: uniqueTempURL)
                        try FileManager.default.moveItem(at: uniqueTempURL, to: localURL)
                        print("Download completed and file moved to \(localURL.path)")
                        completion(.success(localURL))
                    } catch {
                        print("Failed to move downloaded file: \(error)")
                        completion(.failure(error))
                    }
                } else if let error = error {
                    print("Download failed: \(error)")
                    completion(.failure(error))
                } else {
                    print("Download failed: Unknown error")
                    completion(.failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred during download"])))
                }
            }
        }

        downloadTask.resume()
    }



    
    func hasBeenDownloaded(videoURL: URL, messageId: String?, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let messageId = messageId else {
            return
        }
        let fileName = messageId + "-" + videoURL.lastPathComponent
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: localURL.path) {
            print("Video already downloaded for message ID: \(messageId).")
            completion(.success(localURL))
        } else {
            print("Video not downloaded for message ID: \(messageId).")
            completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Video file not found locally."])))
        }
    }
}
