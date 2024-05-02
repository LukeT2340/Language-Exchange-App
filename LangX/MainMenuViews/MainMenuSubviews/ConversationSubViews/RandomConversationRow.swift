//
//  RandomConversationRow.swift
//  Tandy
//
//  Created by Luke Thompson on 5/1/2024.
//

import SwiftUI

struct RandomConversationRow: View {
    @ObservedObject var mainService: MainService
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        HStack(spacing: 15) {
            ZStack (alignment: .topTrailing) {
                Image(systemName: "person.crop.square.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black.opacity(0.8))
                    .frame(width: 70, height: 70)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Image(systemName: "dice.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.white)
                    .padding(2)
            }
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString("Find-Random-Person", comment: "Find random person"))
                    .font(.system(size: 15))
                    .padding(.bottom, 4)
                    .foregroundColor(.primary)
                
                
                Text(mainService.searchingForPartner ? NSLocalizedString("Searching-For-User", comment: "Searching for user") : NSLocalizedString("Find-Random-Person-Details", comment: "Find random person details"))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2) // Ensures the text doesn't wrap to a new line
                
                
                Spacer()
            }
            .padding(.top)
            Spacer()
            if mainService.searchingForPartner {
                LoadingView()
            } else {
                Image(systemName: "shuffle")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 14, height: 14)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black.opacity(0.8))
                    .padding()
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: mainService.searchingForPartner)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}
