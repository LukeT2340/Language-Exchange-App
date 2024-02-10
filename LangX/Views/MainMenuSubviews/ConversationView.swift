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
            navigationBar
            /*
            HStack {
                // Left Icon
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 53, height: 53)
                    .padding(.leading)
                
                Spacer()
                
                // Conditional Content (App Name or Progress View)
                if mainService.hasSetupCompleted {
                    Text(NSLocalizedString("App-Name", comment: "App name"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center) // Align text to the center of its frame
                } else {
                    HStack {
                        Text(NSLocalizedString("Loading-Messages", comment: "Loading messages"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                        LoadingView()
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the progress view and text together
                }
                
                Spacer()
                
                // Right Button
                Button(action: {
                    showingAddFriendSheet = true
                }) {
                    Image(systemName: "person.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .padding(.trailing)
                        .padding(.leading)
                }
            }
            .padding(.bottom)
            .overlay(
                Rectangle()
                    .frame(height: 0.3)
                    .foregroundColor(Color.gray),
                alignment: .bottom
            )
             */
            VStack {
                List {
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
                                // Your button action here
                            } label: {
                                Label(NSLocalizedString("Settings", comment: "Settings"), systemImage: "gearshape")
                            }
                        }
                    
                    ForEach(Array(mainService.sortedUserIds.enumerated()), id: \.element) { index, userId in
                        if let user = mainService.otherUsers.first(where: { $0.id == userId }),
                           let messages = mainService.messages[userId],
                           let lastMessage = messages.last {
                            if let hiddenConversationIds = mainService.clientUser?.hiddenConversationIds,
                               !hiddenConversationIds.contains(lastMessage.conversationId) {
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
                .listStyle(PlainListStyle())
                .id(manualRefreshToggle)
                Spacer()
                    
                
            }
        }
        .animation(.easeInOut, value: mainService.messages)
        .animation(.easeInOut, value: mainService.clientUser)
        .animation(.easeInOut, value: mainService.otherUsers)
        .sheet(isPresented: $showingAddFriendSheet) {
            // The view that you want to present goes here
            SearchUsersView(mainService: mainService).environmentObject(authManager)
        }
        .onChange(of: mainService.otherUsers) { _ in
            self.manualRefreshToggle.toggle()
        }
    }
    private var navigationBar: some View {
        VStack {
            ZStack {
                HStack {
                    
                    Text(LocalizedStringKey("Edit"))
                        .foregroundColor(.accentColor)
                    Spacer()
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
                // Conditional Content (App Name or Progress View)
                if mainService.hasSetupCompleted {
                    Text(NSLocalizedString("Chats", comment: "Chats"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center) // Align text to the center of its frame
                } else {
                    HStack {
                        Text(NSLocalizedString("Loading-Messages", comment: "Loading messages"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                        LoadingView()
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // Center the progress view and text together
                }
            }
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField(LocalizedStringKey("Search for messages or users"), text: $searchText)
                    .simultaneousGesture(TapGesture().onEnded {
                        // This gesture will not interfere with the text field
                    }
                    )
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

