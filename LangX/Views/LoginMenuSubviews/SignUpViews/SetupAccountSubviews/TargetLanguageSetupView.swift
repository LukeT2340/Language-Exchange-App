//
//  TargetLanguageSetupView.swift
//  LanguageApp
//
//  Created by Luke Thompson on 19/11/2023.
//

import SwiftUI

struct TargetLanguageSetupView: View {
    @ObservedObject var setupViewModel: SetupViewModel
    @EnvironmentObject var authManager: AuthManager
    @State private var isAnimating = false
    @State private var showAlert = false
    @State private var navigateToNextView = false

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Image("Icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .opacity(isAnimating ? 1.0 : 0.8)
                    .onAppear() {
                        withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            isAnimating.toggle()
                        }
                    }
                    .frame(width: 70)
                Spacer()
            }
            Text(NSLocalizedString("Select-Target-Languages", comment: "Select target languages"))
                .font(.largeTitle)
            Spacer()
            ScrollView {
                VStack {
                    ForEach(setupViewModel.localizedLanguages, id: \.identifier) { languageInfo in
                        TargetLanguageSelectableRow(language: languageInfo.name, flagImageName: languageInfo.flag, fluencyLevel: setupViewModel.languagesToLearn[languageInfo.identifier]) {
                            if let _ = setupViewModel.languagesToLearn[languageInfo.identifier] {
                                // Remove the language
                                setupViewModel.languagesToLearn[languageInfo.identifier] = nil
                            } else {
                                // Add with initial level
                                setupViewModel.languagesToLearn[languageInfo.identifier] = 1
                            }
                        }
                        // Conditionally display ProficiencySelectorRow
                        if setupViewModel.languagesToLearn[languageInfo.identifier] != nil {
                            let binding = Binding<Int>(
                                get: {
                                    self.setupViewModel.languagesToLearn[languageInfo.identifier] ?? 1
                                },
                                set: {
                                    self.setupViewModel.languagesToLearn[languageInfo.identifier] = $0
                                }
                            )

                            ProficiencySelectorRow(proficiency: binding, languageName: languageInfo.name)
                                .transition(.move(edge: .top).combined(with: .opacity)) // Combine move and fade transitions
                                .animation(.easeInOut, value: setupViewModel.languagesToLearn[languageInfo.identifier]) // Animate the transition

                        }
                    }
                }
            }

            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left") // System-provided name for a left-pointing arrow
                        Text(NSLocalizedString("Back-Button", comment: "Back button"))
                    }
                }
                .buttonStyle() // Apply any custom button style you have
                .frame(width: 120)
                Spacer()
                NavigationLink(destination: NativeLanguageSetupView(setupViewModel: setupViewModel), isActive: $navigateToNextView) {
                      EmptyView()
                  }
                Button(action: {
                    if setupViewModel.languagesToLearn.isEmpty {
                        showAlert = true
                    } else {
                        navigateToNextView = true  // Activate the NavigationLink
                    }
                }) {
                    HStack {
                        Text(NSLocalizedString("Next-Button", comment: "Next button"))
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle()
                .frame(width: 120)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(NSLocalizedString("Error: No Languages Selected", comment: "No Languages Selected")),
                        message: Text(NSLocalizedString("Please select at least one language to learn", comment: "Please select at least one language to learn.")),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .padding()

            }
        }
        .background(
            colorScheme == .dark ?
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.22, green: 0.22, blue: 0.24), Color(red: 0.28, green: 0.28, blue: 0.30)]), startPoint: .top, endPoint: .bottom) :
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.88, blue: 0.92)]), startPoint: .top, endPoint: .bottom)
        )
        .navigationBarHidden(true)
    }
}

struct TargetLanguageSelectableRow: View {
    let language: String
    let flagImageName: String
    var fluencyLevel: Int?
    
    var action: () -> Void

    var isSelected: Bool {
        fluencyLevel != nil
    }

    var body: some View {
        HStack {
            Text(language)
                .font(.title)
            Spacer()
            Image(flagImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .cornerRadius(2)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(isSelected ? Color(red: 0.39, green: 0.58, blue: 0.93).opacity(0.2) : Color.gray.opacity(0.2))
        .cornerRadius(8)
        .contentShape(Rectangle()) // Ensures the tap gesture covers the whole area
        .onTapGesture {
            action()
        }
    }
}

struct ProficiencySelectorRow: View {
    @Binding var proficiency: Int
    var languageName: String
    @State var totalLevels = 5

    private var proficiencyDouble: Binding<Double> {
        Binding<Double>(
            get: { Double(proficiency) },
            set: { proficiency = Int(round($0)) }
        )
    }

    var body: some View {
        VStack {
            Text(String(format: NSLocalizedString("Select-Your-Proficiency", comment: "Select your proficiency"), languageName))
            HStack {
                Text(NSLocalizedString("Beginner", comment: "Beginner"))
                    .font(.footnote)
                ForEach(1...5, id: \.self) { level in
                    BoxView(level: level, totalLevels: 5, selectedLevel: $proficiency)
                }
                Text(NSLocalizedString("Fluent", comment: "Fluent"))
                    .font(.footnote)
            }
        }
    }
}

struct BoxView: View {
    let level: Int
    let totalLevels: Int
    @Binding var selectedLevel: Int

    var body: some View {
        Text("\(level)")
            .frame(width: 50, height: 50)
            .foregroundColor(.white)
            .background(
                Circle()
                    .fill(boxColor(for: level))
            )
            .overlay(
                Circle()
                    .stroke(selectedLevel == level ? Color(red: 0.39, green: 0.58, blue: 0.93) : Color.white, lineWidth: 4) // Blue border for selected, white for others
            )
            .clipShape(Circle())
            .onTapGesture {
                selectedLevel = level
            }
    }
    
    private func boxColor(for level: Int) -> Color {
        let progress = Double(level - 1) / Double(totalLevels - 1)
        let startColor = Color(red: 173/255, green: 216/255, blue: 230/255)// Starting color
        let endColor = Color(red: 0.39, green: 0.58, blue: 0.93) // Ending color

        return Color(
            red: interpolate(from: startColor.components.red, to: endColor.components.red, progress: progress),
            green: interpolate(from: startColor.components.green, to: endColor.components.green, progress: progress),
            blue: interpolate(from: startColor.components.blue, to: endColor.components.blue, progress: progress)
        )
    }

    private func interpolate(from start: Double, to end: Double, progress: Double) -> Double {
        return start + (end - start) * progress
    }
}

extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: Double = 0, g: Double = 0, b: Double = 0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = Double((hexNumber & 0xff0000) >> 16) / 255
            g = Double((hexNumber & 0x00ff00) >> 8) / 255
            b = Double(hexNumber & 0x0000ff) / 255
        }
        
        return (red: r, green: g, blue: b)
    }
}


struct CircleBorderShape: Shape {
    let level: Int
    let totalLevels: Int

    func path(in rect: CGRect) -> Path {
        let cornerRadius = CGFloat(level - 1) * (25 / CGFloat(totalLevels - 1))
        return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}
