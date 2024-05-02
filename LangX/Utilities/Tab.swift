//
//  Tab.swift
//  LangX
//
//  Created by Luke Thompson on 30/4/2024.
//

import SwiftUI

struct TabItem: Identifiable {
    var id = UUID()
    var text: String
    var icon: String
    var tab: Tab
}

var tabItems = [
    TabItem(text: NSLocalizedString("Home", comment: ""), icon: "house", tab: .home),
    TabItem(text: NSLocalizedString("Contacts", comment: ""), icon: "person.3", tab: .contacts),
    TabItem(text: NSLocalizedString("Create", comment: ""), icon: "plus", tab: .create),
    TabItem(text: NSLocalizedString("Messages", comment: ""), icon: "message", tab: .messages),
    TabItem(text: NSLocalizedString("Profile", comment: ""), icon: "person", tab: .profile)
]

enum Tab: String {
    case home
    case contacts
    case create
    case messages
    case profile
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
