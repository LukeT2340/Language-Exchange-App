//
//  NotesView.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import Kingfisher


struct NotesView: View {
    @StateObject var noteService = NoteService()
    @ObservedObject var mainService: MainService
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.colorScheme) var colorScheme
    
    init (mainService: MainService) {
        self.mainService = mainService
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: NewNoteView()) {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            }
            ForEach (noteService.notes, id: \.self) {note in
                
            }
        }
    }
}

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


