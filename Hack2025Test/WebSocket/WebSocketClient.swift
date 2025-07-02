//
//  WebSocketClient.swift
//  Hack2025Test
//
//  Created by Sora Tanaka on 2025/07/02.
//

//import Foundation


//struct ServerMessage: Codable {
//    let type: String
//    let count: Int?
//    let message: String?
//    let now: String?
//}

//final class WebSocketClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {
//    @Published var clientCount = 0
//    @Published var welcomeText = ""
//    @Published var serverTime = ""
//    
//    let captureTrigger = PassthroughSubject<Void, Never>()
//
//    private let photoService = PhotoCaptureService()
//
//    private var session: URLSession!
//    private var webSocketTask: URLSessionWebSocketTask?
//
//    override init() {
//        super.init()
//        let cfg = URLSessionConfiguration.default
//        session = URLSession(configuration: cfg, delegate: self, delegateQueue: .main)
//        
//        // PhotoCaptureService の onCapture はそのまま送信ロジック
//        photoService.onCapture = { [weak self] data in
//            self?.sendPhotoData(data)
//        }
//    }
//
//    func connect() {
//        guard webSocketTask == nil else { return }
//        let url = URL(string: "ws://172.20.10.3:8080")!
//        webSocketTask = session.webSocketTask(with: url)
//        webSocketTask?.resume()
//        receiveLoop()
//    }
//
//    private func receiveLoop() {
//        webSocketTask?.receive { [weak self] result in
//            switch result {
//            case .failure(let error):
//                print("⚠️ receive error:", error)
//            case .success(let message):
//                if case let .string(text) = message,
//                   let data = text.data(using: .utf8),
//                   let msg = try? JSONDecoder().decode(ServerMessage.self, from: data) {
//                    DispatchQueue.main.async {
//                        switch msg.type {
//                        case "capture":
//                            // ここで“撮影トリガー”を通知
//                            self?.captureTrigger.send()
//                        case "count":
//                            if let c = msg.count { self?.clientCount = c }
//                        case "message":
//                            if let m = msg.message { self?.welcomeText = m }
//                        case "time":
//                            if let t = msg.now { self?.serverTime = t }
//                        default:
//                            break
//                        }
//                    }
//                }
//            }
//            self?.receiveLoop()
//        }
//    }
//    
//    /// PhotoCaptureService を呼び出す公開メソッド
//    func takePhoto() {
//        photoService.capturePhoto()
//    }
//
//    // デリゲートで接続成功／失敗をログ
//    func urlSession(_ session: URLSession,
//                    webSocketTask: URLSessionWebSocketTask,
//                    didOpenWithProtocol protocol: String?) {
//        print("✅ WebSocket did open")
//    }
//    func urlSession(_ session: URLSession,
//                    task: URLSessionTask,
//                    didCompleteWithError error: Error?) {
//        print("❌ session error:", error?.localizedDescription ?? "none")
//        webSocketTask = nil
//    }
//}

