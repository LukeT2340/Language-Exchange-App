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
                .font(.title)
                .fontWeight(.light)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Spacer()
            
            Image(flagImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .scaleEffect(isSelected ? 1.2 : 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 1), value: isSelected)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut) {
                action()
            }
        }
        .scaleEffect(isSelected ? 1.03 : 1.0)
        .animation(.easeInOut, value: isSelected)
    }
}
