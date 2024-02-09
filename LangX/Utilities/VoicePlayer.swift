//
//  VoicePlayer.swift
//  Tandy
//
//  Created by Luke Thompson on 10/1/2024.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

class VoicePlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var playingMessageId: String?
    private var audioPlayer: AVAudioPlayer?
    
    func playAudio(from url: URL, messageId: String) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)
            
            // Initialize the audio player with the URL
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            DispatchQueue.main.async {
                // Ensure you update the UI or `@Published` properties on the main thread
                self.playingMessageId = messageId
            }

            // Start playing the audio
            audioPlayer?.play()
        } catch {
            print("Failed to initialize the audio player: \(error.localizedDescription)")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        self.playingMessageId = nil
    }
    
    // Implement the AVAudioPlayerDelegate methods if needed
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playingMessageId = nil
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        // Handle the audio playback error
        if let error = error {
            print("Audio playback error: \(error.localizedDescription)")
        }
    }
    
    func downloadAudioFile(from url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let downloadTask = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server"])))
                return
            }

            guard let localURL = localURL else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Local file URL is nil"])))
                return
            }

            // Move the file to a permanent location in your app's sandbox container
            do {
                let fileManager = FileManager.default
                let documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let savedURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
                try? fileManager.removeItem(at: savedURL) // Remove existing file if any
                try fileManager.moveItem(at: localURL, to: savedURL)
                completion(.success(savedURL))
            } catch {
                completion(.failure(error))
            }
        }

        downloadTask.resume()
    }
    
    func transcribeAudio(audioData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = "AIzaSyDclQzW6i3KEY_nCZp9aZ9ZkLsLuaC1Oo8"
        let url = URL(string: "https://speech.googleapis.com/v1/speech:recognize?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "config": [
                "encoding": "LINEAR16",
                "sampleRateHertz": 16000,
                "languageCode": "en-US",
            ],
            "audio": [
                "content": audioData.base64EncodedString()
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }

                do {
                    // Parse the JSON response
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let results = jsonResponse["results"] as? [[String: Any]],
                       let firstResult = results.first,
                       let alternatives = firstResult["alternatives"] as? [[String: Any]],
                       let transcript = alternatives.first?["transcript"] as? String {
                        // Return the transcribed text
                        completion(.success(transcript))
                    } else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
