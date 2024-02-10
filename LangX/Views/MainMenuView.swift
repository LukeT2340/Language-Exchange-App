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
    @StateObject var peopleService: PeopleService
    //@StateObject var noteService: NoteService
    
    init(authManager: AuthManager) {
        _mainService = StateObject(wrappedValue: MainService(authManager: authManager))
        _peopleService = StateObject(wrappedValue: PeopleService(authManager: authManager))
        /*
        if let clientUser = authManager.clientUser {
            _noteService = StateObject(wrappedValue: NoteService(targetLanguages: Array(clientUser.targetLanguages.keys), clientUserId: clientUser.id) )
        } else {
            _noteService = StateObject(wrappedValue: NoteService(targetLanguages: [], clientUserId: "") )
        }
         */
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.systemBackground 
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
    
    
    var body: some View {
        NavigationView {
            TabView(selection: $mainService.selectedTab) {
                PeopleView(mainService: mainService, peopleService: peopleService).environmentObject(authManager)
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text(NSLocalizedString("Discover", comment: "Discover"))
                    }
                    .tag(1)
                
                ConversationsView(mainService: mainService).environmentObject(authManager)
                
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text(NSLocalizedString("Messages", comment: "Messages"))
                    }
                    .tag(0)
                    .badge(mainService.totalUnreadMessages)


                /*
                 NotesView(noteService: noteService, messageService: messageService, userService: userService).environmentObject(authManager)
                 .tabItem {
                 Image(systemName: "square.and.pencil")
                 Text(NSLocalizedString("Notes", comment: "Notes"))
                 }
                 .tag(2)
                 
                 */
                if let clientUser = mainService.clientUser {
                    ProfileView(mainService: mainService, user: clientUser).environmentObject(authManager)
                        .tabItem {
                            Image(systemName: "person.crop.circle")
                            Text(NSLocalizedString("Me", comment: "Me"))
                        }
                        .tag(3)
                }
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
