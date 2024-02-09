//
//  NotesView.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import Kingfisher

/*
struct NotesView: View {
    @ObservedObject var noteService: NoteService
    @ObservedObject var messageService: MessageService
    @ObservedObject var userService: UserService
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: NewNoteView(noteService: noteService, messageService: messageService, userService: userService).environmentObject(authManager)) {
                       Image(systemName: "square.and.pencil")
                           .resizable()
                           .scaledToFit()
                           .frame(width: 25, height: 25)
                           .foregroundColor(.accentColor)
                           .padding()
                   }
            }
            ScrollView {
                HStack(alignment: .top) {
                    Spacer()
                    LazyVStack {
                        ForEach(0..<noteService.notes.count / 2, id: \.self) { index in
                            NavigationLink(destination: NoteDetailView(noteService: noteService, messageService: messageService, userService: userService, noteId: noteService.notes[index].id ?? "").environmentObject(authManager)) {
                                noteView(for: noteService.notes[index])
                                    .cornerRadius(10)
                            }
                        }
                    }
                    Spacer()
                    LazyVStack {
                        ForEach(noteService.notes.count / 2..<noteService.notes.count, id: \.self) { index in
                            NavigationLink(destination: NoteDetailView(noteService: noteService, messageService: messageService, userService: userService,noteId: noteService.notes[index].id ?? "").environmentObject(authManager)) {
                                noteView(for: noteService.notes[index])
                                    .cornerRadius(10)
                            }
                        }
                        Color.clear
                            .frame(height: 1)
                            .onBottomReached {
                                if !noteService.isLoadingNotes {
                                    noteService.loadMoreNotes()
                                }
                            }
                    }

                    Spacer()
                }
            }
        }
        .refreshable {
            if !noteService.isLoadingNotes {
                await noteService.refreshNotes()
            }
        }
        .onAppear {
            if noteService.notes.isEmpty{
                Task {
                    await noteService.refreshNotes()
                }
            }
        }
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
        )
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func noteView(for note: Note) -> some View {
        VStack (alignment: .leading){
            if let noteid = note.id {
                let screenWidth = UIScreen.main.bounds.width // Get the screen width
                let totalPadding = CGFloat(24) // 12 points of padding on each side
                let imageWidth = (screenWidth - totalPadding) / 2
                
                if let thumbNail = note.mediaURLs.first {
                    KFImage(thumbNail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageWidth, height: 250)
                        .clipped() // This will clip the overflow if the image's aspect ratio doesn't match the frame
                        .background() // Optional: Add a background color to indicate loading area
                        .cornerRadius(10)
                }

                Text(note.title)
                    .font(.system(size: 12))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .bold()
                    .padding(.horizontal)
                
                Text(note.textContent)
                    .foregroundColor(.primary)
                    .font(.system(size: 12))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                
                
                HStack {
                    if let profilePictureURL = noteService.profilePictures[note.authorId] {
                         KFImage(profilePictureURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill) // This will fill the frame and may clip the image
                            .frame(width: 15, height: 15)
                            .clipped() // This will clip the overflow if the image's aspect ratio doesn't match the frame
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    Text(noteService.usernames[note.authorId] ?? "")
                        .foregroundColor(.primary)
                        .font(.system(size: 15))
                    Spacer()
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
                            Text("\(formatNumber(note.likeCount))")
                        }
                    }
                }
                .frame(maxWidth: imageWidth)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.horizontal)

                
            }
        }
        .padding(.bottom)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .background(colorScheme == .dark ? Color.black : Color.white)
        .cornerRadius(10)
        .padding(.bottom, 2)
    }
    
    func formatNumber(_ number: Int) -> String {
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
struct BottomDetectorModifier: ViewModifier {
    let onBottomReached: () -> Void

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    let frame = geometry.frame(in: .global)
                    if frame.maxY < UIScreen.main.bounds.height + 100 { // Threshold
                        onBottomReached()
                    }
                }
        }
    }
}

extension View {
    func onBottomReached(action: @escaping () -> Void) -> some View {
        self.modifier(BottomDetectorModifier(onBottomReached: action))
    }
}

