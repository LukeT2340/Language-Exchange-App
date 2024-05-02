//
//  VideoPlayerView.swift
//  Tandy
//
//  Created by Luke Thompson on 9/1/2024.
//

import SwiftUI
import AVKit
import Kingfisher
import UIKit

struct CustomImageView: View {
    var imageURL: URL
    
    @Environment(\.presentationMode) var presentationMode
    @State private var image: UIImage? = nil

    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                }
                .padding(.leading, 15)
                Spacer()
            }


            KFImage(imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .navigationBarHidden(true)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.height > 50 {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
    }
}
class CustomVideoPlayerContainerViewController: UIViewController {
    private var videoURL: URL
    private var playerViewController: AVPlayerViewController!

    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerViewController = AVPlayerViewController()
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)

        let player = AVPlayer(url: videoURL)
        playerViewController.player = player
        player.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerViewController.view.frame = view.bounds
    }
}

struct AVPlayerViewRepresentable: UIViewControllerRepresentable {
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup error: \(error)")
        }
        // Start playing the video automatically
        player.play()

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Additional updates when your SwiftUI state changes, if needed.
    }
}
