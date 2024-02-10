//
//  MessageView.swift
//  Tandy
//
//  Created by Luke Thompson on 5/1/2024.
//

import SwiftUI
import Kingfisher
import AVFoundation
import AVKit
import Foundation

struct MessageView: View {
    @ObservedObject var mainService: MainService
    @ObservedObject var voicePlayer: VoicePlayer
    @EnvironmentObject var authManager: AuthManager
    
    @State private var translation: String?
    @State private var showTranslation: Bool = false
    @State private var loadingTranslation: Bool = false
    @State private var downloadedLocalVideoURL: URL?
    @State private var downloadedLocalAudioURL: URL?
    @State private var downloadingVideo: Bool = false
    @State private var downloadingAudio: Bool = false
    @State private var showVideoPlayer = false
    @State private var showImagePlayer = false
    @State private var showMenu: Bool = false
    var clientUser: User
    var otherUser: User {
        mainService.otherUsers.first(where: { $0.id == otherUserId })!
    }
    var otherUserId: String
    var message: Message
    let showTimestamp: Bool
    
    var isCurrentUser: Bool
    var isLastMessage: Bool
    
    init (mainService: MainService, voicePlayer: VoicePlayer,message: Message, otherUserId: String, showTimestamp: Bool) {
        self.mainService = mainService
        self.voicePlayer = voicePlayer
        self.message = message
        self.clientUser = mainService.clientUser!
        self.otherUserId = otherUserId
        self.showTimestamp = showTimestamp
        self.isCurrentUser = message.senderId == clientUser.id
        self.isLastMessage = mainService.messages[otherUserId]?.last?.id == message.id ? true : false
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            timeStamp
            HStack (alignment: .top) {
                if !isCurrentUser && message.messageType != .system {
                    profilePicture
                }
                messageContent
                if isCurrentUser && message.messageType != .system  {
                    profilePicture
                }
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var profilePicture: some View {
        NavigationLink(destination: ProfileView(mainService: mainService, user: isCurrentUser ? clientUser : otherUser)) {
            AsyncImageView(url: isCurrentUser ? clientUser.profileImageUrl : otherUser.profileImageUrl)
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
        }
    }
    
    @ViewBuilder
    private var messageContent: some View {
        VStack (alignment: isCurrentUser ? .trailing : .leading) {
            if message.messageType == .system && message.receiverId == clientUser.id {
                //systemMessage
            } else if message.messageType == .text {
                textMessageBubble
            } else if message.messageType == .audio {
                audioMessageBubble
            } else if message.messageType == .image {
                image
            } else if message.messageType == .video {
                video
            }
            if isLastMessage && isCurrentUser && message.messageType != .system || message.messageType == .video && isCurrentUser && !message.isUploaded || message.messageType == .image && isCurrentUser && !message.isUploaded {
                messageStatus
            }
        }
    }
    
    private var menu: some View {
        HStack(spacing: 16) {
            MenuButton(title: "Copy", iconName: "doc.on.doc", action: {
                print("Copy tapped")
            })
            MenuButton(title: "Translate", iconName: "globe", action: {
                print("Translate tapped")
            })
            MenuButton(title: "Delete", iconName: "trash", action: {
                print("Delete tapped")
            })
        }
        .padding()
        .background(colorScheme == .dark
         ? (isCurrentUser ? Color(red: 44/255, green: 150/255, blue: 255/255) : Color.white.opacity(0.2))
         : (isCurrentUser ? Color(red: 44/255, green: 150/255, blue: 255/255) : Color.white)
                )
        .cornerRadius(12)
    }


    
    private var typingIndicator: some View {
        HStack {
            if isLastMessage && otherUser.isTyping {

                AsyncImageView(url: isCurrentUser ? clientUser.profileImageUrl : otherUser.profileImageUrl)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                TypingIndicatorView()
                    .frame(alignment: .leading)
            }
            Spacer()
        }
    }
    
    private var messageStatus: some View {
        HStack (spacing: 5) {
            switch message.isUploaded {
            case false:
                LoadingView()
            case true:
                switch message.hasBeenRead {
                case false:
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.accentColor)
                        
                    Text(NSLocalizedString("Sent", comment: "Sent"))
                        .font(.system(size: 12))
                        .italic()
                        .foregroundColor(Color.accentColor)
                case true:
                    AsyncImageView(url: otherUser.profileImageUrl)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 16, height: 16)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))

                    Text(NSLocalizedString("Read", comment: "Read"))
                        .font(.system(size: 12))
                        .italic()
                        .foregroundColor(Color.accentColor)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .animation(.easeInOut, value: message.hasBeenRead)
    }
    
    private var audioMessageBubble: some View {
        VStack {
            HStack {
                Image(systemName: voicePlayer.playingMessageId == message.id ? "speaker.wave.2.fill" : "speaker.fill")
                    .foregroundColor(
                        colorScheme == .dark
                        ? (.white)
                        : (isCurrentUser ? .white : .black)
                    )
                Text(String(Int(round(message.duration!))) + NSLocalizedString("Seconds", comment: "Seconds"))
                    .foregroundColor(
                        colorScheme == .dark
                        ? (.white)
                        : (isCurrentUser ? .white : .black)
                    )
                if downloadingAudio {
                    if isCurrentUser {
                        WhiteLoadingView()
                    } else {
                        LoadingView()
                    }
                }
            }
        }
        .padding(12)
        .background(
            colorScheme == .dark
            ? (isCurrentUser ? Color.accentColor : .white.opacity(0.2))
            : (isCurrentUser ? Color.accentColor : .white)
        )
        .foregroundColor(isCurrentUser ? .white : (colorScheme == .dark ? .white : .black))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(isCurrentUser ? .leading : .trailing, 48)
        .onTapGesture {
            if voicePlayer.playingMessageId == message.id {
                voicePlayer.stopAudio()
            } else {
                if let localURL = message.localAudioURL ?? downloadedLocalAudioURL {
                    voicePlayer.playAudio(from: localURL, messageId: message.id!)
                } else if let url = message.mediaURL {
                    downloadingAudio = true
                    voicePlayer.downloadAudioFile(from: url) { result in
                        downloadingAudio = false
                        switch result {
                        case .success(let localURL):
                            downloadedLocalAudioURL = localURL
                            voicePlayer.playAudio(from: localURL, messageId: message.id!)
                        case .failure(let error):
                            print("Error occurred: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: downloadingAudio)
        .animation(.easeInOut, value: downloadedLocalAudioURL)
    }
    
    private var image: some View {
        HStack {
            if let image = message.temporaryImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                KFImage(message.mediaURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            if let imageURL = message.mediaURL {
                NavigationLink(destination: CustomImageView(imageURL: imageURL),
                               isActive: $showImagePlayer) {
                    EmptyView()
                }
                               .hidden()
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .onTapGesture {
            if let imageURL = message.mediaURL {
                showImagePlayer = true
            }
        }
    }
    
    private var video: some View {
        ZStack {
            if let thumbnail = message.temporaryImage {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                if let thumbnailURL = message.thumbnailURL {
                    AsyncImageView(url: thumbnailURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            if message.isUploaded {
                if downloadingVideo {
                    DownloadingMediaView()
                } else {
                    Image(systemName: (downloadedLocalVideoURL != nil ? "play.circle" : "arrow.down.circle"))
                        .foregroundColor(.white)
                        .font(.system(size: 35))
                        .frame(width: 120, height: 120)
                }
            } else {
                Image(systemName : "arrow.up.doc")
                    .foregroundColor(.white)
                    .font(.system(size: 35))
                    .frame(width: 120, height: 120)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .onAppear {
            print("onAppear called")
            if let videoURL = message.mediaURL {
                print("Checking downloaded video")
                mainService.hasBeenDownloaded(videoURL: videoURL, messageId: message.id) { result in
                    switch result {
                    case .success(let url):
                        downloadedLocalVideoURL = url
                        print("Downloaded video found: \(url)")
                    case .failure(let error):
                        print("Error checking downloaded video: \(error)")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            if let downloadedLocalVideoURL = downloadedLocalVideoURL {
                AVPlayerViewRepresentable(videoURL: downloadedLocalVideoURL)
                                    .edgesIgnoringSafeArea(.all)
                                
            }
        }
        .onTapGesture {
            if downloadedLocalVideoURL == nil {
                if let videoURL = message.mediaURL {
                    downloadingVideo = true
                    mainService.downloadVideo(videoURL: videoURL, messageId: message.id) { result in
                        switch result {
                        case .success(let localURL):
                            downloadedLocalVideoURL = localURL
                            downloadingVideo = false
                        case .failure(_):
                            print("Error downloading video")
                            downloadingVideo = false
                        }
                    }
                }
            } else {
                showVideoPlayer = true
            }
        }
    }

    
    
    @ViewBuilder
    private var timeStamp: some View {
        if showTimestamp && message.messageType != .system {
            Text(formatDate(message.timestamp))
                .font(.footnote)
                .foregroundColor(.gray)
        }
    }
    
    private var systemMessage: some View {
        VStack (alignment: .center){
            Text(NSLocalizedString("New-Chat-Message", comment: "New chat message"))
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .padding()
            //userIntroduction
        }
        .frame(maxWidth: .infinity)
    }
    
    private var textMessageBubble: some View {
        VStack (alignment: .leading) {
            if let textContent = message.textContent {
                Text(textContent)
                    .foregroundColor(
                        colorScheme == .dark
                        ? (.white)
                        : (isCurrentUser ? .white : .black)
                    )
                if showTranslation {
                    if let translation = translation {
                        Divider()
                        Text(translation)
                    } else if loadingTranslation {
                        Divider()
                        if isCurrentUser {
                            WhiteLoadingView()
                        } else {
                            LoadingView()
                        }
                    }
                }
            }
            if showMenu {
                Divider()
                menu
            }
        }
        .padding(12)
        .background(
            colorScheme == .dark
            ? (isCurrentUser ? Color.accentColor : .white.opacity(0.2))
            : (isCurrentUser ? Color.accentColor : .white)
        )
        .foregroundColor(isCurrentUser ? .white : (colorScheme == .dark ? .white : .black))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
        .padding(isCurrentUser ? .leading : .trailing, 48)
        /*.onTapGesture {
            if !showTranslation && translation == nil {
                loadingTranslation = true
                self.showTranslation = true
                translateMessage(text: message.textContent!) { translatedText in
                    self.translation = translatedText
                    loadingTranslation = false
                }
            } else {
                showTranslation.toggle()
            }
        } */
        .onTapGesture {
            showMenu.toggle()
        }
        .animation(.easeInOut, value: showMenu)
        .animation(.easeInOut, value: showTranslation)
        }
    }


// Helper functions
extension MessageView {
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            let minutesAgo = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
            let hoursAgo = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0

            if minutesAgo < 2 {
                return NSLocalizedString("Just now", comment: "Just now")
            } else if minutesAgo < 60 {
                return "\(minutesAgo)" + NSLocalizedString("Minutes ago", comment: "Minutes ago")
            } else if hoursAgo < 12 {
                return "\(hoursAgo)" + NSLocalizedString("Hours ago", comment: "Hours ago")
            } else {
                dateFormatter.dateFormat = NSLocalizedString("h:mm a", comment: "Time format: 3:45 PM")
                return dateFormatter.string(from: date)
            }
        } else {
            if calendar.isDateInYesterday(date) {
                dateFormatter.dateFormat = NSLocalizedString("'Yesterday at' h:mm a", comment: "Time format: Yesterday at 3:45 PM")
            } else {
                dateFormatter.dateFormat = NSLocalizedString("MMM d, yyyy 'at' h:mm a", comment: "Date format: Jan 5, 2021 at 3:45 PM")
            }
            return dateFormatter.string(from: date)
        }
    }
    
    private func translateMessage(text: String, completion: @escaping (String?) -> Void) {
        let apiKey = "AIzaSyDclQzW6i3KEY_nCZp9aZ9ZkLsLuaC1Oo8"
        let url = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
        
        // Get the system language
        let systemLanguageCode = Locale.current.languageCode ?? "en" // Default to English if unable to determine
        
        let json: [String: Any] = [
            "q": text,
            "target": systemLanguageCode
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let responseData = json["data"] as? [String: Any],
               let translations = responseData["translations"] as? [[String: Any]],
               let firstTranslation = translations.first,
               let translatedText = firstTranslation["translatedText"] as? String {
                DispatchQueue.main.async {
                    completion(translatedText)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    func generateThumbnail(from videoURL: URL, at time: TimeInterval = 0, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let asset = AVAsset(url: videoURL)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)

        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.requestedTimeToleranceAfter = .zero
        assetImageGenerator.requestedTimeToleranceBefore = .zero

        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        assetImageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: cmTime)]) { _, cgImage, _, result, error in
            DispatchQueue.main.async {
                if let cgImage = cgImage, result == .succeeded {
                    let image = UIImage(cgImage: cgImage)
                    completion(.success(image))
                } else {
                    completion(.failure(error ?? NSError(domain: "ThumbnailGenerationError", code: -1, userInfo: nil)))
                }
            }
        }
    }

}

struct MenuRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .imageScale(.large)
                .frame(width: 32, height: 32)
            Text(title)
                .font(.system(size: 16, weight: .regular, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(.primary)
        .padding()
    }
}


struct MenuButton: View {
    var title: String
    var iconName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .imageScale(.large)
                Text(title)
                    .font(.system(size: 16))
            }
        }
        .foregroundColor(.primary)
    }
}
