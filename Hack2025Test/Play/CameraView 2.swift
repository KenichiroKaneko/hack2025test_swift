//
//  CameraView 2.swift
//  Hack2025Test
//
//  Created by 健一郎金子 on 2025/07/02.
//


import SwiftUI

public struct CameraView2: UIViewControllerRepresentable {
    @Binding private var image: UIImage?

    @Environment(\.dismiss) private var dismiss

    public init(image: Binding<UIImage?>) {
        self._image = image
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        viewController.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            viewController.sourceType = .camera
        }

        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension CameraView2 {
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView2

        init(_ parent: CameraView2) {
            self.parent = parent
        }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                self.parent.image = uiImage
            }
            self.parent.dismiss()
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.dismiss()
        }
    }
}
