//
//  ContactsView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 20/11/2023.
//

import SwiftUI
import Kingfisher
import SlidingTabView

struct PeopleView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    @ObservedObject var peopleService: PeopleService
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tabIndex = 0
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            navigationBarView
            SlidingTabView(selection: $tabIndex, tabs: [NSLocalizedString("All", comment: "All"), NSLocalizedString("Following", comment: "Following"), NSLocalizedString("Near-By", comment: "Near-By")], animation: .easeInOut)
            if tabIndex == 0 {
                allPeopleView
            } else if tabIndex == 1 {
                followedPeopleView
            } else if tabIndex == 2 {
                Text("Near-by")
            }
            Spacer()
        }
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
        )
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var navigationBarView: some View {
        HStack {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .padding(.leading)
            
            Spacer()
            
            Text(NSLocalizedString("App-Name", comment: "App name"))
                .font(.subheadline)
                .foregroundColor(.primary)
                .bold()
            
            Spacer()
            Image(systemName: "plus.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .padding()
                .hidden()
        }
    }
    
    private var allPeopleView: some View {
        VStack {
            HStack {
                // Search Field Styling
                TextField(NSLocalizedString("Search", comment: "Search"), text: $peopleService.searchText)
                    .onChange(of: peopleService.searchText) { newValue in
                        if newValue.isEmpty {
                            peopleService.fetchRecommendedUsers()
                        }
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 0.5)
                    )
                    .cornerRadius(8)
                    .padding(.leading)
                    .keyboardType(.webSearch)
                    .onSubmit {
                        peopleService.fetchRecommendedUsers()
                    }
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
                    .padding(.trailing)
            }
            
            
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack (spacing: 0) {
                    ForEach(peopleService.recommendedUsers) { user in
                        NavigationLink(destination: ProfileView(mainService: mainService, user: user).environmentObject(authManager)) {
                            UserRow(user: user)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        //.onAppear(perform: peopleService.fetchRecommendedUsers)
    }
    
    private var followedPeopleView: some View {
        VStack {
            HStack {
                // Search Field Styling
                TextField(NSLocalizedString("Search", comment: "Search"), text: $peopleService.searchText)
                    .onChange(of: peopleService.searchText) { newValue in
                        if newValue.isEmpty {
                            peopleService.fetchRecommendedUsers()
                        }
                    }
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 0.5)
                    )
                    .cornerRadius(8)
                    .padding(.leading)
                    .keyboardType(.webSearch)
                    .onSubmit {
                        peopleService.fetchRecommendedUsers()
                    }
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
                    .padding(.trailing)
            }
            
            
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack (spacing: 0) {
                    ForEach(peopleService.followedUsers) { user in
                        NavigationLink(destination: ProfileView(mainService: mainService, user: user).environmentObject(authManager)) {
                            UserRow(user: user)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear(perform: peopleService.fetchFollowedUsers)
    }
}

struct UserRow: View {
    let user: User
    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian"]
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack (alignment: .top) {
            // User image
            ZStack(alignment: .bottomTrailing) {
                // User image
                AsyncImageView(url: user.profileImageUrl)
                    .aspectRatio(contentMode: .fill) // This will fill the frame and may clip the image
                    .frame(width: 70, height: 70)
                    .clipped() // This will clip the overflow if the image's aspect ratio doesn't match the frame
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                
                // Online status indicator
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(getStatusColor(for: user.lastOnline))
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            
            // User info and bio
            VStack(alignment: .leading, spacing: 4) {
                // User name
                Text(user.name)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .bold()
                
                // User bio
                Text(user.bio)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Spacer()
                // Language information
                HStack {
                    // Native language flag
                    Text(NSLocalizedString("Native-Languages", comment: "Native languages"))
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    HStack {
                        ForEach(user.nativeLanguages, id: \.self) {language in
                            let languageName = languageIdentifiers[language] ?? "Unknown"
                            Image("\(languageName)_Flag", bundle: .main)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 15, height: 15)
                                .cornerRadius(7)
                        }
                    }
                    
                    Text(NSLocalizedString("Target-Languages", comment: "Target languages"))
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    HStack {
                        ForEach(user.targetLanguages.keys.sorted(), id: \.self) { language in
                            let languageName = languageIdentifiers[language] ?? "Unknown"
                            Image("\(languageName)_Flag", bundle: .main)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 15, height: 15)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(10)
        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 3)
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        
    }
    
    private func getStatusColor(for lastOnlineDate: Date) -> Color {
        let timeIntervalSinceLastOnline = -lastOnlineDate.timeIntervalSinceNow // Negated to get a positive value
        
        if timeIntervalSinceLastOnline < 10 * 60 { // Less than 10 minutes ago
            return .green
        } else if timeIntervalSinceLastOnline < 30 * 60 { // Less than 30 minutes ago
            return Color(red: 1/255, green: 171/255, blue: 243/255)
        } else {
            return .gray
        }
    }
    
}
