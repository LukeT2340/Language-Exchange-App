//
//  ChangeUsernameView.swift
//  LangX
//
//  Created by Luke Thompson on 29/4/2024.
//

import SwiftUI

struct ChangeUsernameView: View {
    @Binding var username: String
    @Environment(\.presentationMode) var presentationMode
    @State var usernameWithinLimit = false
    @State var usernameDoesntContainSpecialCharactersOrNumbers = false
    var body: some View {
        VStack (spacing: 0){
            textField
            conditions
            Spacer()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text(LocalizedStringKey("Complete"))
                    Image(systemName: "checkmark")
                }
                .padding(.horizontal, 50)
                .buttonStyle()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
        .onAppear {
            checkUsernameValidity()
        }
    }
    
    @ViewBuilder
    private var textField: some View {
        Text(LocalizedStringKey("Ask-Username-Text"))
            .font(.system(size: 20))
            .fontWeight(.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .shadow(radius: 5)
            .padding(.bottom, 5)
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 20))
                TextField(LocalizedStringKey("Username"), text: $username)
                    .onChange(of: username){ _ in
                        checkUsernameValidity()
                    }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding(.bottom)
    }
    
    private var conditions: some View {
        VStack (alignment: .leading, spacing: 5){
            HStack {
                Text(LocalizedStringKey("Username-within-limit"))
                Image(systemName: usernameWithinLimit ? "checkmark.circle.fill" : "circle")
            }
            .foregroundColor(usernameWithinLimit ? Color("AccentColor") : .gray)
            HStack {
                Text(LocalizedStringKey("Username-no-characters-or-numbers"))
                Image(systemName: usernameDoesntContainSpecialCharactersOrNumbers ? "checkmark.circle.fill" : "circle")
            }
            .foregroundColor(usernameDoesntContainSpecialCharactersOrNumbers ? Color("AccentColor") : .gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func checkUsernameValidity() {
        usernameWithinLimit = username.count > 2 && username.count < 15 ? true : false
        let usernameRegex = "^[a-zA-Z\\p{Han}\\p{Hiragana}\\p{Katakana}\\p{Arabic}]+$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        usernameDoesntContainSpecialCharactersOrNumbers = usernamePredicate.evaluate(with: username) && username.count != 0
    }
}

struct ChangeUsernameView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeUsernameView(username: .constant("Luke"))
    }
}
