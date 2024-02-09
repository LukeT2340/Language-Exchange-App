//
//  ChatView2.swift
//  Tandy
//
//  Created by Luke Thompson on 16/12/2023.
//

import SwiftUI
import FirebaseFirestore
import AVKit
import TLPhotoPicker
import Photos

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct ImageView: View {
    let asset: PHAsset
    
    var body: some View {
        // Use PHAsset to generate an image view
        ImageLoaderView(asset: asset, targetSize: CGSize(width: 1000, height: 1000))
    }
}

struct CustomTLPhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedAssets: [TLPHAsset] // TLPHAsset represents selected items
    
    func makeUIViewController(context: Context) -> TLPhotosPickerViewController {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = context.coordinator
        
        // Configure the picker settings
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = true
        configure.allowedLivePhotos = true
        configure.allowedVideoRecording = false
        configure.maxSelectedAssets = 10 // Adjust as needed
        
        viewController.configure = configure
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: TLPhotosPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TLPhotosPickerViewControllerDelegate {
        var parent: CustomTLPhotoPicker
        
        init(_ parent: CustomTLPhotoPicker) {
            self.parent = parent
        }
        
        func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
            // Update your selected assets here
            parent.selectedAssets = withTLPHAssets
            parent.isPresented = false
            return true
        }
        
        // Implement other delegate methods as needed
    }
}

// Custom view to generate and display a video thumbnail
struct VideoThumbnailView: View {
    let asset: PHAsset
    @State private var thumbnailImage: UIImage?
    
    var body: some View {
        Group {
            if let thumbnailImage = thumbnailImage {
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        ToSendPlayButtonOverlay(),
                        alignment: .center
                    )
            } else {
                ProgressView() // Show a loader or placeholder
            }
        }
        .onAppear(perform: loadThumbnail)
    }
    
    private func loadThumbnail() {
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        
        manager.requestAVAsset(forVideo: asset, options: options) { (avAsset, _, _) in
            if let avAsset = avAsset {
                let generator = AVAssetImageGenerator(asset: avAsset)
                generator.appliesPreferredTrackTransform = true
                let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
                
                DispatchQueue.global().async {
                    do {
                        let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
                        let thumbnail = UIImage(cgImage: imageRef)
                        DispatchQueue.main.async {
                            self.thumbnailImage = thumbnail
                        }
                    } catch {
                        print("Error generating thumbnail: \(error)")
                    }
                }
            }
        }
    }
}

struct ImageLoaderView: View {
    let asset: PHAsset
    let targetSize: CGSize
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView() // Show a loader or placeholder
            }
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        
        manager.requestImage(for: asset,
                             targetSize: targetSize,
                             contentMode: .aspectFit,
                             options: options) { image, _ in
            self.uiImage = image
        }
    }
}

struct ToSendPlayButtonOverlay: View {
    var body: some View {
        Image(systemName: "play.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .foregroundColor(.white)
    }
}


/*
 if let conversationMessages = messageService.messages[conversationId] {
 ForEach(Array(conversationMessages.enumerated()), id: \.element.message.id) { index, messageTuple in
 let message = messageTuple.message
 if !message.isDeleted {
 let previousMessage = (index > 0) ? conversationMessages[index - 1].message : nil
 let showTimestamp = messageHelperModel.shouldShowTimestamp(currentMessage: message, previousMessage: previousMessage)
 let messageCount = conversationMessages.count
 //let messageCount = conversationMessages.count
 if showTimestamp {
 Text(messageHelperModel.formatDate(message.timestamp))
 .font(.footnote)
 .foregroundColor(.gray)
 }
 if let messageId = message.id {
 MessageView2(messageHelperModel: messageHelperModel, messageService: messageService, audioRecorderPlayer: audioRecorderPlayer, messageId: messageId, conversationId: conversationId, isCurrentUser: message.senderId == authManager.currentUser?.uid, showTimestamp: showTimestamp,
 profileImageURL: message.senderId == authManager.currentUser?.uid
 ? userService.clientUser.profileImageUrl
 : userService.otherUsers[conversationId]?.profileImageUrl ?? URL(fileURLWithPath: ""), isMostRecentMessage: index == messageCount - 1, activeMenuMessageId: $activeMenuMessageId).transition(.opacity)
 
 }
 }
 */
