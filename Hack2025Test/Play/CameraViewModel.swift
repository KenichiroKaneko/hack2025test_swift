import Foundation
import AVFoundation

@MainActor
final class CameraViewModel: ObservableObject {
    private let cameraService = CameraService()

    var session: AVCaptureSession {
        cameraService.session
    }

    init() {
        cameraService.configureSession()
    }

    func startSession() {
        cameraService.startSession()
    }

    func stopSession() {
        cameraService.stopSession()
    }
}
