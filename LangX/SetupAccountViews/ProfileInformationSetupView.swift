//
//  ProfileInformationSetupView.swift
//  LangX
//
//  Created by Luke Thompson on 29/4/2024.
//

import SwiftUI

struct ProfileInformationSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutAlert = false
    @State private var showAlert = false
    @State private var navigateToNextView = false
    @State private var showingImagePicker = false

    @State private var birthdaySheetIsShowing = false
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack (spacing: 0) {
            navBar
            ScrollView {
                profilePicture
                Text(LocalizedStringKey("Basic-information"))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .padding(.horizontal, 32)
                
                VStack (spacing: 15 ) {
                    username
                    Divider()
                    gender
                    Divider()
                    birthday
                }
                .foregroundColor(.white)
                .padding()
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(5)
                .padding(.horizontal, 32)
                .padding(.bottom)
                
                Text(LocalizedStringKey("Learning"))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .padding(.horizontal, 32)
                VStack (spacing: 15) {
                    learningGoals
                    Divider()
                    languagePartner
                }
                .foregroundColor(.white)
                .padding()
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(5)
                .padding(.horizontal, 32)
                .padding(.bottom)

                Text(LocalizedStringKey("More about you"))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                    .padding(.horizontal, 32)
                VStack (spacing: 15) {
                    hobbies
                    Divider()
                    bio
                }
                .foregroundColor(.white)
                .padding()
                .background(Color("AccentColor").opacity(0.2))
                .cornerRadius(5)
                .padding(.horizontal, 32)

            }
            Spacer()
            navigationButtons
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(isPresented: $showingImagePicker, selectedImage: $setupAccountModel.profileImage)
        }
        .sheet(isPresented: $birthdaySheetIsShowing) {
            ChangeBirthdayView(birthday: $setupAccountModel.userObject.birthday)
        }
        .navigationBarBackButtonHidden()
    }
    
    private var navBar: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea(.all)
                .background(.ultraThinMaterial.opacity(0.6))
                .frame(height: 60)
            
            Text(LocalizedStringKey("Personal-Information"))
                .font(.system(size: 22))
                .foregroundColor(.white)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .shadow(radius: 10)
    }
    
    private var profilePicture: some View {
        ZStack {
            if let profileImage = setupAccountModel.profileImage {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .transition(.scale)
            } else {
                Color.clear
                    .background(.ultraThinMaterial)
                    .opacity(showingImagePicker ? 0.1 : 0.3)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .cornerRadius(10)



                Image(systemName: "camera.circle.fill")
                    .frame(width: 100, height: 100, alignment: .bottomTrailing)
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
        }
        .onTapGesture {
            showingImagePicker = true
        }
        .animation(.default, value: setupAccountModel.profileImage)
        .foregroundColor(.white)
        .padding(.top, 15)
    }
    
    private var username: some View {
        NavigationLink(destination: ChangeUsernameView(username: $setupAccountModel.userObject.name)) {
            HStack {
                Image(systemName: "pencil")
                setupAccountModel.userObject.name.isEmpty ?
                Text(LocalizedStringKey("Username")) :
                Text(setupAccountModel.userObject.name)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var gender: some View {
        NavigationLink(destination: ChangeUsernameView(username: $setupAccountModel.userObject.name)) {
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(setupAccountModel.userObject.sex == "Male" ? Color("AccentColor") : .pink)
                setupAccountModel.userObject.sex.isEmpty ?
                Text(LocalizedStringKey("Gender")) :
                Text(LocalizedStringKey(setupAccountModel.userObject.sex))
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var birthday: some View {
        Button(action: {
            birthdaySheetIsShowing.toggle()
        }) {
            HStack {
                Image(systemName: "calendar")
                setupAccountModel.userObject.sex.isEmpty ?
                Text(LocalizedStringKey("Birthday")) :
                Text(DateFormatter.localizedString(from: setupAccountModel.userObject.birthday, dateStyle: .long, timeStyle: .none))
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var learningGoals: some View {
        Button(action: {
            birthdaySheetIsShowing.toggle()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                setupAccountModel.userObject.learningGoals.isEmpty ?
                Text(LocalizedStringKey("Learning-goals"))               .lineLimit(1)
 :
                Text(setupAccountModel.userObject.learningGoals)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var languagePartner: some View {
        Button(action: {
            birthdaySheetIsShowing.toggle()
        }) {
            HStack {
                Image(systemName: "person.2.fill")
                setupAccountModel.userObject.learningGoals.isEmpty ?
                Text(LocalizedStringKey("Ideal-language-partner"))
                    .lineLimit(1)
 :
                Text(setupAccountModel.userObject.learningGoals)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var hobbies: some View {
        Button(action: {
            birthdaySheetIsShowing.toggle()
        }) {
            HStack {
                Image(systemName: "face.smiling.fill")
                setupAccountModel.userObject.learningGoals.isEmpty ?
                Text(LocalizedStringKey("Hobbies"))
                    .lineLimit(1)
 :
                Text(setupAccountModel.userObject.learningGoals)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var bio: some View {
        Button(action: {
            birthdaySheetIsShowing.toggle()
        }) {
            HStack {
                Image(systemName: "doc.text.fill")
                setupAccountModel.userObject.learningGoals.isEmpty ?
                Text(LocalizedStringKey("Bio"))
                    .lineLimit(1)
 :
                Text(setupAccountModel.userObject.learningGoals)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
    
    private var navigationButtons: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left")
                    Text(NSLocalizedString("Back-Button", comment: "Back button"))
                }
            }
            .buttonStyle()
            Spacer()
            NavigationLink(destination: ProfileInformationSetupView(setupAccountModel: setupAccountModel), isActive: $navigateToNextView) {
                EmptyView()
            }
            Button(action: {
                guard let image = setupAccountModel.profileImage else {
                    print("Profile image is not set")
                    return
                }
                guard setupAccountModel.userObject.name.count > 2 else {
                    print("Username not set")
                    return
                }
                guard isOver18(birthdate: setupAccountModel.userObject.birthday) else {
                    print("User not over 18")
                    return
                }
                Task {
                     let success = await setupAccountModel.createUserProfileData()
                     if success {
                         authManager.checkIfAccountIsSetup() { }
                         print("User profile data created successfully!")
                     } else {
                         print("Failed to create user profile data.")
                     }
                 }
            }) {
                HStack {
                    Text(LocalizedStringKey("Complete"))
                    if setupAccountModel.creatingUserProfile {
                        LoadingView()
                    } else {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .buttonStyle()
            .padding(.vertical)

        }
        .padding(.horizontal)
    }
    
    func isOver18(birthdate: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let eighteenYearsAgo = calendar.date(byAdding: .year, value: -18, to: currentDate) else {
            return false
        }
        
        return birthdate <= eighteenYearsAgo
    }

}

struct ProfileInformationSetupView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInformationSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
