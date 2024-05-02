//
//  NoteDetailView.swift
//  Tandy
//
//  Created by Luke Thompson on 12/12/2023.
//

import SwiftUI
import Kingfisher

/*

struct NoteDetailView: View {
    @StateObject private var commentService: CommentService
    @ObservedObject var noteService: NoteService
    @ObservedObject var mainService: MainService
    @ObservedObject var userService: UserService
    @EnvironmentObject var authManager: AuthManager
    let noteId: String
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State var commentText = ""
    @State private var isFullScreen = false

    
    var note: Note? {
        noteService.notes.first { $0.id == noteId }
    }
    
    init(noteService: NoteService, mainService: MainService, userService: UserService, noteId: String) {
        self.noteService = noteService
        _commentService = StateObject(wrappedValue: CommentService(clientUserId: userService.clientUser.id, noteId: noteId))
        self.mainService = mainService
        self.userService = userService
        self.noteId = noteId
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                if let note = note {
                    if let profilePictureURL = noteService.profilePictures[note.authorId] {
                        KFImage(profilePictureURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    Text(noteService.usernames[note.authorId] ?? "")
                        .foregroundColor(.primary)
                        .font(.system(size: 25))
                }
                Spacer()
            }
            ScrollView {
                VStack (alignment: .leading, spacing: 0) {
                    postView
                        .padding()
                    textFieldView
                        .padding(.horizontal)
                    commentView
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8) // Rounded corners for the border
                                .stroke(Color.gray, lineWidth: 0.5) // Set border color and thickness
                        )
                        .padding(.horizontal)

                }
            }
        }
        .navigationBarHidden(true)
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
        )
        .onAppear{
            commentService.fetchComments()
        }
        
    }
    
    private var commentView: some View {
        ForEach(commentService.comments) { comment in
            VStack (alignment: .leading){
                HStack {
                    if let url = commentService.userInformation[comment.commenterId]?.profileImageUrl {
                        KFImage(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill) // This will fill the frame and may clip the image
                            .frame(width: 30, height: 30)
                            .clipped() // This will clip the overflow if the image's aspect ratio doesn't match the frame
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    VStack (alignment: .leading) {
                        Text(commentService.userInformation[comment.commenterId]?.name ?? "")
                            .foregroundColor(.primary)
                            .font(.system(size: 12))
                            .bold()
                        // Display the timestamp, formatted
                        Text(formatDate(comment.timestamp))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    if let commentId = comment.id { // Make sure 'id' is lowercase if it's a property
                        let isLiked = commentService.hasLikedComment[commentId] ?? false
                        Button(action: {
                            if isLiked {
                                commentService.unlikeComment(commentId: commentId)
                            } else {
                                commentService.likeComment(commentId: commentId)
                            }
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .gray)
                                Text("\(comment.likeCount)")
                                    .foregroundColor(.gray)
                            }
                        }
                        .disabled(commentService.isLikingComment)
                    }
                }
                Text(comment.commentText)
                    .font(.body)
                
            }
        }
    }
    
    private var textFieldView: some View {
        HStack {
            KFImage(userService.clientUser.profileImageUrl)
                .resizable()
                .aspectRatio(contentMode: .fill) // This will fill the frame and may clip the image
                .frame(width: 35, height: 35)
                .clipped() // This will clip the overflow if the image's aspect ratio doesn't match the frame
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            TextField(NSLocalizedString("Type A Comment", comment: "Type A Comment"), text: $commentService.keyboardText)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 0.5)
                )
                .cornerRadius(8)
                .keyboardType(.twitter)
                .submitLabel(.send)
                .onSubmit {
                    commentService.submitComment()
                }
        }
    }
    
    private var postView: some View {
        VStack (alignment: .leading, spacing: 0) {
            if let note = note {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {  // Adjust spacing as needed
                        ForEach(note.mediaURLs, id: \.self) { url in
                            KFImage(url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width - 32)
                                .clipped()
                                .background()
                                .cornerRadius(10)
                        }
                    }
                }
                Text(note.title)
                    .font(.title)
                    .bold()
                
                Text(note.textContent)
                    .font(.system(size: 15))
                HStack {
                    Text(formatDate(note.timestamp))
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                    Spacer()
                    if let noteid = note.id {
                        let isLiked = noteService.hasLikedNote[noteid] ?? false
                        
                        Button(action: {
                            if isLiked {
                                noteService.unlikeNote(noteId: noteid)
                                
                            } else {
                                noteService.likeNote(noteId: noteid)
                            }
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .gray)
                                    .font(.system(size: 14))
                                Text("\(formatNumber(note.likeCount))")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))

                            }
                        }
                        .disabled(noteService.isLikingNote)
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            let minutesAgo = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
            let hoursAgo = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0

            if minutesAgo < 1 {
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
            let dateComponents = calendar.dateComponents([.year], from: date, to: now)

            if calendar.isDateInYesterday(date) {
                dateFormatter.dateFormat = NSLocalizedString("'Yesterday at' h:mm a", comment: "Time format: Yesterday at 3:45 PM")
            } else if dateComponents.year! < 1 {
                dateFormatter.dateFormat = NSLocalizedString("MMM d 'at' h:mm a", comment: "Date format: Jan 5 at 3:45 PM")
            } else {
                dateFormatter.dateFormat = NSLocalizedString("MMM d, yyyy 'at' h:mm a", comment: "Date format: Jan 5, 2021 at 3:45 PM")
            }
            return dateFormatter.string(from: date)
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let locale = Locale.current
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        // Check for East Asian locales (Chinese and Japanese)
        if ["zh", "ja"].contains(where: locale.identifier.starts(with:)) {
            if number < 10000 {
                return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
            } else {
                let formattedNumber = Double(number) / 10000
                let suffix = locale.identifier.starts(with: "zh") ? "万" : "万" // "万" is used in both Japanese and Chinese
                return formatter.string(from: NSNumber(value: formattedNumber))! + suffix
            }
        } else {
            // General formatting (like 10k, 1M)
            let suffixes = ["", "K", "M", "B", "T"]
            let idx = min(suffixes.count - 1, Int(log10(Double(number)) / 3))
            let divisor = pow(10.0, Double(3 * idx))

            let formattedNumber = Double(number) / divisor
            let numberString = formatter.string(from: NSNumber(value: formattedNumber)) ?? ""
            
            return "\(numberString)\(suffixes[idx])"
        }
    }

}

*/
