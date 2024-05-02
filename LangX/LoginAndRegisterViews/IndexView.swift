//
//  IndexView.swift
//  LangX
//
//  Created by Luke Thompson on 11/2/2024.
//

import SwiftUI

struct IndexView: View {
    @EnvironmentObject var appSettings: AppSettings
    let maxBackgrounds = 3
    @State private var currentBackground = 1
    @State private var nextBackground = 2
    @State private var backgroundTimer: Timer?
    @State var showLanguageSelectionView = false
    let availableLanguages: [Language] = [
        Language(localizedName: "English", code: "en"),
        Language(localizedName: "Español", code: "es"),
        Language(localizedName: "中文(简体)", code: "zh-Hans"), // Chinese (Simplified)
        Language(localizedName: "中文(繁體)", code: "zh-Hant"), // Chinese (Traditional)
        Language(localizedName: "हिन्दी", code: "hi"), // Hindi
        Language(localizedName: "العربية", code: "ar"), // Arabic
        Language(localizedName: "বাংলা", code: "bn"), // Bengali
        Language(localizedName: "Português", code: "pt"), // Portuguese
        Language(localizedName: "русский", code: "ru"), // Russian
        Language(localizedName: "日本語", code: "ja"), // Japanese
        Language(localizedName: "Deutsch", code: "de"), // German
        Language(localizedName: "Français", code: "fr"), // French
        Language(localizedName: "اردو", code: "ur"), // Urdu
        Language(localizedName: "Türkçe", code: "tr"), // Turkish
        Language(localizedName: "한국어", code: "ko"), // Korean
        Language(localizedName: "Italiano", code: "it"), // Italian
        Language(localizedName: "தமிழ்", code: "ta"), // Tamil
        Language(localizedName: "Tiếng Việt", code: "vi"), // Vietnamese
        Language(localizedName: "తెలుగు", code: "te"), // Telugu
        Language(localizedName: "मराठी", code: "mr"), // Marathi
        Language(localizedName: "ગુજરાતી", code: "gu"), // Gujarati
        Language(localizedName: "Polski", code: "pl"), // Polish
        Language(localizedName: "українська", code: "uk"), // Ukrainian
        Language(localizedName: "മലയാളം", code: "ml"), // Malayalam
    ]

    init() {
        let appearance = UINavigationBarAppearance()
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .medium)]

        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        HStack {
            NavigationView {
                VStack(alignment: .center) {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170)
                        .padding(.top, 90)
                    Spacer()
                    HStack {
                        Text(LocalizedStringKey("Over 30 languages"))
                            .foregroundColor(.white)
                            .font(.system(size: 30))
                            .fontWeight(.medium)
                        Spacer()
                    }
                    HStack {
                        Text(LocalizedStringKey("Learn faster"))
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                        Spacer()
                    }
                    Spacer()
                    NavigationLink(destination: LoginScreen().environmentObject(appSettings)) {
                        Text(LocalizedStringKey("Register/Login"))
                            .foregroundColor(Color("AccentColor"))
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(30)
                        
                    }
                    NavigationLink(destination: EmptyView()) {
                        Text(LocalizedStringKey("Take the tour"))
                            .foregroundColor(Color.white)
                            .fontWeight(.medium)
                            .padding(.vertical, 12)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal)
                .background(
                    ZStack {
                        Image("HomeScreenBackground\(currentBackground)")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                            .transition(AnyTransition.move(edge: .trailing).combined(with: .opacity))
                        LinearGradient(
                            gradient: Gradient(colors: [Color("Background2").opacity(0.6), Color("Background1").opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .opacity(0.95)
                        .edgesIgnoringSafeArea(.all)
                    }
                        .animation(Animation.linear(duration:2.5), value: currentBackground)
                )
                .navigationBarItems(trailing: Menu {
                        ForEach(availableLanguages, id: \.self) { language in
                            Button(action: {
                                appSettings.appLanguage = language
                            }) {
                                Text(language.localizedName)
                            }
                        }
                    } label: {
                        HStack (spacing: 3){
                            Image(systemName: "globe")
                            Text(appSettings.appLanguage.localizedName)
                        }
                        .foregroundColor(.white)
                    }
                            
                )
                .onAppear {
                    backgroundTimer?.invalidate()

                    backgroundTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
                         withAnimation {
                             currentBackground = nextBackground
                             nextBackground = (nextBackground % maxBackgrounds) + 1
                         }
                     }
               }
            }
        }
    }
}

struct WelcomeScreenPreviews: PreviewProvider {
    static var previews: some View {
        let appSettings = AppSettings()
        IndexView().environmentObject(appSettings)
    }
}

extension String {
func localized(_ lang:String) ->String {

    let path = Bundle.main.path(forResource: lang, ofType: "lproj")
    let bundle = Bundle(path: path!)

    return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
}}
