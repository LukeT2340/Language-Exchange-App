//
//  ChangeBirthdayView.swift
//  LangX
//
//  Created by Luke Thompson on 30/4/2024.
//

import SwiftUI

struct ChangeBirthdayView: View {
    @Binding var birthday: Date
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            Text(LocalizedStringKey("Ask-Birthday-Text"))
                .font(.system(size: 26))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
            
            DatePicker("", selection: $birthday, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .background(.ultraThinMaterial)
                .cornerRadius(12)
            Spacer()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Text(LocalizedStringKey("Complete"))
                    Image(systemName: "checkmark")
                }
                .padding(.horizontal, 50)
                .buttonStyle()
            }
        }
        .padding(50)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color("Background2").opacity(0.5), Color("Background1").opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.7)
            .edgesIgnoringSafeArea(.all)
        )
        .navigationBarHidden(true)
    }
}

struct ChangeBirthdayView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeBirthdayView(birthday: .constant(Date()))
    }
}
