//
//  LanguageGoalsSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 10/12/2023.
//

import SwiftUI

struct LanguageGoalsSetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var navigateToHobbiesAndInterestsSetupView: Bool = false
    @State private var showAlert = false
    @State private var alertReason: AlertReason?
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    enum AlertReason {
        case emptyGoals, goalsTooLong
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
            Text(LocalizedStringKey("Ask-Learning-Goals-Text"))
                .font(.system(size: 18))
                .fontWeight(.light)
                .padding(.bottom)
            
            goalsInput
            NavigationLink(destination: HobbiesAndInterestsSetupView(setupAccountModel: setupAccountModel), isActive: $navigateToHobbiesAndInterestsSetupView) {
                EmptyView()
            }
            Spacer()
            navigationButtons

        }
        .alert(isPresented: $showAlert) {
            switch alertReason {
            case .emptyGoals:
                return Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Error alert")),
                    message: Text(NSLocalizedString("Error: Empty-Goals", comment: "Error: Empty goals")),
                    primaryButton: .destructive(Text(NSLocalizedString("Continue-Button", comment: "Continue button")), action: {
                        navigateToHobbiesAndInterestsSetupView = true
                    }),
                    secondaryButton: .cancel()
                )
            case .goalsTooLong:
                return Alert(
                    title: Text(NSLocalizedString("Error-Alert", comment: "Error alert")),
                    message: Text(NSLocalizedString("Error: Goals-Too-Long", comment: "Error: Goals too long")),
                    dismissButton: .default(Text("OK"))
                )
            default:
                return Alert(title: Text("Error"))
            }
        }
        .gesture(
            TapGesture().onEnded { _ in
                self.hideKeyboard()
            }
        )
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
    }
    private var navigationBar: some View {
        HStack {
            Image("Icon")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .hidden()
            
            Spacer()
            
            Text(LocalizedStringKey("Language-Goals-Text"))
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
    private var goalsInput: some View {
        TextEditor(text: $setupAccountModel.userObject.learningGoals)
            .frame(height: 180)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(8)
            .simultaneousGesture(TapGesture().onEnded {
                // This gesture will not interfere with the text field
            })
        HStack {
            Spacer()
            Text("\(learningGoalsCharacterCount)/200")
                .font(.system(size: 15))
                .fontWeight(.light)
                .foregroundColor(areLearningGoalsWithinCharacterLimit ? .green : .red)
                .padding(.trailing)
                .animation(nil)
        }
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
                if setupAccountModel.userObject.learningGoals.isEmpty  {
                    alertReason = .emptyGoals
                    showAlert = true
                } else if setupAccountModel.userObject.learningGoals.count > 200 {
                    alertReason = .goalsTooLong
                    showAlert = true
                } else {
                    navigateToHobbiesAndInterestsSetupView = true
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

struct LanguageGoalsSetupView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageGoalsSetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
