import Firebase
import FirebaseStorage
import FirebaseFirestore

enum ViewModelError: Error {
    case noUserId
    case imageConversionFailed
    case uploadFailed
    case urlRetrievalFailed
    case unknownError
}

class SetupViewModel: ObservableObject {
    var authManager: AuthManager
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var profileImage: UIImage?
    @Published var bio: String = ""
    @Published var learningGoals: String = ""
    @Published var hobbiesAndInterests: String = ""
    @Published var birthday: Date = Date()
    @Published var sex: String = "Male"
    @Published var languagesToLearn: [String: Int] = [:]
    @Published var nativeLanguages: [String] = []
    @Published var creatingUserProfile = false
    
    let sexOptions = [NSLocalizedString("Male", comment: "Male"), NSLocalizedString("Female", comment: "Female"), NSLocalizedString("Other", comment: "Other")]
    
    // Use language codes as identifiers
    let languageIdentifiers = ["en": "English", "zh": "Chinese", "es": "Spanish", "de": "German", "ja": "Japanese", "ru": "Russian"]
    
    var localizedLanguages: [(identifier: String, name: String, flag: String)] {
        languageIdentifiers.map { (identifier: $0.key, name: NSLocalizedString($0.value, comment: ""), flag: "\($0.value)_Flag") }
    }
    
    // Localized strings for display
    var localizedSexOptions: [String] {
        ["Male", "Female", "Other"].map { NSLocalizedString($0, comment: "Sex Option") }
    }
    
    // English versions of the sex options
    let sexOptionsInEnglish: [String] = ["Male", "Female", "Other"]
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        self.email = authManager.firebaseUser?.email ?? ""
    }
    
    func selectSex(localizedSelection: String) {
        if let index = localizedSexOptions.firstIndex(of: localizedSelection),
           index < sexOptionsInEnglish.count {
            sex = sexOptionsInEnglish[index]
        }
    }
    
    // Method to upload image to Firebase Storage
    func uploadProfileImage(completion: @escaping (Result<String, Error>) -> Void) {
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let userId = authManager.firebaseUser?.uid ?? ""
        let imageRef = storageRef.child("profileImages/\(userId).jpg")
        
        // First, upload the image data
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard let _ = metadata else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            // After successfully uploading, fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // If the URL is successfully retrieved, complete with the URL
                if let downloadURL = url {
                    completion(.success(downloadURL.absoluteString))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not retrieve download URL"])))
                }
            }
        }
    }
    
    
    // Modified createUserProfileData method
    func createUserProfileData() async -> Bool {
        DispatchQueue.main.async {
            self.creatingUserProfile = true
        }
        guard let userId = authManager.firebaseUser?.uid else {
            print("No user ID available")
            DispatchQueue.main.async {
                self.creatingUserProfile = false
            }
            return false // Registration failed
        }

        do {
            let imageUrl = try await uploadProfileImage()
            let compressedImageUrl = try await uploadCompressedProfileImage()

            let db = Firestore.firestore()
            let userDocument = db.collection("users").document(userId)

            // Prepare the user data for Firestore
            let userData: [String: Any] = [
                "id": userId,
                "name": self.username,
                "name_lower": self.username.lowercased(),
                "birthday": Timestamp(date: self.birthday),
                "sex": self.sex,
                "email": self.email,
                "bio": self.bio,
                "learningGoals": self.learningGoals,
                "hobbiesAndInterests": self.hobbiesAndInterests,
                "nativeLanguages": self.nativeLanguages,
                "targetLanguages": self.languagesToLearn,
                "hiddenConversationIds": [],
                "profileImageUrl": imageUrl.absoluteString,
                "compressedProfileImageUrl": compressedImageUrl.absoluteString,
                "lastOnline": Timestamp(date: Date()),
                "followerCount": 0,
                "fcmToken": "",
                "notifications": 0,
                "searchingForPartner": false,
                "isTyping": false
            ]

            // Use the prepared dictionary to set data in Firestore
            try await userDocument.setData(userData)
            print("User profile created in Firestore successfully with UID: \(userId).")
            DispatchQueue.main.async {
                self.creatingUserProfile = false
            }
            return true // Registration successful

        } catch {
            print("Error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.creatingUserProfile = false
            }
            return false // Registration failed
        }
    }

    func uploadCompressedProfileImage() async throws -> URL {
        guard let image = profileImage else {
            throw ViewModelError.imageConversionFailed
        }

        // Compress the image
        let compressedImageData = image.jpegData(compressionQuality: 0) // Adjust the compression quality as needed
        guard let imageData = compressedImageData else {
            throw ViewModelError.imageConversionFailed
        }

        let storageRef = Storage.storage().reference()
        let userId = authManager.firebaseUser?.uid ?? ""
        let compressedImageRef = storageRef.child("compressedProfileImages/\(userId).jpg")

        // Upload the compressed image data
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            compressedImageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: ViewModelError.uploadFailed)
                }
            }
        }

        // Retrieve the download URL
        let downloadURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            compressedImageRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: ViewModelError.urlRetrievalFailed)
                }
            }
        }

        return downloadURL
    }

    
    func uploadProfileImage() async throws -> URL {
        guard let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }
        
        let storageRef = Storage.storage().reference()
        let userId = authManager.firebaseUser?.uid ?? ""
        let imageRef = storageRef.child("profileImages/\(userId).jpg")
        
        // Wrap the Firebase putData call
        let metadata = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload image"]))
                }
            }
        }
        
        // Wrap the Firebase downloadURL call
        let downloadURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            imageRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not retrieve download URL"]))
                }
            }
        }
        
        return downloadURL
    }

}
