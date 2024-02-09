//
//  File.swift
//  Tandy
//
//  Created by Luke Thompson on 8/12/2023.
//

import SwiftUI

struct BirthdaySetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var activeAlert: ActiveAlert?
    @State private var errorMessage: String = ""
    @Environment(\.colorScheme) var colorScheme
    
    private var isUserAdult: Bool {
        Calendar.current.dateComponents([.year], from: setupViewModel.birthday, to: Date()).year! >= 18
    }
    
    var body: some View {
        VStack {
            HStack {
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
                Spacer()
                Button(action: {
                    self.activeAlert = .logoutConfirmation
                }) {
                    if !authManager.isLoggingOut {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.primary)
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 50)
            }
            
            Text(NSLocalizedString("Welcome to LanguageApp!", comment: "Welcome"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()

            Text(NSLocalizedString("Setup Account", comment: "Set account"))
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray : .black)
                .padding(.bottom, 30)
            
            Text(NSLocalizedString("Ask-Birthday", comment: "Ask birthday")) // Label text
                .font(.title) // Optional: Add font styling
                .padding(.bottom, 5) // Optional: Adjust padding as needed
            
            // DatePicker for Date of Birth
            DatePicker("", selection: $setupViewModel.birthday, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden() // Hides the default label of DatePicker
                .padding()

            Spacer()
            HStack {
                Spacer()
                // Navigation Link
                NavigationLink(destination: SexSetupView(setupViewModel: setupViewModel)) {
                    HStack {
                        Text(NSLocalizedString("Next-Button", comment: "Next button"))
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle()
                .frame(width: 120)
                .disabled(!isUserAdult)  // Disable button if user is not an adult
                .onTapGesture {
                    if !isUserAdult {
                        // Set error message and show alert if user is not 18
                        self.errorMessage = NSLocalizedString("Error: Not 18", comment: "You must be at least 18 years old to use this app.")
                        self.activeAlert = .inputError
                    }
                }
            }
            .padding()
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .logoutConfirmation:
                return Alert(
                    title: Text(NSLocalizedString("Confirm Logout", comment: "Confirm logout")),
                    message: Text(NSLocalizedString("Are you sure you want to log out?", comment: "Are you sure you want to log out?")),
                    primaryButton: .destructive(Text(NSLocalizedString("Logout", comment: "Logout"))) {
                        authManager.logout() {_, _ in}
                    },
                    secondaryButton: .cancel()
                )
            case .inputError:
                return Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
    }
}

