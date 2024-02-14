//
//  InAppNotificationView.swift
//  Tandy
//
//  Created by Luke Thompson on 8/1/2024.
//

import SwiftUI
import Kingfisher

struct BannerView: View {
    @ObservedObject var mainService: MainService
    let banner: Banner?
    let otherUser: User?
    @State private var heartBeat = false
    
    init(mainService: MainService, banner: Banner?) {
        self.mainService = mainService
        self.banner = banner
        self.otherUser = mainService.otherUsers.first { $0.id == banner?.otherUserId }
    }
    
    
    var body: some View {
        if let banner = banner {
            if banner.linkType == .message {
                
                HStack(spacing: 15) {
                    if let imageURL = banner.imageURL {
                        AsyncImageView(url: imageURL)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                    } else {
                        Image("Logo")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(banner.title)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        if let text = banner.text {
                            Text(text)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.horizontal)
                
            } else if banner.linkType == .follow {
                
                HStack(spacing: 15) {
                    Image(systemName: "heart.fill")
                        .aspectRatio(contentMode: .fill)
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                        .scaleEffect(heartBeat ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: heartBeat)
                    
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(banner.title)
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        if let text = banner.text {
                            Text(text)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
                .shadow(radius: 4)
                .padding(.horizontal)
                .onAppear {
                    heartBeat.toggle()
                }
            }
            
        }
    }
    
}
