//
//  MainService.swift
//  Tandy
//
//  Created by Luke Thompson on 27/12/2023.
//

import SwiftUI
import FirebaseFirestore
import AudioToolbox
import FirebaseStorage
import Photos
import TLPhotoPicker

class MainService: ObservableObject {
    var db = Firestore.firestore()
    var storage = Storage.storage().reference()
    var initializationTime: Date
    
    // Messages and Conversations
    var messageListeners: [String: ListenerRegistration] = [:]
    var conversationsListener: ListenerRegistration?
    var userListeners: [String: ListenerRegistration] = [:]
    var followerListener: ListenerRegistration?
    var languagePartnerListener: ListenerRegistration?
    @Published var messages: [String: [Message]] = [:] {
        didSet {
            updateBadgeCount()
        }
    }
    @Published var reachedBeginningOfChatHistory: [String: Bool] = [:]
    @Published var isLoadingNewMessages = false
    @Published var isLoadingOlderMessages = false
    @Published var chattingWithUserId: String? = nil
    @Published var chattingInConversationId: String? = nil
    @Published var authManager: AuthManager
    @Published var automaticallyTranslateMessages = false
    @Published var hasSetupCompleted = false
    @Published var selectedTab = 0
    @Published var showingVoiceMessageUI: Bool = false
    
    // Users
    var clientUserListener: ListenerRegistration? = nil
    var isSetupInProgress = false
    var initializationTimestamp: Date = Date()
    
    @Published var clientUser: User? = nil
    @Published var otherUsers: [User] = []
    var isRemovalScheduled = false
    
    // Follows
    @Published var processingFollow = false
    
    // Banners
    @Published var banners: [Banner] = []
    
    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian"]
    
    var searchingForPartner: Bool {
        clientUser?.searchingForPartner ?? false
    }
    
    var totalUnreadMessages: Int {
        messages.values
            .flatMap({ $0 })
            .filter { !$0.hasBeenRead && ($0.receiverId == clientUser?.id && !(clientUser?.hiddenConversationIds.contains($0.conversationId))!)}
            .count
    }
    
    var sortedUserIds: [String] {
        messages.keys.sorted { firstUserId, secondUserId in
            guard let firstUserMessages = messages[firstUserId],
                  let secondUserMessages = messages[secondUserId],
                  let firstLastMessage = firstUserMessages.last,
                  let secondLastMessage = secondUserMessages.last else {
                return false
            }
            return firstLastMessage.timestamp > secondLastMessage.timestamp
        }
    }
    
    init (authManager: AuthManager) {
        self.initializationTime = Date()
        self.authManager = authManager
        self.setup()
    }
    
    func setup() {
        print("setup called")
        guard !isSetupInProgress && !hasSetupCompleted else { return }
        
        isSetupInProgress = true
        isLoadingNewMessages = true
        fetchClient() { user in
            self.clientUser = user
            if let clientUser = self.clientUser {
                print("Client user found: \(clientUser.name)")
                self.setupClientUserListener(for: clientUser.id)
                self.fetch10RecentConversations(for: clientUser.id) { conversations in
                    print("Number of converations: \(conversations.count)")
                    let dispatchGroup = DispatchGroup()
                    self.setupConversationsListener(for: clientUser.id)
                    self.setupFollowListener()
                    for conversation in conversations {
                        dispatchGroup.enter()
                        if let conversationId = conversation.id {
                            if let otherUserId = conversation.participants.first(where: { $0 != clientUser.id }) {
                                // Now 'otherUserId' is the ID of the other user in the conversation
                                self.fetchUserAndSetupListener(withId: otherUserId)
                                self.fetchRecent30MessagesAndListenForUpdates(conversationId: conversationId, otherUserId: otherUserId) { success in
                                }
                            }
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.notify(queue: .main) {
                        // All fetchRecent30Messages calls are completed
                        self.isSetupInProgress = false
                        self.hasSetupCompleted = true
                        self.updateBadgeCount()
                        self.updateNotificationCount()
                        // Handle anything else you need to do after all messages have been fetched
                    }
                }
            }
        }
    }
    
    
    // Remove all listeners
    deinit {
        print("listeners removed")
        clientUserListener?.remove()
        conversationsListener?.remove()
        languagePartnerListener?.remove()
        followerListener?.remove()
        
        for (_, listener) in messageListeners {
            listener.remove()
        }
    }
}

