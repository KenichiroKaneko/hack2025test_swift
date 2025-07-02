//
//  CameraView.swift
//  Hack2025Test
//
//  Created by Sora Tanaka on 2025/07/02.
//

//import SwiftUI
//import AVFoundation
//
///// UIView のレイヤーを AVCaptureVideoPreviewLayer にする UIView
//final class VideoPreviewUIView: UIView {
//    override class var layerClass: AnyClass {
//        AVCaptureVideoPreviewLayer.self
//    }
//    var previewLayer: AVCaptureVideoPreviewLayer {
//        layer as! AVCaptureVideoPreviewLayer
//    }
//}

///// SwiftUI 用のカメラプレビュー
//struct CameraView: UIViewRepresentable {
//    // カメラセッションを保持
//    class Coordinator {
//        let session = AVCaptureSession()
//        let queue   = DispatchQueue(label: "camera.session.queue")
//
//        init() {
//            session.sessionPreset = .high
//            guard
//                let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                     for: .video,
//                                                     position: .front),
//                let input  = try? AVCaptureDeviceInput(device: device),
//                session.canAddInput(input)
//            else {
//                print("⚠️ フロントカメラが取得できません")
//                return
//            }
//            session.addInput(input)
//        }
//
//        func start() {
//            queue.async { self.session.startRunning() }
//        }
//        func stop() {
//            queue.async { self.session.stopRunning() }
//        }
//    }
//
//    func makeCoordinator() -> Coordinator { Coordinator() }
//
//    func makeUIView(context: Context) -> VideoPreviewUIView {
//        let view = VideoPreviewUIView()
//        view.previewLayer.videoGravity = .resizeAspectFill
//
//        // カメラ権限の確認＆リクエスト
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            context.coordinator.start()
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { granted in
//                if granted {
//                    context.coordinator.start()
//                } else {
//                    print("⚠️ カメラ権限が拒否されました")
//                }
//            }
//        default:
//            print("⚠️ カメラ権限が無効です。設定アプリで許可してください。")
//        }
//
//        // このセッションをプレビューにアタッチ
//        view.previewLayer.session = context.coordinator.session
//        return view
//    }
//
//    func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
//        // 特に何もしなくて OK
//    }
//
//    static func dismantleUIView(_ uiView: VideoPreviewUIView, coordinator: Coordinator) {
//        coordinator.stop()
//    }
//}

// CameraView.swift
// Hack2025Test

import SwiftUI
import AVFoundation

/// UIView のレイヤーを AVCaptureVideoPreviewLayer に置き換えたカスタム UIView
final class VideoPreviewUIView: UIView {
//    override class var layerClass: AnyClass {
//        AVCaptureVideoPreviewLayer.self
//    }
//    var previewLayer: AVCaptureVideoPreviewLayer {
//        layer as! AVCaptureVideoPreviewLayer
//    }
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 正方形にするため、短辺を基準に中央をクリップ
        let side = min(bounds.width, bounds.height)
        let x = (bounds.width - side) / 2
        let y = (bounds.height - side) / 2
        previewLayer.frame = CGRect(x: x, y: y, width: side, height: side)
    }
}

/// SwiftUI からインカメラプレビューを表示する UIViewRepresentable
struct CameraView: UIViewRepresentable {
    class Coordinator {
        let session = AVCaptureSession()
        private let queue = DispatchQueue(label: "camera.session.queue")

        init() {
            configureSession()
        }

        private func configureSession() {
            session.beginConfiguration()
            session.sessionPreset = .high
            // フロントカメラ入力
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .front),
               let input = try? AVCaptureDeviceInput(device: device),
               session.canAddInput(input) {
                session.addInput(input)
            }
            session.commitConfiguration()
        }

        func start() {
            queue.async { self.session.startRunning() }
        }

        func stop() {
            queue.async { self.session.stopRunning() }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> VideoPreviewUIView {
        let view = VideoPreviewUIView()
        view.backgroundColor = .black
        view.previewLayer.session = context.coordinator.session
        view.previewLayer.videoGravity = .resizeAspectFill
        context.coordinator.start()
        return view
    }

    func updateUIView(_ uiView: VideoPreviewUIView, context: Context) {
        uiView.previewLayer.frame = uiView.bounds
    }

    static func dismantleUIView(_ uiView: VideoPreviewUIView, coordinator: Coordinator) {
        coordinator.stop()
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
//            .ignoresSafeArea()
            .frame(width: 200, height: 200)
    }
}

