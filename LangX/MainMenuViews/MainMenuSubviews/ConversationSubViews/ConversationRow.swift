//
//  ConversationRwo.swift
//  Tandy
//
//  Created by Luke Thompson on 29/12/2023.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct ConversationRow: View {
    var user: User
    var lastMessage: Message
    var unreadCount: Int

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Group {
                    let imageUrl = user.profileImageUrl
                    KFImage(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill) 
                        .frame(width: 60, height: 60)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                
                }
                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 30, y: -30)
                }
                
            }
            VStack(alignment: .leading) {
                Spacer()
                Text(user.name)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                    .padding(.bottom, 2)
                    .foregroundColor(.white)
                    
                if lastMessage.messageType == .text {
                    if let textContent = lastMessage.textContent {
                        Text(textContent)
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.light)
                            .lineLimit(1)
                    }
                } else if lastMessage.messageType == .system {
                    Text(NSLocalizedString("System-Message", comment: "System message"))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if lastMessage.messageType == .image {
                    Text(NSLocalizedString("Image-Message", comment: "Image message"))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if lastMessage.messageType == .video {
                    Text(NSLocalizedString("Video-Message", comment: "Video message"))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                } else if lastMessage.messageType == .audio {
                    Text(NSLocalizedString("Audio-Message", comment: "Audio message"))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                Spacer()
            }
            Spacer()
            
            Text(formatDate(lastMessage.timestamp))
                .font(.caption)
                .foregroundColor(.white)
                .padding(.trailing, 5)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(9)
        .background(Color.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let now = Date()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        if calendar.isDateInToday(date) {
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            formatter.dateFormat = NSLocalizedString("'Yesterday at' h:mm a", comment: "")
            return formatter.string(from: date)
        }  else {
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }

    
}


