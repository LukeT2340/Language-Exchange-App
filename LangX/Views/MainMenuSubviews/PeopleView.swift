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
    @StateObject var peopleService = PeopleService()
    @Environment(\.colorScheme) var colorScheme
    
    @State private var tabIndex = 0
    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian", "pl": "Polish", "ko": "Korean", "it": "Italian", "sv": "Swedish", "pt": "Portuguese", "uk": "Ukrainian", "hi": "Hindi", "EL": "Greek", "da": "Danish", "id": "Indonesian", "vi": "Vietnamese", "th": "Thai"]
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            navigationBarView
            if tabIndex == 0 {
                allPeopleView
            } else if tabIndex == 1 {
                followedPeopleView
            } else if tabIndex == 2 {
                Text("Near-by")
            }
            Spacer()
        }
        .animation(.easeInOut, value: peopleService.searchLanguages)
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    @ViewBuilder
    private var navigationBarView: some View {
        SlidingTabView(selection: $tabIndex, tabs: [NSLocalizedString("All", comment: "All-Label"), NSLocalizedString("Friends", comment: "Friends-Label"), NSLocalizedString("Following", comment: "Following-Label")], animation: .easeInOut, activeAccentColor: Color(red: 51/255, green: 200/255, blue: 255/255), inactiveAccentColor: colorScheme == .light ? .gray : .white, selectionBarColor: Color.accentColor)
    }
    
    private var allPeopleView: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                // Search Field Styling
                TextField(NSLocalizedString("Search", comment: "Search"), text: $peopleService.searchText)
                    .onChange(of: peopleService.searchText) { newValue in
                        if newValue.isEmpty {
                            //peopleService.fetchRecommendedUsers()
                        }
                    }
                    .keyboardType(.webSearch)
                    .onSubmit {
                        peopleService.fetchRecommendedUsers()
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        
                    }
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
            }
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.secondary, lineWidth: 0.5)
            )
            .cornerRadius(8)
            .padding(.horizontal)
            /*
            ScrollView (.horizontal) {
                HStack {
                    ForEach(peopleService.searchLanguages, id: \.self) {langId in
                        Button(action: {
                            if let index = peopleService.searchLanguages.firstIndex(of: langId) {
                                peopleService.searchLanguages.remove(at: index)
                                peopleService.fetchRecommendedUsers()
                            }
                        }) {
                            if let englishLanguage = languageIdentifiers[langId] {
                                let imageName = "\(englishLanguage)_Flag"
                                Image(imageName)
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                
                                Text(LocalizedStringKey(englishLanguage))
                                    .foregroundColor(.primary)
                                    .font(.system(size: 15))
                                
                                Image(systemName: "minus.circle")
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                
                            }
                        }
                        .padding(12)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                    }
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            */
            List {
                ForEach(peopleService.recommendedUsers) { user in
                    NavigationLink(destination: ProfileView(mainService: mainService, user: user).environmentObject(authManager)) {
                        UserRow(user: user)
                    }
                }
            }
            .listStyle(PlainListStyle())
            
        }
        .onAppear {
            if peopleService.searchLanguages.isEmpty {
                if let keys = mainService.clientUser?.targetLanguages.keys {
                    let targetLanguages = Array(keys)
                    peopleService.searchLanguages = targetLanguages
                    peopleService.fetchRecommendedUsers()
                }
            }
        }
        .refreshable {
            peopleService.fetchRecommendedUsers()
        }
    }
    
    private var followedPeopleView: some View {
        VStack {
            HStack {
                // Search Field Styling
                TextField(NSLocalizedString("Search", comment: "Search"), text: $peopleService.searchText)
                    .onChange(of: peopleService.searchText) { newValue in
                        
                        if newValue.isEmpty {
                            //peopleService.fetchRecommendedUsers()
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
                        //peopleService.fetchRecommendedUsers()
                    }
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor)
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
        HStack (spacing: 15) {
            // User image
            ZStack {
                // User image
                AsyncImageView(url: user.profileImageUrl)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()                     .clipShape(RoundedRectangle(cornerRadius: 5))
                
                
                // Online status indicator
                if let firstNativeLanguage = user.nativeLanguages.first {
                    if let englishName = languageIdentifiers[firstNativeLanguage] {
                        let imageName = "\(englishName)_Flag"
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .overlay(Circle().stroke(lineWidth: 2).foregroundColor(colorScheme == .light ? .white : .black))
                            .offset(x: 30, y: -30)
                    }
                }
            }
            
            
            // User info and bio
            VStack(alignment: .leading) {
                // User name
                Text(user.name)
                    .font(.system(size: 15))
                    .padding(.bottom, 4)
                    .foregroundColor(.primary)
                
                // User bio
                Text(user.bio)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.top)
            
            Spacer()
            ForEach(user.targetLanguages.keys.sorted(), id: \.self) { language in
                let languageName = languageIdentifiers[language] ?? "Unknown"
                let imageName = "\(languageName)_Flag"
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
                    .overlay(
                        ProficiencyCircle(proficiency: user.targetLanguages[language]!)
                            .frame(width: 20, height: 20) // Adjust size as needed
                    )
            }
        }
    }
}

struct ProficiencyCircle: View {
    var proficiency: Int
    var maxProficiency: Int = 5 // Assuming 5 is the highest proficiency
    
    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let radius = diameter / 2
            let proficiencyFraction = CGFloat(proficiency) / CGFloat(maxProficiency)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 2.0)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Circle()
                    .trim(from: 0.0, to: proficiencyFraction)
                    .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
                    .foregroundColor(Color.accentColor)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear, value: proficiencyFraction)
            }
            .frame(width: diameter, height: diameter)
        }
    }
}
