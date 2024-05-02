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


struct NewNoteView: View {
    @StateObject private var newNoteService = NewNoteService()
    
    var body: some View {
        VStack {}
    }
}

class NewNoteService: ObservableObject {
    var authorId = ""
    var title = ""
    var textContent = ""
    var tags: [String] = []
    var isPublic = true
    var localMediaURLS: [URL] = []
    var mentionedUserIDs: [String] = []
}