//
//import Foundation
//import Combine
//import AVFoundation
//
///// サーバーからのメッセージ構造体
//typealias JSONDictionary = [String: Any]
//
//struct ServerMessage: Codable {
//    let type: String
//    let count: Int?
//    let message: String?
//    let now: String?
//}
//
///// 写真撮影サービス
//typealias PhotoCaptureCompletion = (Data) -> Void
//final class PhotoCaptureService: NSObject, AVCapturePhotoCaptureDelegate {
//    private let session = AVCaptureSession()
//    private let photoOutput = AVCapturePhotoOutput()
//    private let queue = DispatchQueue(label: "photo.capture.queue")
//    
//    /// 撮影完了時に呼ばれるクロージャ\    var onCapture: PhotoCaptureCompletion?
//    
//    override init() {
//        super.init()
//        session.beginConfiguration()
//        session.sessionPreset = .photo
//        
//        // フロントカメラを追加
//        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
//                                                for: .video,
//                                                position: .front),
//           let input = try? AVCaptureDeviceInput(device: device),
//           session.canAddInput(input) {
//            session.addInput(input)
//        }
//        // PhotoOutput を追加
//        if session.canAddOutput(photoOutput) {
//            session.addOutput(photoOutput)
//        }
//        session.commitConfiguration()
//        queue.async { self.session.startRunning() }
//    }
//    
//    /// 写真撮影を開始
//    func capturePhoto() {
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = .off
//        queue.async { [weak self] in
//            self?.photoOutput.capturePhoto(with: settings, delegate: self!)
//        }
//    }
//    
//    // MARK: AVCapturePhotoCaptureDelegate
//    func photoOutput(_ output: AVCapturePhotoOutput,
//                     didFinishProcessingPhoto photo: AVCapturePhoto,
//                     error: Error?) {
//        guard let data = photo.fileDataRepresentation() else { return }
//        onCapture?(data)
//    }
//}
//
///// WebSocket クライアント
//final class WebSocketClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {
//    @Published var clientCount = 0
//    @Published var welcomeText = ""
//    @Published var serverTime = ""
//    
//    /// サーバーからキャプチャ要求を受け取るトリガー
//    let captureTrigger = PassthroughSubject<Void, Never>()
//    
//    private var session: URLSession!
//    private var webSocketTask: URLSessionWebSocketTask?
//    private let photoService = PhotoCaptureService()
//    private var cancellables = Set<AnyCancellable>()
//    
//    override init() {
//        super.init()
//        let config = URLSessionConfiguration.default
//        session = URLSession(configuration: config,
//                             delegate: self,
//                             delegateQueue: .main)
//        
//        // 撮影完了時の送信
//        photoService.onCapture = { [weak self] (data: Data) in
//            self?.sendPhotoData(data)
//        }
//    }
//    
//    /// サーバーに接続
//    func connect() {
//        guard webSocketTask == nil else { return }
//        let url = URL(string: "ws://172.20.10.3:8080")!
//        webSocketTask = session.webSocketTask(with: url)
//        webSocketTask?.resume()
//        receiveLoop()
//    }
//    
//    /// メッセージ受信ループ
//    private func receiveLoop() {
//        webSocketTask?.receive { [weak self] result in
//            switch result {
//            case .failure(let error):
//                print("⚠️ receive error:", error)
//            case .success(let message):
//                if case let .string(text) = message,
//                   let data = text.data(using: .utf8),
//                   let msg = try? JSONDecoder().decode(ServerMessage.self, from: data) {
//                    DispatchQueue.main.async {
//                        switch msg.type {
//                        case "capture":
//                            // 撮影トリガーを通知
//                            self?.captureTrigger.send()
//                        case "count":
//                            if let c = msg.count { self?.clientCount = c }
//                        case "message":
//                            if let m = msg.message { self?.welcomeText = m }
//                        case "time":
//                            if let t = msg.now { self?.serverTime = t }
//                        default: break
//                        }
//                    }
//                }
//            }
//            self?.receiveLoop()
//        }
//    }
//    
//    /// 撮影を呼び出す
//    func takePhoto() {
//        photoService.capturePhoto()
//    }
//    
//    /// 写真データをサーバーへ送信
//    private func sendPhotoData(_ data: Data) {
//        webSocketTask?.send(.data(data)) { error in
//            if let e = error {
//                print("❌ send photo error:", e)
//            } else {
//                print("📤 photo data sent (\(data.count) bytes)")
//            }
//        }
//    }
//    
//    // MARK: URLSessionWebSocketDelegate
//    func urlSession(_ session: URLSession,
//                    webSocketTask: URLSessionWebSocketTask,
//                    didOpenWithProtocol protocol: String?) {
//        print("✅ WebSocket did open")
//    }
//    
//    func urlSession(_ session: URLSession,
//                    task: URLSessionTask,
//                    didCompleteWithError error: Error?) {
//        print("❌ session error:", error?.localizedDescription ?? "none")
//        webSocketTask = nil
//    }
//}

// WebSocketClient.swift
// Hack2025Test

import Foundation
import Combine

/// サーバーからのメッセージ構造体
struct ServerMessage: Codable {
    let type: String
    let count: Int?
    let message: String?
    let now: String?
    let shouldTakePhoto: Bool?
}

/// WebSocket クライアント
final class WebSocketClient: NSObject, ObservableObject, URLSessionWebSocketDelegate {
    @Published var clientCount = 0
    @Published var welcomeText = ""
    @Published var serverTime = ""

    /// サーバーからキャプチャ要求を受け取るトリガー
    let captureTrigger = PassthroughSubject<Bool, Never>()

    private var session: URLSession!
    private var webSocketTask: URLSessionWebSocketTask?
    private let photoService = PhotoCaptureService()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config,
                             delegate: self,
                             delegateQueue: .main)

        // PhotoCaptureService の撮影完了を受けてサーバーへ送信
        photoService.onCapture = { [weak self] (data: Data) in
            self?.sendPhotoData(data)
        }
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
        photoService.capturePhoto()
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

