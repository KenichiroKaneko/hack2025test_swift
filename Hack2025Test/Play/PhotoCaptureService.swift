// PhotoCaptureService.swift
// Hack2025Test

import Foundation
import AVFoundation

/// 写真撮影サービス
final class PhotoCaptureService: NSObject, AVCapturePhotoCaptureDelegate {
    /// 撮影完了時に呼ばれるクロージャ
    var onCapture: ((Data) -> Void)?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let queue = DispatchQueue(label: "photo.capture.queue")

    override init() {
        super.init()
        session.beginConfiguration()
        session.sessionPreset = .photo

        // フロントカメラを入力に追加
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video,
                                                position: .front),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }

        // PhotoOutput を追加
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()

        // セッション開始は設定完了後に実行
        queue.async { self.session.startRunning() }
    }

    /// 写真撮影を開始
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        queue.async { [weak self] in
            guard let self = self else { return }
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    // MARK: AVCapturePhotoCaptureDelegate
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        onCapture?(data)
    }
}
