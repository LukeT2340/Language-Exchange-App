//
//  User.swift
//  LangLeap
//
//  Created by Luke Thompson on 17/11/2023.
//

import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var name_lower: String
    var birthday: Date
    var sex: String
    var phoneNumber: String?
    var email: String?
    var bio: String
    var learningGoals: String
    var hobbiesAndInterests: [String]
    var nativeLanguages: [String]
    var targetLanguages: [String: Int]
    var hiddenConversationIds: [String]
    var profileImageUrl: URL
    var lastOnline: Date
    var followerCount: Int
    var fcmToken: String?
    var notificationCount: Int
    var searchingForPartner: Bool
    var isTyping: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, name_lower, birthday, sex, email, bio, learningGoals, hobbiesAndInterests
        case nativeLanguages, targetLanguages, hiddenConversationIds, profileImageUrl, compressedProfileImageUrl
        case lastOnline, latitude, longitude, followerCount, fcmToken, notificationCount, searchingForPartner, isTyping, phoneNumber
    }
    
    init(id: String, name: String, birthday: Date, sex: String, phoneNumber: String? = nil, email: String? = nil, bio: String, learningGoals: String, hobbiesAndInterests: [String], nativeLanguages: [String], targetLanguages: [String: Int], hiddenConversationIds: [String], profileImageUrl: URL, lastOnline: Date, followerCount: Int, fcmToken: String, notificationCount: Int, searchingForPartner: Bool, isTyping: Bool) {
        self.id = id
        self.name = name
        self.name_lower = name.lowercased()
        self.birthday = birthday
        self.sex = sex
        self.phoneNumber = phoneNumber
        self.email = email
        self.bio = bio
        self.learningGoals = learningGoals
        self.hobbiesAndInterests = hobbiesAndInterests
        self.nativeLanguages = nativeLanguages
        self.targetLanguages = targetLanguages
        self.hiddenConversationIds = hiddenConversationIds
        self.profileImageUrl = profileImageUrl
        self.lastOnline = lastOnline
        self.followerCount = followerCount
        self.fcmToken = fcmToken
        self.notificationCount = notificationCount
        self.searchingForPartner = searchingForPartner
        self.isTyping = isTyping
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        name_lower = try container.decode(String.self, forKey: .name_lower)
        birthday = try container.decode(Date.self, forKey: .birthday)
        sex = try container.decode(String.self, forKey: .sex)
        phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        bio = try container.decode(String.self, forKey: .bio)
        learningGoals = try container.decode(String.self, forKey: .learningGoals)
        hobbiesAndInterests = try container.decode([String].self, forKey: .hobbiesAndInterests)
        nativeLanguages = try container.decode([String].self, forKey: .nativeLanguages)
        targetLanguages = try container.decode([String: Int].self, forKey: .targetLanguages)
        hiddenConversationIds = try container.decode([String].self, forKey: .hiddenConversationIds)
        profileImageUrl = try container.decode(URL.self, forKey: .profileImageUrl)
        lastOnline = try container.decode(Date.self, forKey: .lastOnline)
        followerCount = try container.decode(Int.self, forKey: .followerCount)
        fcmToken = try container.decode(String.self, forKey: .fcmToken)
        notificationCount = try container.decode(Int.self, forKey: .notificationCount)
        searchingForPartner = try container.decode(Bool.self, forKey: .searchingForPartner)
        isTyping = try container.decode(Bool.self, forKey: .isTyping)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(name_lower, forKey: .name_lower)
        try container.encode(birthday, forKey: .birthday)
        try container.encode(sex, forKey: .sex)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(email, forKey: .email)
        try container.encode(bio, forKey: .bio)
        try container.encode(learningGoals, forKey: .learningGoals)
        try container.encode(hobbiesAndInterests, forKey: .hobbiesAndInterests)
        try container.encode(nativeLanguages, forKey: .nativeLanguages)
        try container.encode(targetLanguages, forKey: .targetLanguages)
        try container.encode(hiddenConversationIds, forKey: .hiddenConversationIds)
        try container.encode(profileImageUrl, forKey: .profileImageUrl)
        try container.encode(lastOnline, forKey: .lastOnline)
        try container.encode(followerCount, forKey: .followerCount)
        try container.encode(fcmToken, forKey: .fcmToken)
        try container.encode(notificationCount, forKey: .notificationCount)
        try container.encode(searchingForPartner, forKey: .searchingForPartner)
        try container.encode(isTyping, forKey: .isTyping)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        // You can compare other properties as well if needed
        return lhs.id == rhs.id
    }
}
