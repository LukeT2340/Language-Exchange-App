//
//  SearchUsersView.swift
//  Tandy
//
//  Created by Luke Thompson on 26/12/2023.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct SearchUsersView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    @StateObject private var searchHelper = SearchHelper()

    @State private var searchText = ""

    var body: some View {
        NavigationView {
            VStack {
                Text(NSLocalizedString("Search-Title", comment: "Search-Title"))
                    .font(.system(size: 18))
                TextField(NSLocalizedString("Search-User-Placeholder", comment: "Search User Placeholder"), text: $searchHelper.searchText)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.secondary, lineWidth: 0.5)
                    )
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .keyboardType(.webSearch)
                    .onSubmit {
                        searchHelper.users = []
                        searchHelper.searchUsers()
                    }
                if let clientUser = mainService.clientUser {
                    Text("\(NSLocalizedString("My-ID", comment: "My")): \(clientUser.id)")
                        .font(.system(size: 12))
                }
                ScrollView(.vertical, showsIndicators: true) {
                    VStack (spacing: 0) {
                        ForEach(searchHelper.users) { user in
                            NavigationLink(destination: ProfileView(mainService: mainService, user: user).environmentObject(authManager)) {
                                UserRow(user: user)
                            }
                            //.buttonStyle(PlainButtonStyle())
                        }
                        .frame(maxWidth: .infinity)
                        Color.clear
                            .frame(height: 1)
                            .onBottomReached {
                                if !searchHelper.isLoadingUsers {
                                    searchHelper.searchUsers()
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .padding()
            .gesture(
                TapGesture().onEnded { _ in
                    self.hideKeyboard()
                }
            )
        }
    }
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
