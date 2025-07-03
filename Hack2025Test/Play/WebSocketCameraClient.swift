import Foundation
import Combine
import SwiftUI
import AVFoundation
import UIKit

/// サーバーからのメッセージ構造体
struct WebSocketServerMessage: Codable {
    let type: String
    let body: String?
    let count: Int?
}

/// 写真データ送信用構造体
//struct PhotoUploadMessage: Codable {
//    let type: String
//    let photo: PhotoInfo
//    let emoji: String
//    let timestamp: Double
//}

//struct PhotoInfo: Codable {
//    let data: String  // Base64エンコードされた画像データ
//    let width: Int
//    let height: Int
//    let timestamp: Double
//}

/// 統合されたWebSocketカメラクライアント
final class WebSocketCameraClient: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    @Published var clientCount = 0
    @Published var capturedImage: UIImage?
    @Published var isConnected = false
//    @Published var isFrozen = false
    @Published var cameraStatus = "start"
    @Published var currentEmoji = "😀"
    
    // MARK: - Publishers
    /// サーバーからキャプチャ要求を受け取るトリガー (isPrimary, fixedEmoji)
    let captureTrigger = PassthroughSubject<(Bool, String), Never>()
    
    /// 撮影完了通知
    let captureComplete = PassthroughSubject<Void, Never>()
    
    // MARK: - Private Properties
    private var session: URLSession!
    private var webSocketTask: URLSessionWebSocketTask?
    
    // Camera関連
    let cameraSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    
    // 撮影時の絵文字保存用
    var emojiAtCapture: String = ""
    
    // MARK: - Initialization
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config,
                             delegate: self,
                             delegateQueue: .main)
        configureCameraSession()
    }
    
    // MARK: - Camera Configuration
    private func configureCameraSession() {
        cameraSession.beginConfiguration()
        cameraSession.sessionPreset = .photo

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input = try? AVCaptureDeviceInput(device: device),
            cameraSession.canAddInput(input),
            cameraSession.canAddOutput(output)
        else {
            cameraSession.commitConfiguration()
            print("❌ Failed to configure camera")
            return
        }

        cameraSession.addInput(input)
        cameraSession.addOutput(output)
        cameraSession.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async {
            self.cameraSession.startRunning()
        }
        
        print("✅ Camera configured successfully")
    }
    
    // MARK: - WebSocket Connection
    /// サーバーに接続
    func connect() {
        guard webSocketTask == nil else { return }
        guard let url = URL(string: "ws://172.20.10.3:8080") else {
            print("❌ Invalid WebSocket URL")
            return
        }
        
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("➡️ WebSocket connection resumed")
        
        // 役割をサーバーに送信
        sendRoleMessage()
        
        receiveLoop()
    }
    
    /// 切断
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        print("🔌 WebSocket disconnected")
    }
    
    /// 役割メッセージ送信
    private func sendRoleMessage() {
        let roleDict: [String: String] = [
            "type": "role",
            "body": "Player"
        ]
        
        sendJSONMessage(roleDict)
    }
    
    /// JSONメッセージ送信
    private func sendJSONMessage<T: Encodable>(_ message: T) {
        do {
            let data = try JSONEncoder().encode(message)
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ Failed to send message: \(error)")
                } else {
                    print("📤 Message sent: \(jsonString)")
                }
            }
        } catch {
            print("❌ Failed to encode message: \(error)")
        }
    }
    
    /// 辞書形式のJSONメッセージ送信
    private func sendJSONMessage(_ dict: [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            
            webSocketTask?.send(.string(jsonString)) { error in
                if let error = error {
                    print("❌ Failed to send message: \(error)")
                } else {
                    print("📤 Message sent: \(jsonString)")
                }
            }
        } catch {
            print("❌ Failed to serialize message: \(error)")
        }
    }

    // MARK: - Message Handling
    /// メッセージ受信ループ
    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("⚠️ Receive error: \(error)")
                self?.handleConnectionError()
            case .success(let message):
                self?.handleReceivedMessage(message)
            }
            self?.receiveLoop()
        }
    }
    
    /// 受信メッセージの処理
    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            handleTextMessage(text)
        case .data(let data):
            handleBinaryMessage(data)
        @unknown default:
            print("⚠️ Unknown message type received")
        }
    }
    
    /// テキストメッセージの処理
    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8),
              let msg = try? JSONDecoder().decode(WebSocketServerMessage.self, from: data) else {
            print("⚠️ Failed to decode message: \(text)")
            return
        }
        
        DispatchQueue.main.async {
            switch msg.type {
                case "message":
                    guard let body = msg.body else { return }
                    switch body {
                        case "capture":
                            print("command capture")
                            self.handleCaptureMessage(msg)
                        case "stop":
                            print("command stop")
                            self.handleCaptureMessage(msg)
                        case "start":
                            print("command start")
                            self.handleShootComplete()
                        default:
                            print("command default")
                    }
//                case "capture", "prepare_shoot":
//                    self.handleCaptureMessage(msg)
                case "count":
                    if let count = msg.count {
                        self.clientCount = count
                    }
                default:
                    print("📨 Unhandled message type: \(msg.type)")
            }
        }
    }
    
    /// バイナリメッセージの処理
    private func handleBinaryMessage(_ data: Data) {
        print("📨 Received binary data: \(data.count) bytes")
        // 必要に応じて画像データなどの処理を実装
    }
    
    /// 撮影メッセージの処理
    private func handleCaptureMessage(_ msg: WebSocketServerMessage) {
        guard let command = msg.body else { return }

        switch command {
        case "capture":
            cameraStatus = "capture"
            print("📸 capture command, freezing emoji: \(emojiAtCapture)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.capturePhoto()
//            }
        case "stop":
            cameraStatus = "stop"
            print("⏸️ stop command, emoji frozen: \(emojiAtCapture)")
        default:
            print("💬 Received message: \(command)")
        }
    }
    
    /// 撮影完了の処理
    private func handleShootComplete() {
        cameraStatus = "start"
        emojiAtCapture = ""
//        captureComplete.send()
        print("✅ Shoot complete - unfreezing emoji")
    }
    
    /// 接続エラーの処理
    private func handleConnectionError() {
        isConnected = false
        webSocketTask = nil

        // 3秒後に再接続を試行
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            print("🔄 Attempting to reconnect...")
            self.connect()
        }
    }
    
    // MARK: - Photo Capture
    /// 写真撮影
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        output.capturePhoto(with: settings, delegate: self)
        print("📸 Capturing photo...")
    }
    
    /// 撮影した写真をサーバーに送信
    private func sendPhotoToServer(_ image: UIImage, emoji: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG data")
            return
        }
        
        let base64String = imageData.base64EncodedString()
        
