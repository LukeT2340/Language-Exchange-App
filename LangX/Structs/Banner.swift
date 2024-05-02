//
//  Banner.swift
//  Tandy
//
//  Created by Luke Thompson on 8/1/2024.
//

import Foundation
import SwiftUI

struct Banner {
    var id: String
    var title: String
    var text: String?
    var linkType: LinkType
    var timeStamp: Date
    var otherUserId: String?
    var imageURL: URL?
    
    enum LinkType: String, Codable, Equatable, Hashable {
        case message
        case follow
    }
}
