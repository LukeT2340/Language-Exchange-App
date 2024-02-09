//
//  VoiceInputView.swift
//  Tandy
//
//  Created by Luke Thompson on 5/1/2024.
//

import SwiftUI
import Kingfisher
import AVFoundation
import AVKit
import Foundation

struct VoiceInputView: View {
    @StateObject private var voiceRecorder = VoiceRecorder()
    @ObservedObject var mainService: MainService
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    @State private var recordingSetupFailed = false
    
    var body: some View {
        
        HStack(spacing: 15) {
            Button(action: {
                mainService.showingVoiceMessageUI = false
            }) {
                Image(systemName: "keyboard")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 21))
                    .frame(width: 25)
                    .padding(.leading)
            }
            if let recordingURL = voiceRecorder.lastRecordingURL, !voiceRecorder.isRecording {
            // Playback controls, Send and Cancel buttons
                Button(action: {
                    if voiceRecorder.isPlaying {
                        voiceRecorder.stopPlaying()
                    } else {
                        voiceRecorder.playRecording()
                    }
                }) {
                    Image(systemName: voiceRecorder.isPlaying ? "stop.fill" : "play.circle")
                        .font(.system(size: 15))
                        .foregroundColor(voiceRecorder.isPlaying ? .red : .green)
                    Text(voiceRecorder.isPlaying ? NSLocalizedString("Stop-Audio-Playback", comment: "Stop audio playback") : NSLocalizedString("Playback-Audio", comment: "Playback audio"))
                        .font(.system(size: 15))
                        .foregroundColor(.black)

                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 45)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .padding(.top, 5)

                // Send button
                Button(action: {
                    let duration = voiceRecorder.getAudioDuration(url: recordingURL)
                    mainService.sendAudioMessage(with: recordingURL, duration: voiceRecorder.lastRecordingDuration)
                    voiceRecorder.lastRecordingURL = nil
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .padding(.trailing)
                }
                
            } else {
                Button(action: {}) {
                    Image(systemName: voiceRecorder.isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                    Text(voiceRecorder.isRecording ? NSLocalizedString("Recording", comment: "Recording") : NSLocalizedString("Hold to record", comment: "Hold to record"))
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 45)
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onLongPressGesture(minimumDuration: 1, pressing: { isPressing in
                    if isPressing {
                        voiceRecorder.startRecording()
                    } else if voiceRecorder.isRecording {
                        voiceRecorder.stopRecording()
                    }
                }, perform: {})
                .padding(.top, 5)

                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .padding(.trailing)
                    .hidden()

            }
        }
        .animation(.easeInOut, value: voiceRecorder.lastRecordingURL)

    }
}
