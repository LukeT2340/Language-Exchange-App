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

    init(mainService: MainService, banner: Banner?) {
        self.mainService = mainService
        self.banner = banner
        self.otherUser = mainService.otherUsers.first { $0.id == banner?.otherUserId }
    }

    
    var body: some View {
        if let banner = banner {
            HStack(spacing: 15) {
                if let imageURL = banner.imageURL {
                    AsyncImageView(url: imageURL)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image("Logo")
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(banner.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    if let text = banner.text {
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 4)
            .padding(.horizontal)
        }
    }
    
}
