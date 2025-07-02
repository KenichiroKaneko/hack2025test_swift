import Foundation
import Combine
import SwiftUI
import AVFoundation

/// サーバーからのメッセージ構造体
struct ServerMessage: Codable {
    let type: String
    let count: Int?
    let message: String?
    let now: String?
    let shouldTakePhoto: Bool?
}

/// WebSocket クライアント
final class WebSocketClient: NSObject, ObservableObject, URLSessionWebSocketDelegate, AVCapturePhotoCaptureDelegate  {
    @Published var clientCount = 0
    @Published var welcomeText = ""
    @Published var serverTime = ""
    
    @Published var capturedImage: UIImage?

    /// サーバーからキャプチャ要求を受け取るトリガー
    let captureTrigger = PassthroughSubject<Bool, Never>()

    private var session: URLSession!
    private var webSocketTask: URLSessionWebSocketTask?
    
    
    let cameraSession = AVCaptureSession()
    
    private let output = AVCapturePhotoOutput()

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config,
                             delegate: self,
                             delegateQueue: .main)
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
    
    /// サーバーに接続
    func connect() {
        guard webSocketTask == nil else { return }
        guard let url = URL(string: "ws://172.20.10.3:8080") else { return }
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("➡️ WebSocket connection resumed")
        
        let roleDict: [String: String] = [
            "type": "role",
            "body": "Player"
        ]
        if let data = try? JSONSerialization.data(withJSONObject: roleDict, options: []),
           let json = String(data: data, encoding: .utf8) {
            webSocketTask?.send(.string(json)) { error in
                if let e = error {
                    print("❌ failed to send role:", e)
                } else {
                    print("📤 sent role message:", json)
                }
            }
        }
        
        receiveLoop()
    }

    /// メッセージ受信ループ
    private func receiveLoop() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("⚠️ receive error:", error)
            case .success(let message):
                if case let .string(text) = message,
                   let data = text.data(using: .utf8),
                   let msg = try? JSONDecoder().decode(ServerMessage.self, from: data) {
                    DispatchQueue.main.async {
                        switch msg.type {
                        case "capture":
                            // 撮影トリガー発行
//                            self?.captureTrigger.send()
                            let isPrimary = msg.shouldTakePhoto ?? false
                                                        self?.captureTrigger.send(isPrimary)
                        case "count":
                            if let c = msg.count { self?.clientCount = c }
                        case "message":
                            if let m = msg.message { self?.welcomeText = m }
//                        case "time":
//                            if let t = msg.now { self?.serverTime = t }
                        default:
                            break
                        }
                    }
                }
            }
            self?.receiveLoop()
        }
    }

    /// 写真撮影を呼び出す
    func takePhoto() {
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

    /// サーバーへのバイナリデータ送信
    private func sendPhotoData(_ data: Data) {
        webSocketTask?.send(.data(data)) { error in
            if let e = error {
                print("❌ send photo error:", e)
            } else {
                print("📤 photo data sent (\(data.count) bytes)")
            }
        }
    }

    // MARK: - URLSessionWebSocketDelegate
    func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("✅ WebSocket did open")
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        print("❌ session error:", error?.localizedDescription ?? "none")
        webSocketTask = nil
    }
}

