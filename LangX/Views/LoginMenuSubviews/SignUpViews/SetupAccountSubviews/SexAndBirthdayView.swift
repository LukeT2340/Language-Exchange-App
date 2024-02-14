//
//  SexSetupView.swift
//  Tandy
//
//  Created by Luke Thompson on 9/12/2023.
//

import SwiftUI

struct SexAndBirthdaySetupView: View {
    @ObservedObject var setupAccountModel: SetupAccountModel
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedSex: String = NSLocalizedString("Male-Option", comment: "Male option")
    @State private var isAnimating = false
    @State private var activeAlert: ActiveAlert?
    @State private var errorMessage: String = ""
    @Environment(\.colorScheme) var colorScheme
    

    private var isUserAdult: Bool {
        Calendar.current.dateComponents([.year], from: setupAccountModel.userObject.birthday, to: Date()).year! >= 18
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 10) {
            navigationBar
            header
            Spacer()
            sexPicker
            birthdayPicker
            Spacer()
            navigationButtons
        }
        .padding(.horizontal)
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .logoutConfirmation:
                return Alert(
                    title: Text(LocalizedStringKey("Confirm-Logout-Alert")),
                    message: Text(LocalizedStringKey("Ask-Logout")),
                    primaryButton: .destructive(Text(LocalizedStringKey("Logout-Button"))) {
                        authManager.signOut()
                    },
                    secondaryButton: .cancel()
                )
            case .inputError:
                return Alert(title: Text(NSLocalizedString("Error-Alert", comment: "Error")), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    private var navigationBar: some View {
        HStack {
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
            .frame(width: 70)
            Spacer()
            Text(LocalizedStringKey("Registration-Successful"))
                .font(.system(size: 25))
                .fontWeight(.medium)

            Spacer()
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.primary)
                .frame(width: 70)
                .hidden()

        }
    }
    
    @ViewBuilder
    private var header: some View {
        Text(LocalizedStringKey("Setup-Account-Text"))
            .font(.system(size: 20))
            .fontWeight(.light)
            .padding(.horizontal)
            .padding(.vertical)
    }
    
    @ViewBuilder
    private var sexPicker: some View {
        Text(LocalizedStringKey("Ask-Sex-Text"))
            .font(.system(size: 18))
            .fontWeight(.medium)

        HStack {
            ForEach(setupAccountModel.localizedSexOptions, id: \.self) { localizedOption in
                Button(action: {
                    selectedSex = localizedOption
                    setupAccountModel.selectSex(localizedSelection: localizedOption)
                }) {
                    HStack {
                        Text(localizedOption)
                            .foregroundColor(selectedSex == localizedOption ? Color(red: 16/255, green: 219/255, blue: 211/255) : .gray)
                    }
                    .padding()
                    .background(selectedSex == localizedOption ? Color(red: 0.39, green: 0.58, blue: 0.93).opacity(0.2) : Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
        }
        .padding(.bottom, 20)
        .animation(.easeInOut, value: selectedSex)
    }

    @ViewBuilder
    private var birthdayPicker: some View {
        Text(LocalizedStringKey("Ask-Birthday-Text"))
            .font(.system(size: 18))
            .fontWeight(.medium)

        DatePicker("", selection: $setupAccountModel.userObject.birthday, displayedComponents: .date)
            .datePickerStyle(WheelDatePickerStyle())
            .labelsHidden()
        
    }
    
    private var navigationButtons: some View {
        HStack {
            Spacer()
            
            NavigationLink(destination: UserNameAndProfilePictureSetupView(setupAccountModel: setupAccountModel)) {
                HStack {
                    Text(LocalizedStringKey("Next-Button"))
                    Image(systemName: "arrow.right")
                }
                .buttonStyle()
            }
            .disabled(!isUserAdult)
            .onTapGesture {
                if !isUserAdult {
                    self.errorMessage = NSLocalizedString("Error: Not 18", comment: "You must be at least 18 years old to use this app.")
                    self.activeAlert = .inputError
                }
            }
            .padding()
            .frame(width: 150)
        }
    }
    
    private func imageNameForLocalizedOption(_ localizedOption: String) -> String {
        if let index = setupAccountModel.localizedSexOptions.firstIndex(of: localizedOption),
           index < setupAccountModel.sexOptionsInEnglish.count {
            return "\(setupAccountModel.sexOptionsInEnglish[index])_Icon"
        }
        return "Default_Icon" // Fallback icon name
    }
}

struct BirthdaySetupView_Previews: PreviewProvider {
    static var previews: some View {
        SexAndBirthdaySetupView(setupAccountModel: SetupAccountModel(authManager: AuthManager()))
            .environmentObject(AuthManager())
    }
}
struct SexPicker: View {
    @Binding var selectedSex: String
    var localizedSexOptions: [String]
    var action: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(LocalizedStringKey("Ask-Sex-Text"))
                .font(.system(size: 20))
                .fontWeight(.light)
            
            HStack {
                ForEach(localizedSexOptions, id: \.self) { option in
                    Button(action: {
                        action(option)
                    }) {
                        Text(option)
                            .font(.title)
                            .fontWeight(.light)
                            .foregroundColor(selectedSex == option ? .white : .blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(selectedSex == option ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.vertical)
    }
}
