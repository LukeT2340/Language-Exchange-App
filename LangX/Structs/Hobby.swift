//
//  Hobbies.swift
//  SpeakSwap
//
//  Created by Luke Thompson on 20/1/2024.
//

import SwiftUI
import FirebaseFirestore

struct Hobby: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var name_lower: String
    var usageCount: Int

    enum CodingKeys: String, CodingKey {
        case id, name, name_lower, usageCount
    }
    
    init(id: String, name: String, usageCount: Int) {
        self.id = id
        self.name = name
        self.name_lower = name.lowercased()
        self.usageCount = usageCount
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        name_lower = try container.decode(String.self, forKey: .name_lower)
        usageCount = try container.decode(Int.self, forKey: .usageCount)

    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(name_lower, forKey: .name_lower)
        try container.encode(usageCount, forKey: .usageCount)
    }
    
    static func == (lhs: Hobby, rhs: Hobby) -> Bool {
        return lhs.id == rhs.id
    }
}
