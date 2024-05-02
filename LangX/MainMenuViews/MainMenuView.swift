//
//  MainMenuView.swift
//  LangLeap
//
//  Created by Luke Thompson on 14/11/2023.
//

import SwiftUI
import FirebaseFirestore
import Combine

struct MainMenuView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject var mainService: MainService
    
    init(authManager: AuthManager) {
        _mainService = StateObject(wrappedValue: MainService(authManager: authManager))
         
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.systemBackground 
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    
    var body: some View {
        NavigationView {
            ZStack {
                if mainService.selectedTab == .home {
                    EmptyView()
                } else if mainService.selectedTab == .contacts {
                    PeopleView(mainService: mainService).environmentObject(authManager)
                } else if mainService.selectedTab == .create {
                    EmptyView()
                } else if mainService.selectedTab == .messages {
                    ConversationsView(mainService: mainService).environmentObject(authManager)
                } else if mainService.selectedTab == .profile {
                    if let clientUser = mainService.clientUser {
                        ProfileView(mainService: mainService, user: clientUser).environmentObject(authManager)
                    }
                }
                TabBar(selectedTab: mainService.selectedTab, badge: [.home: 0, .contacts: 0, .create: 0, .messages: mainService.totalUnreadMessages, .profile: 0])
            }
            .overlay(
                BannerView(mainService: mainService, banner: mainService.banners.last)
                    .transition(.move(edge: .top)) // Transition effect
                    .animation(.easeInOut, value: mainService.banners.isEmpty)
                , alignment: .top
            )
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthManager()
        let mainService = MainService(authManager: authManager)
        
        MainMenuView(authManager: authManager)
            .environmentObject(authManager)
    }
}
