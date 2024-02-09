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
                        .frame(width: 70, height: 70)
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
                        .offset(x: 35, y: -35)
                }
                
            }
            VStack(alignment: .leading) {
                Text(user.name)
                    .font(.system(size: 15))
                    .padding(.bottom, 4)
                    .foregroundColor(.primary)
                
                if lastMessage.messageType == .text {
                    if let textContent = lastMessage.textContent {
                        Text(textContent)
                            .font(.caption)
                            .foregroundColor(.gray)
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
            .padding(.top)
            Spacer()
            
            // Timestamp for the last message
            Text(formatDate(lastMessage.timestamp))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        
        
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
}
extension String {
    func words(limit: Int) -> String {
        let wordsArray = self.components(separatedBy: .whitespacesAndNewlines)
        if wordsArray.count > limit {
            let limitedArray = wordsArray.prefix(limit)
            return limitedArray.joined(separator: " ") + "..."
        } else {
            return self
        }
    }
}

