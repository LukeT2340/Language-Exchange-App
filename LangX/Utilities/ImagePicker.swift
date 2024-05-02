//
//  File.swift
//  Tandy
//
//  Created by Luke Thompson on 28/11/2023.
//

import Combine
import SwiftUI
import TLPhotoPicker
import Photos

struct CustomTLPhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedAssets: [TLPHAsset] // TLPHAsset represents selected items
    
    func makeUIViewController(context: Context) -> TLPhotosPickerViewController {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = context.coordinator
        
        // Configure the picker settings
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = true
        configure.allowedLivePhotos = true
        configure.allowedVideoRecording = false
        configure.maxSelectedAssets = 10 // Adjust as needed
        
        viewController.configure = configure
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: TLPhotosPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, TLPhotosPickerViewControllerDelegate {
        var parent: CustomTLPhotoPicker
        
        init(_ parent: CustomTLPhotoPicker) {
            self.parent = parent
        }
        
        func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
            // Update your selected assets here
            parent.selectedAssets = withTLPHAssets
            parent.isPresented = false
            return true
        }
        
        // Implement other delegate methods as needed
    }
}






// Used to allow the user to select an image from their device.
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}
