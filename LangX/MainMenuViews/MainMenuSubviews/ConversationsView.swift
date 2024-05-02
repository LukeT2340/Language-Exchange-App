import SwiftUI

struct ConversationsView: View {
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var mainService: MainService
    @Environment(\.colorScheme) var colorScheme
    @State private var showingAddFriendSheet = false
    @State private var manualRefreshToggle = false
    @State private var searchText = ""
    var body: some View {
        VStack {
            navBar
            VStack {
                ScrollView {
                    /*
                     RandomConversationRow(mainService: mainService)
                     .onTapGesture {
                     if mainService.searchingForPartner {
                     mainService.stopSearchingForPartner()
                     } else {
                     mainService.searchForPartner()
                     }
                     }
                     .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                     Button(role: .none) {
                     
                     } label: {
                     Label(NSLocalizedString("Settings", comment: "Settings"), systemImage: "gearshape")
                     }
                     }
                     */
                    ForEach(Array(mainService.sortedUserIds.enumerated()), id: \.element) { index, userId in
                        if let user = mainService.otherUsers.first(where: { $0.id == userId && (searchText.isEmpty || $0.name_lower.contains(searchText.lowercased())) }),
                           let messages = mainService.messages[userId],
                           let lastMessage = messages.last {
                            if let hiddenConversationIds = mainService.clientUser?.hiddenConversationIds {
                                if !hiddenConversationIds.contains(lastMessage.conversationId) || !searchText.isEmpty {
                                    let unreadCount = messages.filter { !$0.hasBeenRead && ($0.receiverId == mainService.clientUser?.id || $0.receiverId == "0") && !(mainService.clientUser?.hiddenConversationIds.contains(lastMessage.conversationId))!}.count
                                    NavigationLink(destination: ChatView(mainService: mainService, otherUserId: user.id).environmentObject(authManager)) {
                                        ConversationRow(user: user, lastMessage: lastMessage, unreadCount: unreadCount)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            mainService.hideConversation(conversationId: lastMessage.conversationId)
                                            mainService.markMessagesAsRead(for: user.id) { success in
                                                mainService.updateNotificationCount()
                                                mainService.updateBadgeCount()
                                            }
                                        } label: {
                                            Label(NSLocalizedString("Hide-Chat", comment: "Hide chat"), systemImage: "eye.slash")
                                                .font(.system(size: 20))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .id(manualRefreshToggle)
                .padding(.horizontal)
                Spacer()
            }
        }
        .animation(.easeInOut, value: mainService.messages)
        .animation(.easeInOut, value: mainService.clientUser)
        .animation(.easeInOut, value: mainService.otherUsers)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .sheet(isPresented: $showingAddFriendSheet) {
            SearchUsersView(mainService: mainService).environmentObject(authManager)
        }
        .onChange(of: mainService.otherUsers) { _ in
            self.manualRefreshToggle.toggle()
        }
    }
    private var navBar: some View {
        VStack {
            ZStack {
                Image(systemName: "square.and.pencil")
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                
                if mainService.hasSetupCompleted {
                    Text(NSLocalizedString("Chats", comment: "Chats"))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    HStack {
                        Text(NSLocalizedString("Loading-Messages", comment: "Loading messages"))
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        WhiteLoadingView()                        .font(.system(size: 20))
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.black)
                TextField(LocalizedStringKey("Search for users"), text: $searchText)
                    .simultaneousGesture(TapGesture().onEnded {
                        
                    }
                    )
                    .submitLabel(.done)
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(Color.white.opacity(0.7))
            .cornerRadius(15)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

