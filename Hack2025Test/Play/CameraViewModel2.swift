//
//  CameraViewModel.swift
//  Hack2025Test
//
//  Created by 健一郎金子 on 2025/07/02.
//

import UIKit
import AVFoundation


final class CameraViewModel2: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var capturedImage: UIImage?
    let cameraSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            cameraSession.canAddInput(input),
            cameraSession.canAddOutput(output)
        else {
            cameraSession.commitConfiguration()
            return
        }

        cameraSession.addInput(input)
        cameraSession.addOutput(output)
        cameraSession.commitConfiguration()

        cameraSession.startRunning()
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        if let data = photo.fileDataRepresentation(),
           let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.capturedImage = image
            }
        }
    }
}
