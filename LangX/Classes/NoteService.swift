//
//  NoteService.swift
//  Tandy
//
//  Created by Luke Thompson on 11/12/2023.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseStorage

class NoteService: ObservableObject {
    @Published var usernames: [String: String] = [:]// stores username for each authorId
    @Published var profilePictures: [String: URL] = [:] // stores profile picture url for each authorId
    @Published var hasLikedNote: [String: Bool] = [:]
    @Published var notes: [Note] = []
    @Published var isLikingNote = false
    @Published var isLoadingNotes = false
    private var db = Firestore.firestore()
    private var languages: [String]
    private var clientUserId: String
    private var lastFetchedDocument: DocumentSnapshot?

    init(targetLanguages: [String], clientUserId: String) {
        self.languages = targetLanguages
        self.clientUserId = clientUserId
    }
    
    func loadMoreNotes() {
        print("load more notes called")
        guard !isLoadingNotes else { return }

        isLoadingNotes = true
        var query: Query = db.collection("notes")
                             .order(by: "timestamp", descending: true)
                             .limit(to: 8)

        if let lastDocument = lastFetchedDocument {
            query = query.start(afterDocument: lastDocument)
        }

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            self.isLoadingNotes = false

            if let error = error {
                print("Error loading more notes: \(error.localizedDescription)")
            } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                self.lastFetchedDocument = documents.last
                
                let newNotes = documents.compactMap { document -> Note? in
                    try? document.data(as: Note.self)
                }.filter { newNote in
                    !self.notes.contains(where: { $0.id == newNote.id })
                }
                
                self.notes.append(contentsOf: newNotes)
                self.fetchUserDetails(for: newNotes)
            }
        }
    }

    
    func refreshNotes() async {
        guard !isLoadingNotes else { return }

        print("refresh called")
        isLoadingNotes = true
        var allFetchedNotes = Set<Note>() // Using a set to avoid duplicates
        let dispatchGroup = DispatchGroup()

        for language in languages {
            dispatchGroup.enter()
            db.collection("notes")
                .order(by: "timestamp", descending: true)
                .limit(to: 8)
                .getDocuments { (querySnapshot, error) in
                    defer { dispatchGroup.leave() }
                    
                    if let error = error {
                        print("Error getting notes: \(error.localizedDescription)")
                        self.isLoadingNotes = false
                    } else {
                        let fetchedNotes = querySnapshot?.documents.compactMap { document in
                            try? document.data(as: Note.self)
                        } ?? []
                        
                        allFetchedNotes.formUnion(fetchedNotes)
                        self.isLoadingNotes = false
                    }
                }
        }

        dispatchGroup.notify(queue: .main) {
            print("notes updated")
            self.notes = Array(allFetchedNotes)
            self.fetchUserDetails(for: self.notes)
            self.fetchLikesStatus(for: self.clientUserId)
        }
    }


    private func fetchUserDetails(for notes: [Note]) {
        let userIDs = Set(notes.map { $0.authorId })

        for userID in userIDs {
            fetchUsername(for: userID)
            fetchProfilePicture(for: userID)
        }
    }

    private func fetchLikesStatus(for userId: String) {
        let noteLikesRef = db.collection("noteLikes").whereField("likerId", isEqualTo: userId)

        noteLikesRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let err = err {
                print("Error getting likes: \(err)")
            } else {
                // Reset the hasLikedNote dictionary
                self.hasLikedNote = [:]

                // Iterate through each document in the snapshot
                for document in querySnapshot!.documents {
                    let data = document.data()
                    if let noteId = data["noteId"] as? String {
                        // Set the like status for each note
                        self.hasLikedNote[noteId] = true
                    }
                }

                // Update the UI by calling a method to refresh the view, if necessary
            }
        }
    }

    
    private func fetchUsername(for userID: String) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let userName = document.data()?["name"] as? String ?? "Unknown"
                DispatchQueue.main.async {
                    self.usernames[userID] = userName
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    private func fetchProfilePicture(for userID: String) {
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let profilePictureURLString = document.data()?["profileImageUrl"] as? String ?? ""
                if let url = URL(string: profilePictureURLString) {
                    DispatchQueue.main.async {
                        self.profilePictures[userID] = url
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func writeNote(authorId: String, nativeLanguages: [String], title: String, textContent: String, isPublic: Bool, localMediaURLs: [URL], completion: @escaping (Note?) -> Void) {
        let tags = extractTags(from: textContent)


        // Then, upload the media URLs
        self.uploadMedia(from: localMediaURLs) { uploadedMediaURLs in
            let newNote = Note(
                id: nil,
                authorId: authorId,
                authorNativeLanguages: nativeLanguages,
                title: title,
                textContent: textContent,
                tags: tags,
                location: nil,
                likeCount: 0,
                commentCount: 0,
                reportCount: 0,
                mentionedUserIDs: [],
                timestamp: Date(),
                isPublic: isPublic,
                mediaURLs: uploadedMediaURLs
            )
            self.uploadNote(newNote)
            completion(newNote)
        }
        
    }
    
    private func uploadMedia(from localMediaURLs: [URL], completion: @escaping ([URL]) -> Void) {
        var uploadedURLs: [URL] = []
        let uploadGroup = DispatchGroup()

        for localURL in localMediaURLs {
            uploadGroup.enter()

            // First, compress the image
            compressImage(from: localURL) { [weak self] compressedUrl in
                guard let compressedUrl = compressedUrl, let self = self else {
                    uploadGroup.leave()
                    return
                }
                
                // Then, upload the compressed image
                self.uploadFileToServer(fileURL: compressedUrl) { uploadedURL in
                    if let url = uploadedURL {
                        uploadedURLs.append(url)
                    }
                    uploadGroup.leave()
                }
            }
        }

        uploadGroup.notify(queue: .main) {
            completion(uploadedURLs)
        }
    }

    private func compressImage(from originalUrl: URL, completion: @escaping (URL?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let originalImageData = try? Data(contentsOf: originalUrl),
                  let image = UIImage(data: originalImageData) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Adjust the compression quality as needed (0.0 being the most compression and 1.0 being the least)
            let compressionQuality: CGFloat = 0
            guard let compressedImageData = image.jpegData(compressionQuality: compressionQuality) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let compressedImageFilename = UUID().uuidString + ".jpg"
            let compressedImageUrl = self.getDocumentsDirectory().appendingPathComponent(compressedImageFilename)
            
            do {
                try compressedImageData.write(to: compressedImageUrl)
                DispatchQueue.main.async {
                    completion(compressedImageUrl)
                }
            } catch {
                print("Error saving compressed image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func extractTags(from text: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: "#[\\w_]+")
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, range: range)

        return matches.map {
            String(text[Range($0.range, in: text)!])
        }
    }
    
    private func uploadFileToServer(fileURL: URL, completion: @escaping (URL?) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let uniqueFileName = "\(timestamp)_\(fileURL.lastPathComponent)"
        let fileRef = Storage.storage().reference().child("NoteMedia/\(uniqueFileName)")


        fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Upload error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            fileRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL error: \(error.localizedDescription)")
                    completion(nil)
                } else if let url = url {
                    completion(url)
                }
            }
        }
    }
    
    func uploadNote(_ note: Note) {
        do {
            var newNote = note
            if newNote.id == nil {
                // If the note doesn't have an ID, create a new document and assign the ID.
                let documentRef = db.collection("notes").document()
                newNote.id = documentRef.documentID
            }
            
            try db.collection("notes").document(newNote.id!).setData(from: newNote) { error in
                if let error = error {
                    print("Error writing note: \(error.localizedDescription)")
                } else {
                    print("Note successfully written to the database")
                }
            }
        } catch let error {
            print("Error encoding note: \(error.localizedDescription)")
        }
    }
    
    func likeNote(noteId: String) {
        guard !isLikingNote else { return }
        isLikingNote = true
        self.hasLikedNote[noteId] = true
        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                self.notes[index].likeCount += 1
            }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("noteLikes")
                             .whereField("noteId", isEqualTo: noteId)
                             .whereField("likerId", isEqualTo: clientUserId)

        noteLikeRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, documents.isEmpty {
                // No existing like found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Create a new like
                    let newLikeRef = db.collection("noteLikes").document()
                    transaction.setData(["noteId": noteId, "likerId": self.clientUserId], forDocument: newLikeRef)

                    // Increment the likes count on the note
                    let noteRef = db.collection("notes").document(noteId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingNote = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedNote[noteId] = false
                        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                                self.notes[index].likeCount -= 1
                            }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingNote = false
                print("User has already liked this note or an error occurred.")
            }
        }
    }

    func unlikeNote(noteId: String) {
        guard !isLikingNote else { return }
        isLikingNote = true
        self.hasLikedNote[noteId] = false
        // Decrement the local like count
        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
            self.notes[index].likeCount -= 1
        }

        let db = Firestore.firestore()
        let noteLikeRef = db.collection("noteLikes")
                             .whereField("noteId", isEqualTo: noteId)
                             .whereField("likerId", isEqualTo: clientUserId)

        noteLikeRef.getDocuments { [weak self] (querySnapshot, err) in
            guard let self = self else { return }
            if let documents = querySnapshot?.documents, !documents.isEmpty {
                // Existing like found, proceed with transaction
                db.runTransaction({ (transaction, errorPointer) -> Any? in
                    // Remove the like
                    let likeRef = documents.first!.reference
                    transaction.deleteDocument(likeRef)

                    // Decrement the likes count on the note
                    let noteRef = db.collection("notes").document(noteId)
                    transaction.updateData(["likeCount": FieldValue.increment(Int64(-1))], forDocument: noteRef)

                    return nil
                }) { _, error in
                    self.isLikingNote = false
                    if let error = error {
                        print("Transaction failed: \(error)")
                        self.hasLikedNote[noteId] = true
                        // Decrement the local like count
                        if let index = self.notes.firstIndex(where: { $0.id == noteId }) {
                            self.notes[index].likeCount += 1
                        }
                    } else {
                        print("Transaction successfully committed!")
                    }
                }
            } else {
                self.isLikingNote = false
                print("User has not liked this note or an error occurred.")
            }
        }
    }

}
