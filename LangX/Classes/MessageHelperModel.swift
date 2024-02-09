//
//  MessageHelperModel.swift
//  Tandy
//
//  Created by Luke Thompson on 2/12/2023.
//

import FirebaseFirestore
import AudioToolbox
import FirebaseStorage

class MessageHelperModel: ObservableObject {
    private var db = Firestore.firestore()

    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full

        let dateFormatter = DateFormatter()

        if calendar.isDateInToday(date) {
            let minutesAgo = calendar.dateComponents([.minute], from: date, to: now).minute ?? 0
            let hoursAgo = calendar.dateComponents([.hour], from: date, to: now).hour ?? 0

            if minutesAgo < 1 {
                return NSLocalizedString("Just now", comment: "Just now")
            } else if minutesAgo < 60 {
                return "\(minutesAgo)" + NSLocalizedString("Minutes ago", comment: "Minutes ago")
            } else if hoursAgo < 12 {
                return "\(hoursAgo)" + NSLocalizedString("Hours ago", comment: "Hours ago")
            } else {
                dateFormatter.dateFormat = NSLocalizedString("h:mm a", comment: "Time format: 3:45 PM")
                return dateFormatter.string(from: date)
            }
        } else {
            if calendar.isDateInYesterday(date) {
                dateFormatter.dateFormat = NSLocalizedString("'Yesterday at' h:mm a", comment: "Time format: Yesterday at 3:45 PM")
            } else {
                dateFormatter.dateFormat = NSLocalizedString("MMM d, yyyy 'at' h:mm a", comment: "Date format: Jan 5, 2021 at 3:45 PM")
            }
            return dateFormatter.string(from: date)
        }
    }

    // Functions to handle actions
    func translateMessage(text: String, completion: @escaping (String?) -> Void) {
        let apiKey = ProcessInfo.processInfo.environment["Google-API-KEY"] ?? "No API Key"
        let url = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
        
        // Get the system language
        let systemLanguageCode = Locale.current.languageCode ?? "en" // Default to English if unable to determine
        
        let json: [String: Any] = [
            "q": text,
            "target": systemLanguageCode
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let responseData = json["data"] as? [String: Any],
               let translations = responseData["translations"] as? [[String: Any]],
               let firstTranslation = translations.first,
               let translatedText = firstTranslation["translatedText"] as? String {
                DispatchQueue.main.async {
                    completion(translatedText)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    func shouldShowTimestamp(currentMessage: Message, previousMessage: Message?) -> Bool {
        guard let previousTimestamp = previousMessage?.timestamp else {
            return true // Always show for the first message
        }
        // Example logic: show timestamp if messages are more than 15 minutes apart
        let timeDifference = currentMessage.timestamp.timeIntervalSince(previousTimestamp)
        return timeDifference > 5 * 60
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
