//
//  File.swift
//  Tandy
//
//  Created by Luke Thompson on 10/12/2023.
//

import SwiftUI
import Firebase
import Kingfisher

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    @State private var isChatViewShowing = false
    @State private var isSettingsViewShowing = false
    @State private var isFollowing = false
    @State private var isProcessingFollow = false

    let user: User
    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian"]
    
    init (mainService: MainService, user: User)
    {
        self.mainService = mainService
        self.user = user
    }
    
    var body: some View {
        NavigationView {
            VStack {
                navigationBarView
                ScrollView { // For some reason can only have 10 items in Vstack so had to use 2 vstacks???
                    VStack (alignment: .leading, spacing: 10) {
                        profilePictureView
                        userBioView
                        optionPanelView
                        Text(NSLocalizedString("Languages-Label", comment: "Languages label"))
                            .font(.system(size: 23))
                            .bold()
                            .padding(.leading)
                            .frame(alignment: .leading)
                        Divider()
                        nativeLanguagesView
                        targetLanguagesView
                        learningGoalsView
                        Text(NSLocalizedString("About-Label", comment: "About label"))
                            .font(.system(size: 23))
                            .bold()
                            .padding(.leading)
                            .frame(alignment: .leading)
                    }
                    VStack (alignment: .leading, spacing: 10) {
                        Divider()
                        aboutUserView
                        Text(NSLocalizedString("Activity-Label", comment: "Activity label"))
                            .font(.system(size: 23))
                            .bold()
                            .padding(.leading)
                            .frame(alignment: .leading)
                        Divider()
                    }
                }
                NavigationLink(destination: ChatView(mainService: mainService, otherUserId: user.id).environmentObject(authManager), isActive: $isChatViewShowing) {
                    EmptyView()
                }
            }
        }
        .onAppear {
            mainService.isFollowing(followedUserId: user.id) { isFollowing, Error in
                print(isFollowing)
                self.isFollowing = isFollowing
                if let error = Error{
                    print(error.localizedDescription)
                }
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isSettingsViewShowing) {
            SettingsView(mainService: mainService).environmentObject(authManager)
        }
    }
    
    func calculateAge(from birthday: Date) -> Int {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: birthday, to: now)
        return ageComponents.year ?? 0
    }

    private var lastOnlineText: String {
        let now = Date()
        let timeDifference = now.timeIntervalSince(user.lastOnline)
        
        if timeDifference < 60 {
            return NSLocalizedString("Online", comment: "User is currently online")
        } else if timeDifference < 3600 { // Less than 1 hour
            let minutes = Int(timeDifference / 60)
            let minutesFormat = NSLocalizedString("minutes_ago", comment: "Time format for minutes ago")
            return String(format: minutesFormat, minutes)
        } else if timeDifference < 43200 { // Less than 12 hours
            let hours = Int(timeDifference / 3600)
            let hoursFormat = NSLocalizedString("hours_ago", comment: "Time format for hours ago")
            return String(format: hoursFormat, hours)
        } else {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: user.lastOnline, relativeTo: now)
        }
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
    
    private func initiateConversation() {
        mainService.ensureConversationExists(with: user.id) { success, conversation in
            if success {
                if !mainService.otherUsers.contains(where: { $0.id == user.id }) {
                    mainService.otherUsers.append(user)
                }
                    isChatViewShowing = true
                } else {
                    // Handle error or no conversation found
                }
            }
        }
    
    private var optionPanelView: some View {
        HStack {
            if user.id == mainService.clientUser?.id {
                Spacer()
                VStack {
                    Button(action: {}) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 30))
                    }
                    Text(NSLocalizedString("Edit-Profile-Button", comment: "Edit profile"))
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 18))
                }
                Spacer()
            } else {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "phone")
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "video")
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {
                    guard !mainService.processingFollow else { return }
                    
                    if isFollowing {
                        isFollowing = false
                        mainService.unfollow(userId: user.id)
                    } else {
                        isFollowing = true
                        mainService.follow(userId: user.id)
                    }
                }) {
                    Image(systemName: isFollowing ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.system(size: 30))
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 30))
                }
                Spacer()
            }
        }
        .padding()
    }
    
    private var userBioView: some View {
        HStack {
            Spacer()
            if user.bio != "" {
                Text(user.bio)
                    .font(.system(size: 18))
                    .padding()
            }
            Spacer()
        }
    }
    
    private var profilePictureView: some View {
        VStack {
            HStack {
                Spacer()
                ZStack (alignment: .bottomTrailing) {
                    // User image
                    KFImage(user.profileImageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Rectangle())
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Online status indicator
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundColor(getStatusColor(for: user.lastOnline))
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                Spacer()
            }
            Text(lastOnlineText)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
    }
    
    private var aboutUserView: some View {
        VStack (alignment: .leading) {
            Text(NSLocalizedString("Location-Label", comment: "Location label"))
                .bold()
                .font(.system(size: 18))
                .padding(.bottom, 2)
            
            HStack {
                Text("Country-Placeholder")
                    .font(.system(size: 18))
                Image(systemName: "location")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
            }
            if user.hobbiesAndInterests.count != 0 {
                Text(NSLocalizedString("Hobbies-Interests-Label", comment: "Hobbies and interests label"))
                    .bold()
                    .font(.system(size: 18))
                    .padding(.bottom, 2)
                
                ForEach(user.hobbiesAndInterests, id: \.self) {hobby in
                    Text(hobby)
                        .font(.system(size: 18))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var navigationBarView: some View {
        HStack {
            if user.id != mainService.clientUser?.id || mainService.selectedTab != 3 {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor) // Consistent color for icons
                }
                .padding(.leading, 15)
                if mainService.totalUnreadMessages > 0 {
                    Text("\(mainService.totalUnreadMessages)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }
            } else {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.accentColor) // Consistent color for icons
                    .hidden()
            }
        
            Spacer()

            VStack {
                // User Name
                Text("\(user.name), \(calculateAge(from: user.birthday))")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                HStack (spacing: 0){
                    Text("Country-Placeholder")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Image(systemName: "location")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            if user.id == mainService.clientUser?.id {
                Button(action: {
                    isSettingsViewShowing = true
                }) {
                    Image(systemName: "gearshape.2.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing, 15)
            } else if mainService.selectedTab != 0 {
                Button(action: initiateConversation) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing, 15)
            } else {
                    Image(systemName: "message.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                        .hidden()
                }
            
        }
        .shadow(radius: 5) // Optional shadow for depth
        .background(colorScheme == .dark ? Color.black : Color.white)
        .padding(.vertical, 5)
    }
    
    private var targetLanguagesView: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Target-Languages", comment: "Target languages "))
                .bold()
                .font(.system(size: 18))
            ForEach(sortedTargetLanguages, id: \.key) { language, proficiency in
                if let imageName = mainService.languageIdentifiers[language] {
                    HStack {
                        ZStack {
                            Image("\(imageName)_Flag")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(25)
                                .clipShape(Circle())
                            
                            ProficiencyBorder(proficiency: proficiency)
                                .frame(width: 40, height: 40)
                                .foregroundColor(interpolatedColorForProficiency(proficiency))
                        }
                        Text(NSLocalizedString(mainService.languageIdentifiers[language] ?? "", comment: "language"))
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }

    private var learningGoalsView: some View {
        VStack (alignment: .leading){
            if user.learningGoals != "" {
                Text(NSLocalizedString("Learning-Goals-Label", comment: "Learning goals label"))
                    .bold()
                    .font(.system(size: 18))
                    .padding(.bottom, 2)
                
                Text(user.learningGoals)
                    .font(.system(size: 18))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var sortedTargetLanguages: [(key: String, value: Int)] {
        user.targetLanguages.sorted { $0.value > $1.value }
    }
    
    private var nativeLanguagesView: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString("Native-Languages", comment: "Native languages"))
                .bold()
                .font(.system(size: 18))
            ForEach(user.nativeLanguages, id: \.self) { language in
                if let imageName = mainService.languageIdentifiers[language] {
                    HStack {
                        ZStack {
                            Image("\(imageName)_Flag")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .cornerRadius(25)
                                .clipShape(Circle())
                            
                            ProficiencyBorder(proficiency: 5)
                                .frame(width: 40, height: 40)
                                .foregroundColor(interpolatedColorForProficiency(5))
                        }
                        Text(NSLocalizedString(mainService.languageIdentifiers[language] ?? "", comment: "language"))
                            .font(.system(size: 18))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)  // Ensures VStack content aligns to the leading edge
        .padding()
    }
    
    func interpolatedColorForProficiency(_ proficiency: Int, maxProficiency: Int = 5) -> Color {
        // Define the start and end colors
        let startColor = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0) // Lighter Blue
         let endColor = UIColor(red: 0.0, green: 0.6, blue: 0.8, alpha: 1.0) // Slightly Darker Blue

        // Calculate the interpolation ratio (0.0 to 1.0)
        let ratio = CGFloat(proficiency) / CGFloat(maxProficiency)

        // Interpolate between the colors
        var startRed: CGFloat = 0, startGreen: CGFloat = 0, startBlue: CGFloat = 0, startAlpha: CGFloat = 0
        var endRed: CGFloat = 0, endGreen: CGFloat = 0, endBlue: CGFloat = 0, endAlpha: CGFloat = 0
        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)

        let interpolatedRed = startRed + ratio * (endRed - startRed)
        let interpolatedGreen = startGreen + ratio * (endGreen - startGreen)
        let interpolatedBlue = startBlue + ratio * (endBlue - startBlue)
        let interpolatedAlpha = startAlpha + ratio * (endAlpha - startAlpha)

        return Color(UIColor(red: interpolatedRed, green: interpolatedGreen, blue: interpolatedBlue, alpha: interpolatedAlpha))
    }
  
}

struct ProficiencyBorder: Shape {
    var proficiency: Int
    let maxProficiency = 5

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Calculate the end angle based on proficiency
        let endAngle = Double(proficiency) / Double(maxProficiency) * 360.0 - 90
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: rect.width / 2,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(endAngle),
                    clockwise: false)

        return path.strokedPath(.init(lineWidth: 3, lineCap: .round))
    }

    
}