//        let photoInfo = PhotoInfo(
//            data: base64String,
//            width: Int(image.size.width),
//            height: Int(image.size.height),
//            timestamp: Date().timeIntervalSince1970
//        )
        
//        let uploadMessage = PhotoUploadMessage(
//            type: "photo_upload",
//            photo: photoInfo,
//            emoji: emoji,
//            timestamp: Date().timeIntervalSince1970
//        )
//        
//        sendJSONMessage(uploadMessage)
        
        // 撮影完了をサーバーに通知
        let completionMessage: [String: Any] = [
            "type": "image",
            "body": [
                "picture": base64String,
                "emoji": emoji
            ]
        ]
        
        sendJSONMessage(completionMessage)
        
        print("📤 Photo sent to server with emoji: \(emoji)")
    }
    
    // MARK: - Cleanup
    deinit {
        disconnect()
        cameraSession.stopRunning()
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketCameraClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.isConnected = true
        }
        print("✅ WebSocket connection opened")
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
        
        if let error = error {
            print("❌ WebSocket session error: \(error.localizedDescription)")
        } else {
            print("🔌 WebSocket session completed")
        }
        
        webSocketTask = nil
        
        // エラーが発生した場合、自動再接続を試行
        if error != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.connect()
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension WebSocketCameraClient: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            print("❌ Failed to create image from photo data")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            
            // 撮影時の絵文字と一緒にサーバーに送信
            self.sendPhotoToServer(image, emoji: self.emojiAtCapture)
        }
        
        print("✅ Photo captured successfully")
    }
}
