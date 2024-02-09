//
//  Message.swift
//  LangLeap
//
//  Created by Luke Thompson on 16/11/2023.
//

import SwiftUI
import FirebaseFirestore

struct Message: Identifiable, Equatable, Hashable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    var timestamp: Date
    var conversationId: String
    var hasBeenRead: Bool
    var isDeleted: Bool?
    var messageType: MessageType
    var textContent: String?
    var temporaryImage: UIImage?
    var thumbnailURL: URL?
    var localAudioURL: URL?
    var mediaURL: URL?
    var duration: TimeInterval?
    var isUploaded: Bool
    
    enum MessageType: String, Codable, Equatable, Hashable {
        case system
        case text
        case image
        case audio
        case video
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case receiverId
        case timestamp
        case conversationId
        case hasBeenRead
        case isDeleted
        case messageType
        case textContent
        case mediaURL
        case thumbnailURL
        case duration
        case isUploaded
    }

    init(id: String? = nil, senderId: String, receiverId: String, timestamp: Date, conversationId: String, hasBeenRead: Bool, isDeleted: Bool? = nil, messageType: MessageType, textContent: String? = nil, temporaryImage: UIImage? = nil, thumbnailURL: URL? = nil, localAudioURL: URL? = nil, mediaURL: URL? = nil, duration: TimeInterval? = nil, isUploaded: Bool) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.conversationId = conversationId
        self.hasBeenRead = hasBeenRead
        self.isDeleted = isDeleted
        self.messageType = messageType
        self.textContent = textContent
        self.temporaryImage = temporaryImage
        self.thumbnailURL = thumbnailURL
        self.localAudioURL = localAudioURL
        self.mediaURL = mediaURL
        self.duration = duration
        self.isUploaded = isUploaded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(receiverId, forKey: .receiverId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(conversationId, forKey: .conversationId)
        try container.encode(hasBeenRead, forKey: .hasBeenRead)
        try container.encodeIfPresent(isDeleted, forKey: .isDeleted)
        try container.encode(messageType, forKey: .messageType)
        try container.encodeIfPresent(textContent, forKey: .textContent)
        try container.encodeIfPresent(thumbnailURL, forKey: .thumbnailURL)
        try container.encodeIfPresent(mediaURL, forKey: .mediaURL)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encode(isUploaded, forKey: .isUploaded)
    }
}
