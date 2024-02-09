//
//  AudioManager.swift
//  languageapp
//
//  Created by Luke Thompson on 24/11/2023.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

class VoiceRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    private var recordingsDirectory: URL?

    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var lastRecordingURL: URL?
    @Published var lastRecordingDuration: TimeInterval?

    func startRecording() {
        let recordingName = "\(UUID().uuidString).m4a"
          let filePath = getDocumentsDirectory().appendingPathComponent(recordingName)

          let settings = [
              AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
              AVSampleRateKey: 44100,
              AVNumberOfChannelsKey: 1,
              AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
          ] as [String: Any]

          do {
              let audioSession = AVAudioSession.sharedInstance()
              try audioSession.setCategory(.playAndRecord, mode: .default)
              try audioSession.setActive(true)

              audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
              audioRecorder?.prepareToRecord()
              audioRecorder?.record()
              isRecording = true
              print("Simplified recording started")

          } catch {
              print("Simplified recording failed: \(error)")
          }
      }

    func setupRecorder(completion: @escaping (Bool) -> Void) {
        let recordingName = "\(Date().timeIntervalSince1970).m4a"
        let filePath = getDocumentsDirectory().appendingPathComponent(recordingName)

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String: Any]

        do {
            audioRecorder = try AVAudioRecorder(url: filePath, settings: settings)
            audioRecorder?.prepareToRecord()
            completion(true)
        } catch {
            print("Failed to set up the audio recorder: \(error)")
            completion(false)
        }
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        lastRecordingURL = audioRecorder?.url
        
        // Debug: Check the file immediately after recording
        if let url = lastRecordingURL {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attributes[.size] as? UInt64
                let duration = getAudioDuration(url: url)
                if duration < 1 || duration > 60 {
                    print("duration too long or too short")
                    lastRecordingURL = nil
                } else {
                    lastRecordingDuration = duration
                }
                print("File size after recording: \(fileSize ?? 0) bytes")
            } catch {
                print("Error getting file size: \(error)")
            }
        }
    }
        
    func playRecording() {
        guard let url = lastRecordingURL else {
            print("No recording URL found")
            return
        }

        // Debug: Check the file size
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? UInt64
            print("File size: \(fileSize ?? 0) bytes")
        } catch {
            print("Error getting file size: \(error)")
        }

        // Debug: Check the audio duration
        let duration = getAudioDuration(url: url)
        print("Audio Duration: \(duration) seconds")

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Playback failed: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            audioPlayer?.stop()
           isPlaying = false
       }

    func stopPlaying() {
        audioPlayer?.stop()
        isPlaying = false
    }

    func getAudioDuration(url: URL) -> TimeInterval {
        let asset = AVAsset(url: url)
        return CMTimeGetSeconds(asset.duration)
    }
}

