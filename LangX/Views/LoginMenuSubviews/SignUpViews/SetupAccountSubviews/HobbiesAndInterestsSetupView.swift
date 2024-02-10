//
//  HobbiesAndInterestsSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 10/12/2023.
//

import SwiftUI

struct HobbiesAndInterestsSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var navigateToBioSetupView: Bool = false
    @State private var showAlert = false
    @State private var alertReason: AlertReason?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    enum AlertReason {
        case emptyHobbies, tooManyHobbies
    }
    
    private var learningGoalsCharacterCount: Int {
        setupAccountModel.userObject.learningGoals.count
    }
    
    private var areLearningGoalsWithinCharacterLimit: Bool {
        learningGoalsCharacterCount <= 200 // Assuming a limit of 200 characters
    }
    
    var body: some View {
        VStack {
            navigationBar
            Text(LocalizedStringKey("Ask-Hobbies-And-Interests"))
                .font(.system(size: 18))
                .fontWeight(.light)
                .padding(.bottom)
            
            hobbiesInput
            suggestedHobbies
            selectedHobbies
            NavigationLink(destination: BioSetupView(setupViewModel: setupAccountModel), isActive: $navigateToBioSetupView) {
                EmptyView()
            }
            Spacer()
            navigationButtons
            
        }
        .alert(isPresented: $showAlert) {
            switch alertReason {
            case .emptyHobbies:
                return Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Error alert")),
                    message: Text(NSLocalizedString("Error: Empty-Hobbies", comment: "Error: Empty hobbies")),
                    primaryButton: .destructive(Text(NSLocalizedString("Continue-Button", comment: "Continue button")), action: {
                        navigateToBioSetupView = true
                    }),
                    secondaryButton: .cancel()
                )
            case .tooManyHobbies:
                return Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Error alert")),
                    message: Text(NSLocalizedString("Error: Too-Many-Hobbies", comment: "Error: Too many hobbies")),
                    dismissButton: .default(Text("OK"))
                )
            default:
                return Alert(title: Text("Error"))
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .padding()
        .background(colorScheme == .light ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.95, green: 0.98, blue: 1.00), // Very light pastel blue
                            Color(red: 0.85, green: 0.90, blue: 0.95)  // Slightly deeper pastel blue
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ) : LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.18, green: 0.23, blue: 0.28), // Slightly lighter dark slate blue
                            Color(red: 0.28, green: 0.33, blue: 0.38)  // A bit lighter and softer slate blue
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
        )
        
        .navigationBarHidden(true)
        .animation(.easeInOut, value: setupAccountModel.userObject.hobbiesAndInterests)
        .animation(.easeInOut, value: setupAccountModel.suggestedHobbies)
        .animation(.easeInOut, value: setupAccountModel.hobbiesAndInterestsSearchResult)
    }
    private var navigationBar: some View {
        HStack {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .hidden()
            
            Spacer()
            
            Text(LocalizedStringKey("Hobbies-And-Interests-Text"))
                .font(.system(size: 25))
                .fontWeight(.medium)
            
            
            Spacer()
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .opacity(isAnimating ? 1.0 : 0.8)
                .onAppear() {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        isAnimating.toggle()
                    }
                }
                .frame(width: 70)
        }
    }
    
    @ViewBuilder
    private var hobbiesInput: some View {
        VStack (alignment: .leading) {
            HStack {
                TextField(LocalizedStringKey("Hobbies-Placeholder"), text: $setupAccountModel.hobbiesAndInterestsSearchText)
                    .padding(.horizontal)
                    .simultaneousGesture(TapGesture().onEnded {
                        // This gesture will not interfere with the text field
                    })
                    
                Button(action: {
                    guard !setupAccountModel.hobbiesAndInterestsSearchText.isEmpty else {
                        return
                    }
    
                    setupAccountModel.addHobby(hobby: setupAccountModel.hobbiesAndInterestsSearchText)
                    setupAccountModel.hobbiesAndInterestsSearchText = ""
                }) {
                    Text(LocalizedStringKey("Add-Button"))
                        .foregroundColor(setupAccountModel.hobbiesAndInterestsSearchText.count < 21 ? Color.blue : Color.gray)
                }
                .onChange(of: setupAccountModel.hobbiesAndInterestsSearchText) { newValue in
                    setupAccountModel.searchHobbies()
                }
                .disabled(setupAccountModel.hobbiesAndInterestsSearchText.count > 20)
            }
            ForEach(setupAccountModel.hobbiesAndInterestsSearchResult) { hobby in
                Button(action : {
                    setupAccountModel.addHobby(hobby: hobby.name)
                    setupAccountModel.hobbiesAndInterestsSearchResult.removeAll()
                    setupAccountModel.hobbiesAndInterestsSearchText = ""
                }) {
                    HStack {
                        Text(hobby.name)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                    .padding()
                    .background(Color(red: 0.39, green: 0.58, blue: 0.93).opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .cornerRadius(10)
    }
    
    private var selectedHobbies: some View {
        VStack (alignment: .leading) {
            Text(String(format: NSLocalizedString("Selected-Hobbies-Account", comment: "Number of selected hobbies"), "\(setupAccountModel.userObject.hobbiesAndInterests.count)"))
                .fontWeight(.light)
                .font(.system(size: 16))
            ScrollView (.horizontal) {
                HStack {
                    ForEach(setupAccountModel.userObject.hobbiesAndInterests.reversed(), id: \.self) { hobbyName in
                        Button(action: {
                            setupAccountModel.removeHobby(hobbyName: hobbyName)
                        }) {
                            Text(hobbyName)
                                .lineLimit(1)
                                .fontWeight(.light)
                                .foregroundColor(.white)
                            Image(systemName: "minus.circle")
                                .fontWeight(.light)
                                .foregroundColor(.white)
                        }
                        .padding(10)
                        .background(Color(red: 40/255, green: 150/255, blue: 255/255))
                        .cornerRadius(15)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var suggestedHobbies: some View {
        VStack (alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(setupAccountModel.suggestedHobbies) { hobby in
                        Button(action: {
                            setupAccountModel.addHobby(hobby: hobby.name)
                        }) {
                            Text(hobby.name)
                                .fontWeight(.light)
                                .foregroundColor(.primary)
                            Image(systemName: "plus.circle")
                                .foregroundColor(.primary)
                        }
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var navigationButtons: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "arrow.left") // System-provided name for a left-pointing arrow
                    Text(NSLocalizedString("Back-Button", comment: "Back button"))
                }
            }
            .buttonStyle() // Apply any custom button style you have
            .frame(width: 120)
            Spacer()
            
            Button(action: {
                if setupAccountModel.userObject.hobbiesAndInterests.isEmpty  {
                    alertReason = .emptyHobbies
                    showAlert = true
                } else if setupAccountModel.userObject.hobbiesAndInterests.count > 10 {
                    alertReason = .tooManyHobbies
                    showAlert = true
                } else {
                    navigateToBioSetupView = true
                }
            }) {
                HStack {
                    Text(NSLocalizedString("Next-Button", comment: "Next-Button"))
                    Image(systemName: "arrow.right")
                }
            }
            .buttonStyle()
            .frame(width: 120)
            
            
        }
        .padding()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HobbiesAndInterestsSetupView_Previews: PreviewProvider {
    static var previews: some View {
        HobbiesAndInterestsSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
