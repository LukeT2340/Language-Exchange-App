//
//  MotherLanguageSelectableRow.swift
//  SpeakSwap
//
//  Created by Luke Thompson on 20/1/2024.
//

import SwiftUI

struct NativeLanguageSelectableRow: View {
    let language: String
    let flagImageName: String
    var action: () -> Void
    var isSelected: Bool
    
    var body: some View {
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
