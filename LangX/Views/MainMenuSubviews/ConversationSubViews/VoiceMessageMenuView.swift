//
//  VoiceMessageMenuView.swift
//  Tandy
//
//  Created by Luke Thompson on 26/11/2023.
//

import SwiftUI

struct VoiceMessageMenuView: View {
    @State private var isRecording = false
    @State private var hasRecorded = false
    @State private var isPlaying = false

    var body: some View {
        VStack {
            if hasRecorded {
                // Horizontal stack for buttons
                HStack {
                    // Play/Pause Button
                    Button(action: togglePlayPause) {
                        Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }

                    // Send Message Button
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                    }

                    // Record Another Message Button
                    Button(action: recordAnotherMessage) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary)
                .cornerRadius(10)
                .shadow(radius: 5)
            } else {
                // Record Button with Microphone Symbol
                Button(action: {}) {
                    Image(systemName: isRecording ? "mic.fill" : "mic")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text(isRecording ? NSLocalizedString("Recording", comment: "Recording") : NSLocalizedString("Hold to record", comment: "Hold to record"))
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isRecording ? Color.red : Color.blue)
                .cornerRadius(10)
                .onLongPressGesture(minimumDuration: 0.1, pressing: { isPressing in
                    if isPressing {
                        startRecording()
                    } else if isRecording {
                        stopRecording()
                        hasRecorded = true
                    }
                }, perform: {})
            }
        }
        .padding()
        .background(Color.secondary)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func togglePlayPause() {
        isPlaying.toggle()
        // Logic to play or pause the recorded message
    }

    private func sendMessage() {
        // Logic to send the recorded message
        hasRecorded = false // Reset after sending
    }

    private func recordAnotherMessage() {
        // Logic to start a new recording
        hasRecorded = false
    }

    private func startRecording() {
        isRecording = true
    }

    private func stopRecording() {
        isRecording = false
    }}
