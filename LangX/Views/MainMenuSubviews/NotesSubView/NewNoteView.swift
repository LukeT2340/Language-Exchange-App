//
//  NewNoteView.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import AVFoundation
import AVKit
import UIKit

/*
struct NewNoteView: View {
    @ObservedObject var noteService: NoteService
    @ObservedObject var messageService: MessageService
    @ObservedObject var userService: UserService
    @EnvironmentObject var authManager: AuthManager
    
    @State private var noteTitle = ""
    @State private var noteText = ""
    @State private var showingMediaPicker = false
    @State private var selectedMediaURLs: [URL] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideo: IdentifiableVideo?
    @State private var publishAsPublic = true
    @State private var privacyOption = PrivacyOption.public_option // Default value
    @State private var publishingNote = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            headerSection
            ScrollView {
                VStack(spacing: 16) { // Use spacing to add more room between sections
                    
                    titleSection
                        .padding(.horizontal) // Apply padding to the whole section
                    
                    mediaSection
                        .padding(.horizontal)
                    
                    bodySection
                        .padding(.horizontal)
                    
                    publishButton
                }
                .padding(.top) // Add padding to the top of the content
            }
            
        }
        .sheet(isPresented: $showingMediaPicker) {
            MediaPicker(selectedMediaURLs: $selectedMediaURLs, selectedImages: $selectedImages)
        }
        .sheet(item: $selectedVideo) { video in
            FullScreenVideoPlayer(url: video.url)
        }
        .navigationBarHidden(true)
    }
    
    var privacyPicker: some View {
        Menu {
            Picker("Privacy", selection: $privacyOption) {
                Text(PrivacyOption.public_option.localized).tag(PrivacyOption.public_option)
                Text(PrivacyOption.private_option.localized).tag(PrivacyOption.private_option)
            }
        } label: {
            HStack {
                Text(privacyOption.localized)
                Image(systemName: "chevron.down")
            }
            .frame(minWidth: 0, maxWidth: 280)
            .padding()
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
            .shadow(color: .black.opacity(0.5), radius: 4, x: -2, y: -2)
            .background(Color(red: 0.39, green: 0.58, blue: 0.93))
            .cornerRadius(40)
            .font(.body)
        }
    }
    
    var headerSection: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .padding()
            }
            
            Spacer()
            
            Image(systemName: "ellipsis")
                .imageScale(.large)
                .padding()
        }
    }
    
    var titleSection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Title", comment: "Title"))
                .font(.headline)
                .padding(.vertical)
            
            TextField(NSLocalizedString("Title-Placeholder", comment: "Title"), text: $noteTitle)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 0.5)
                )
                .cornerRadius(8)
                .keyboardType(.webSearch)
        }
    }
    
    var mediaSection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Media", comment: "Media"))
                .font(.headline)
                .padding(.vertical)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    MediaPreview(selectedMediaURLs: selectedMediaURLs, selectedImages: selectedImages, selectedVideo: $selectedVideo)
                    Button(action: { showingMediaPicker = true }) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 112, height: 200)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title)
                            )
                    }
                }
            }
        }
    }
    
    var bodySection: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Body", comment: "Body"))
                .font(.headline)
                .padding(.vertical)
            
            TextEditor(text: $noteText)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 0.5)
                )
                .cornerRadius(8)
                .frame(minHeight: 200)
        }
    }
    
    var publishButton: some View {
        HStack {
            privacyPicker
                .padding(.horizontal)
                .onChange(of: privacyOption) { newValue in
                    publishAsPublic = (newValue == .public_option)
                }
            
            Button(action: {
                publishingNote = true
                noteService.writeNote(
                    authorId: userService.clientUser.id,
                    nativeLanguages: userService.clientUser.nativeLanguages,
                    title: noteTitle,
                    textContent: noteText,
                    isPublic: publishAsPublic,
                    localMediaURLs: selectedMediaURLs
                ) { resultNote in
                    // Resetting the UI state after publishing
                    noteTitle = ""
                    selectedMediaURLs = []
                    selectedImages = []
                    noteText = ""
                    publishingNote = false
                }
            }) {
                if !publishingNote {
                    Text(NSLocalizedString("Publish", comment: "Publish"))
                        .buttonStyle()
                } else {
                    ProgressView()
                        .frame(minWidth: 0, maxWidth: 280)
                        .padding()
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                        .shadow(color: .black.opacity(0.5), radius: 4, x: -2, y: -2) // Added contrasting shadow
                        .background(Color(red: 0.39, green: 0.58, blue: 0.93))
                        .cornerRadius(40)
                        .font(.body)
                }
                
            }
            .disabled(publishingNote)
        }
        .padding(.vertical)
    }

}

enum PrivacyOption {
    case public_option
    case private_option
    
    var localized: String {
        switch self {
        case .public_option:
            return NSLocalizedString("Public", comment: "Public")
        case .private_option:
            return NSLocalizedString("Private", comment: "Private")
        }
    }
}

struct IdentifiableVideo: Identifiable {
    let id = UUID() // Unique identifier
    let url: URL
}

enum MediaType {
    case audio, image, video, none
}

// Custom media picker to handle audio and video selection
struct MediaPicker: UIViewControllerRepresentable {
    @Binding var selectedMediaURLs: [URL]
    @Binding var selectedImages: [UIImage]
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: MediaPicker
        
        init(_ parent: MediaPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Handling images
            if let image = info[.originalImage] as? UIImage {
                if let imageUrl = saveImageLocally(image) {
                    parent.selectedMediaURLs.append(imageUrl)
                }
                parent.selectedImages.append(image)
            }
            
            // Handling videos
            if let url = info[.mediaURL] as? URL {
                parent.selectedMediaURLs.append(url)
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        private func saveImageLocally(_ image: UIImage) -> URL? {
            guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else { return nil }
            let filename = getDocumentsDirectory().appendingPathComponent("\(UUID().uuidString).jpg")
            
            do {
                try data.write(to: filename)
                return filename
            } catch {
                print("Error saving image: \(error.localizedDescription)")
                return nil
            }
        }
        
        private func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
}

struct MediaPreview: View {
    var selectedMediaURLs: [URL]
    var selectedImages: [UIImage]
    @Binding var selectedVideo: IdentifiableVideo?
    
    var body: some View {
        HStack {
            ForEach(selectedImages, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.horizontal, 5)
                    .cornerRadius(15)
            }
            
            ForEach(selectedMediaURLs, id: \.self) { url in
                if url.isVideo {
                    VideoPreview(url: url)
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.horizontal, 5)
                        .cornerRadius(15)
                        .onTapGesture {
                            selectedVideo = IdentifiableVideo(url: url)
                        }
                }
            }
        }
        
    }
}


struct FullScreenVideoPlayer: View {
    var url: URL
    @State private var player: AVPlayer
    
    init(url: URL) {
        self.url = url
        self._player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                configureAudioSession()
                player.play()
            }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
}

struct VideoPreview: View {
    var url: URL
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        Group {
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .scaledToFit()
                    .overlay(PlayButtonOverlay(), alignment: .center)
            } else {
                Color.gray // Placeholder for when there is no thumbnail
            }
        }
        .onAppear {
            thumbnailImage = generateThumbnail(for: url)
        }
    }
    
    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print("Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}

struct PlayButtonOverlay: View {
    var body: some View {
        Image(systemName: "play.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .foregroundColor(.white)
    }
}


extension URL {
    var isVideo: Bool {
        // Create an asset and access its tracks
        let asset = AVAsset(url: self)
        let tracks = asset.tracks(withMediaType: .video)

        // Check if there are video tracks
        return !tracks.isEmpty
    }
}
*/
