//
//  LoadingView.swift
//  Tandy
//
//  Created by Luke Thompson on 6/1/2024.
//

import SwiftUI

struct ListLoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            LoadingView()
            Spacer()
        }
    }
}

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.accentColor, lineWidth: 1.7)
            .frame(width: 13, height: 13)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct WhiteLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.white, lineWidth: 1.7)
            .frame(width: 13, height: 13)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct DownloadingMediaView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.white, lineWidth: 3)
            .frame(width: 35, height: 35)
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear {
                self.isAnimating = true
            }
    }
}

struct LoadingAndSuccessView: View {
    @State private var isAnimating = false
    @State private var isLoadingComplete = false
    @State private var showCheckmark = false

    let animationColor = Color.blue // Unified color for both animations

    var body: some View {
        ZStack {
            // Loading Circle
            Circle()
                .trim(from: 0, to: isLoadingComplete ? 0 : 0.7)
                .stroke(animationColor, lineWidth: 5)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                .opacity(showCheckmark ? 0 : 1)
                .onAppear {
                    isAnimating = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // Simulate loading time
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isLoadingComplete = true
                            showCheckmark = true
                        }
                    }
                }

            // Checkmark
            if showCheckmark {
                Image(systemName: "checkmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(animationColor)
                    .scaleEffect(isLoadingComplete ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0), value: isLoadingComplete)
            }
        }
    }
}
