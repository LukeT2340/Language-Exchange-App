//
//  AsyncImageView.swift
//  Tandy
//
//  Created by Luke Thompson on 26/11/2023.
//

import SwiftUI
import UIKit
import Foundation

struct AsyncImageView: View {
    @StateObject private var loader = ObservableImageLoader()
    let url: URL

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Text("")
                    .foregroundColor(.gray)
                    .frame(width: 100, height: 100)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear {
            loader.loadImage(from: url)
        }
    }
}
