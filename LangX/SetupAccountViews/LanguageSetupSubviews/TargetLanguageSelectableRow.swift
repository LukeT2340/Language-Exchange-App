//
//  TargetLanguageSelectableRow.swift
//  SpeakSwap
//
//  Created by Luke Thompson on 20/1/2024.
//

import SwiftUI

struct TargetLanguageSelectableRow: View {
    let language: String
    let flagImageName: String
    @Binding var fluencyLevel: Int?
    
    var action: () -> Void

    var isSelected: Bool {
        fluencyLevel != nil
    }
    
    let proficiencyDescriptions = [
        1: NSLocalizedString("Beginner-Text", comment: "Beginner proficiency level"),
        2: NSLocalizedString("Elementary-Text", comment: "Elementary proficiency level"),
        3: NSLocalizedString("Intermediate-Text", comment: "Intermediate proficiency level"),
        4: NSLocalizedString("Advanced-Text", comment: "Advanced proficiency level"),
        5: NSLocalizedString("Fluent-Text", comment: "Fluent proficiency level")
    ]

    var body: some View {
        VStack {
            HStack {
                Text(language)
                    .font(isSelected ? .system(size: 20) : .system(size: 18))
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(.white)
                Spacer()
                Image(flagImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                        .scaleEffect(isSelected ? 1.2 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 1), value: isSelected)
                }
            }
            if isSelected {
                Divider()
                let localizedLanguageName = NSLocalizedString(language, comment: "Language name")
                Text(String(format: NSLocalizedString("Ask-Language-Proficiency-Text", comment: "Ask user for their language proficiency"), localizedLanguageName))
                    .fontWeight(.medium)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                HStack {
        
                    ForEach(1...5, id: \.self) { i in
                        if let description = proficiencyDescriptions[i] {
                            Text(description)
                                .padding(.horizontal, fluencyLevel == i ? 8 : 5)
                                .padding(.vertical, 15)
                                .lineLimit(1)
                                .font(.system(size: 12))
                                .minimumScaleFactor(0.6)
                                .fontWeight(.medium)
                                .frame(idealWidth: 200, maxWidth: .infinity)
                                .foregroundColor(fluencyLevel == i ? Color("AccentColor") : .white)
                                .background(fluencyLevel == i ? .white : Color.gray.opacity(0.2))
                                .cornerRadius(10)
                                .onTapGesture {
                                    self.fluencyLevel = i
                                }
                                .padding(.bottom, fluencyLevel == i ? 5 : 0)
                            
                        }
                    }
                    .animation(.easeInOut, value: fluencyLevel)

               
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(isSelected ? Color("Background2").opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut, value: isSelected)
        .padding(.trailing, 8)

    }
}

