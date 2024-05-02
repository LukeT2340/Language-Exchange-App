//
//  AppSettings.swift
//  LangX
//
//  Created by Luke Thompson on 13/4/2024.
//

import Foundation
import SwiftUI

struct Language: Codable, Hashable {
    var localizedName: String
    var code: String
}

// Contains various app settings (language, etc)
class AppSettings: ObservableObject {
    private let defaultLanguage = Language(localizedName: "English", code: "en")
    
    @Published var appLanguage: Language {
        didSet {
            saveLanguage()
            changeAppLanguage()
        }
    }
    
    init() {
        if let savedLanguageData = UserDefaults.standard.data(forKey: "AppLanguage"),
           let savedLanguage = try? JSONDecoder().decode(Language.self, from: savedLanguageData) {
            self.appLanguage = savedLanguage
        } else {
            self.appLanguage = defaultLanguage
            saveLanguage()
        }
        changeAppLanguage()
    }
    
    private func saveLanguage() {
        if let encodedLanguage = try? JSONEncoder().encode(appLanguage) {
            UserDefaults.standard.set(encodedLanguage, forKey: "AppLanguage")
        }
    }
    
    private func changeAppLanguage() {
        UserDefaults.standard.set([appLanguage.code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
    }
}
