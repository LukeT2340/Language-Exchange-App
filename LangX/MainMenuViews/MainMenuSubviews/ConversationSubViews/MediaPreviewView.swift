//
//  MediaPreviewView.swift
//  Tandy
//
//  Created by Luke Thompson on 28/11/2023.
//

import SwiftUI
import Combine

/*
struct MediaPreviewView: View {
    var image: UIImage?
    var videoURL: URL?
    var mediaService: MediaService
    var onRemove: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer() // Pushes the button to the right
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .imageScale(.large)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
            .padding([.top, .trailing]) // Add padding here

            Spacer() // Pushes the media content up

            // Media preview content
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else if let videoURL = videoURL, let thumbnail = mediaService.generateThumbnail(for: videoURL) {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(height: 100) // Adjust the height as needed
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))

            Spacer() // Ensures the media content doesn't fill the entire VStack
        }
        .frame(height: 150) // Adjust overall frame size as needed
        
    }
}
*/
