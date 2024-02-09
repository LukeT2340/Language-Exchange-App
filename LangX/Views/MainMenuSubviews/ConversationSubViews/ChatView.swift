//
//  ChatView.swift
//  Tandy
//
//  Created by Luke Thompson on 5/1/2024.
//

import SwiftUI
import FirebaseFirestore
import AVKit
import TLPhotoPicker
import Photos

struct ChatView: View {
    @StateObject private var messageHelperModel = MessageHelperModel()
    @StateObject var voicePlayer = VoicePlayer()
    @ObservedObject var mainService: MainService
    @EnvironmentObject var authManager: AuthManager
    
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    @State private var newMessageText: String = ""
    @State private var showingAdditionalOptions: Bool = true
    @State private var isShowingMediaPicker = false
    @State private var selectedAssets: [TLPHAsset] = []
    
    var otherUserId: String
    var otherUser: User {
        mainService.otherUsers.first(where: { $0.id == otherUserId })!
    }
    var messages: [Message]
    var lastOnlineText: String {
        let now = Date()
        let timeDifference = now.timeIntervalSince(otherUser.lastOnline)
        
        if timeDifference < 60 {
            return NSLocalizedString("Online", comment: "User is currently online")
        } else if timeDifference < 3600 { // Less than 1 hour
            let minutes = Int(timeDifference / 60)
            let minutesFormat = NSLocalizedString("minutes_ago", comment: "Time format for minutes ago")
            return String(format: minutesFormat, minutes)
        } else if timeDifference < 43200 { // Less than 12 hours
            let hours = Int(timeDifference / 3600)
            let hoursFormat = NSLocalizedString("hours_ago", comment: "Time format for hours ago")
            return String(format: hoursFormat, hours)
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: otherUser.lastOnline, relativeTo: now)
        }
    }
    
    
    init(mainService: MainService, otherUserId: String) {
        self.mainService = mainService
        self.otherUserId = otherUserId
        if let messages = mainService.messages[otherUserId] {
            self.messages = messages.reversed()
        } else {
            self.messages = []
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some View {
        VStack (spacing: 0){
            navigationBarView
            messagesView
            if mainService.showingVoiceMessageUI {
                VoiceInputView(mainService: mainService).environmentObject(authManager)
            } else {
                textInputView
            }
        }
        .fullScreenCover(isPresented: $isShowingMediaPicker) {
            CustomTLPhotoPicker(isPresented: $isShowingMediaPicker, selectedAssets: $selectedAssets)
        }
        .onAppear {
            if let messages = mainService.messages[otherUser.id] {
                if let lastMessage = messages.last {
                    mainService.chattingInConversationId = lastMessage.conversationId
                    mainService.chattingWithUserId = otherUser.id
                }
            }
            mainService.markMessagesAsRead(for: otherUser.id) { _ in}
        }
        .onDisappear {
            mainService.chattingInConversationId = nil
            mainService.chattingWithUserId = nil
            mainService.updateUserTypingStatus(isTyping: false)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if mainService.chattingInConversationId != nil {
                mainService.markMessagesAsRead(for: otherUser.id) { _ in}
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            mainService.updateUserTypingStatus(isTyping: false)
        }
        .onChange(of: selectedAssets) { _ in
            if !selectedAssets.isEmpty {
                for asset in selectedAssets {
                    mainService.sendMedia(asset: asset)
                }
            }
        }
        .animation(.easeInOut, value: mainService.messages[otherUser.id])
        .animation(.easeInOut, value: mainService.showingVoiceMessageUI)
        .cornerRadius(10)
        .navigationBarHidden(true)
    }
    
    private var navigationBarView: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor) // Consistent color for icons
            }
            .padding(.leading, 15)
            
            if mainService.totalUnreadMessages > 0 {
                Text("\(mainService.totalUnreadMessages)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
                        
            Spacer()
            
            NavigationLink(destination: ProfileView(mainService: mainService, user: otherUser)) {
                VStack(alignment: .center) {
                    Text(otherUser.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if otherUser.isTyping && Date().timeIntervalSince(otherUser.lastOnline) < 60 {
                        Text(NSLocalizedString("Is-Typing", comment: "Is typing"))
                            .font(.caption)
                            .foregroundColor(Color.accentColor)
                    } else {
                        Text(lastOnlineText)
                            .font(.caption)
                            .foregroundColor(lastOnlineText == NSLocalizedString("Online", comment: "Online") ? .green : .gray)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink(destination: PhoneCallView(mainService: mainService).environmentObject(authManager)) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 27))
                    .foregroundColor(Color.accentColor)
            }
            .padding(.trailing, 15)
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 5)
    }
    
    private var userIntroduction: some View {
        VStack (alignment: .center) {
            NavigationLink(destination: ProfileView(mainService: mainService, user: otherUser)) {
                AsyncImageView(url: otherUser.compressedProfileImageUrl)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            Text(otherUser.bio)
            Text(NSLocalizedString("New-Chat-Message", comment: "New chat message"))
                .font(.system(size: 20))
                .foregroundColor(.gray)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var messagesView: some View {
        ScrollView(.vertical) {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    Spacer().id("top")
                    
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        if !(message.isDeleted ?? false){
                            
                            let previousMessage = (index < messages.count - 1) ? messages[index + 1] : nil
                            
                            let showTimestamp = messageHelperModel.shouldShowTimestamp(currentMessage: message, previousMessage: previousMessage)
                            
                            MessageView(mainService: mainService, voicePlayer: voicePlayer, message: message, otherUserId: otherUser.id, showTimestamp: showTimestamp).environmentObject(authManager)
                                .rotationEffect(.degrees(180))
                                .scaleEffect(x: -1, y: 1, anchor: .center)
                        }
                        
                    }
                    if ((mainService.reachedBeginningOfChatHistory[otherUserId]) != nil) {
                        userIntroduction
                            .rotationEffect(.degrees(180))
                            .scaleEffect(x: -1, y: 1, anchor: .center)
                    }
                }
                Spacer().id("bottom")
            }
            .background(GeometryReader { geometry in
                Color.clear
                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                })
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                if value.y >= -600 {
                    print("loading more messages")
                    mainService.loadMoreMessages(for: otherUser.id)
                }
            }
        }
        .rotationEffect(.degrees(180))
        .scaleEffect(x: -1, y: 1, anchor: .center)
        .background(colorScheme == .dark ? Color.black : Color(red: 0.95, green: 0.95, blue: 0.95))
        .onTapGesture {
            messageHelperModel.hideKeyboard()
        }
    }
    
    private var textInputView: some View {
        HStack(spacing: 15) {
            Button(action: {
                showingAdditionalOptions.toggle()
            }) {
                Image(systemName: showingAdditionalOptions ? "chevron.left" : "chevron.right")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 21))
                    .frame(width: 25)
                    .padding(.leading)
            }
            if showingAdditionalOptions {
                Button(action: {
                    isShowingMediaPicker.toggle()
                }) {
                    Image(systemName: "photo.on.rectangle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 21))
                        .frame(width: 25)
                }
                Button(action: {
                    mainService.showingVoiceMessageUI = true
                }) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 21))
                        .foregroundColor(.accentColor)
                        .frame(width: 25)
                }
            }
            
            TextField(NSLocalizedString("Type A Message", comment: "Type a message"), text: $newMessageText, axis: .vertical)
                .padding(.horizontal)
                .frame(minHeight: 45)
                .foregroundColor(.primary)
                .cornerRadius(22)
                .lineLimit(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .onChange(of: newMessageText) { newText in
                    showingAdditionalOptions = false
                    let isUserTyping = !newText.isEmpty
                    if mainService.clientUser?.isTyping != isUserTyping {
                        mainService.updateUserTypingStatus(isTyping: isUserTyping)
                    }
                }
                .padding(.top, 5)
            
            Button(action: sendTextMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .padding(.trailing)
            }
        }
        .animation(.easeInOut, value: showingAdditionalOptions)
        .animation(.easeInOut, value: mainService.showingVoiceMessageUI)
    }
}

// ChatView functions
extension ChatView {
    private func sendTextMessage() {
        let trimmedText = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedText.isEmpty {
            mainService.sendTextMessage(text: trimmedText)
            showingAdditionalOptions = true
            newMessageText = ""
        }
    }
}


struct BouncingDot: View {
    let delay: Double
    @State private var bouncing = false
    
    var body: some View {
        Circle()
            .frame(width: 10, height: 10)
            .scaleEffect(bouncing ? 1 : 0.8)
            .animation(
                Animation.easeInOut(duration: 0.6)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: bouncing
            )
            .foregroundColor(Color.accentColor)
            .onAppear {
                self.bouncing = true
            }
    }
}

struct TypingIndicatorView: View {
    var body: some View {
        HStack(spacing: 5) {
            BouncingDot(delay: 0)
            BouncingDot(delay: 0.2)
            BouncingDot(delay: 0.4)
        }
    }
}
