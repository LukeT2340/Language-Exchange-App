//
//  TabBar.swift
//  LangX
//
//  Created by Luke Thompson on 30/4/2024.
//

import SwiftUI

struct TabBar: View {
    @AppStorage("selectedTab") var selectedTab: Tab = .messages
    var badge: [Tab: Int]
    @State var tabItemWidth: CGFloat = 0
    
    var body: some View {
        HStack {
            buttons
        }
        .padding(.horizontal, 8)
        .padding(.top, 14)
        .frame(height: 88, alignment: .top)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .overlay(
            overlay
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
    }
    
    
    var buttons: some View {
        ForEach(tabItems) { item in
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = item.tab
                }
            } label: {
                VStack(spacing: 0) {
                    if item.tab == .create {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.accentColor)
                                 .frame(width: 45, height: 35)

                            Image(systemName: item.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 20).bold())

                        }
                        Text(item.text)
                            .font(.caption2)
                            .lineLimit(1)
                            .hidden()
                        
                    } else {
                        ZStack {
                            Image(systemName: item.icon)
                                .symbolVariant(.fill)
                                .font(.system(size: 20).bold())
                                .frame(width: 44, height: 29)
                            let badgeNumber = badge[item.tab] ?? 0
                            if badgeNumber > 0 {
                                Text(String(badgeNumber))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 10, y: -10)
                            }
                        }
                            
                            Text(item.text)
                                .font(.caption2)
                                .lineLimit(1)
                        
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(selectedTab == item.tab ? .primary : .secondary)
            .foregroundColor(selectedTab == item.tab ? Color("AccentColor") : .secondary)
            .overlay(
                GeometryReader { proxy in
                    Color.clear.preference(key: TabPreferenceKey.self, value: proxy.size.width)
                }
            )
            .onPreferenceChange(TabPreferenceKey.self) { value in
                tabItemWidth = value
            }
        }
    }
    
    var overlay: some View {
        HStack {
            if selectedTab == .messages {
                Spacer()
                Spacer()
                Spacer()
            }
            if selectedTab == .contacts {
                Spacer()
            }
            if selectedTab == .profile {
                Spacer()
            }
            Rectangle()
                .fill(Color("AccentColor"))
                .frame(width: 28, height: 5)
                .cornerRadius(3)
                .frame(width: tabItemWidth)
                .frame(maxHeight: .infinity, alignment: .top)
                .opacity(selectedTab == .create ? 0 : 1)
            if selectedTab == .home {
                Spacer()
            }
            if selectedTab == .messages {
                Spacer()
            }
            if selectedTab == .contacts {
                Spacer()
                Spacer()
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .animation(.easeInOut, value: selectedTab)
    }
}
