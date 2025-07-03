import SwiftUI
class WebSocketReceiver: ObservableObject {
    @Published var count: Int = 0
    @Published var message: String = ""
    @Published var images: [UIImage] = []
    @Published var isConnected: Bool = false  // ← 追加

    var task: URLSessionWebSocketTask?

    init() {
        connect()
    }

    func connect() {
        let url = URL(string: "ws://172.20.10.3:8080")!
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if self?.task?.state == .running {
                self?.isConnected = true
                self?.sendMessage(type: "role", body: "Controller") // ← 成功後に送信
            }
        }

        listen()
    }

    func listen() {
        task?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(.string(let str)):
                self.handleJSONString(str)

            case .success(.data(let data)):
                if let jsonString = String(data: data, encoding: .utf8) {
                    self.handleJSONString(jsonString)
                } else {
                    print("⚠️ .dataメッセージのデコードに失敗（utf8変換）")
                }

            case .failure(let error):
                print("❌ 受信エラー: \(error)")

            default:
                break
            }

            self.listen()
        }
    }

    
    private func handleJSONString(_ str: String) {
        guard let data = str.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let type = json["type"] as? String else {
            print("⚠️ JSON解析に失敗")
            return
        }

        switch type {
        case "message":
            if let message = json["body"] as? String {
                print("📩 メッセージ受信: \(message)")
                DispatchQueue.main.async {
                    self.message = message
                }
            }

        case "role":
            if let role = json["body"] as? String {
                print("🎭 ロール受信: \(role)")
            }

        case "count":
            if let count = json["body"] as? Int {
                print("👥 接続台数: \(count)")
                DispatchQueue.main.async {
                    self.count = count
                }
            }

        case "image":
            if let body = json["body"] as? [String: Any],
               let base64Image = body["picture"] as? String,
               let imageData = Data(base64Encoded: base64Image),
               let uiImage = UIImage(data: imageData) {
                print("🖼️ 画像受信成功（\(imageData.count) bytes）")
                DispatchQueue.main.async {
                    self.images.append(uiImage)
                }
            } else {
                print("⚠️ imageタイプのbodyが不正または画像デコード失敗")
            }

        default:
            print("⚠️ 未知のtype: \(type)")
        }
    }



    func sendMessage(type: String, body: String) {
        let payload: [String: Any] = [
            "type": type,
            "body": body
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let jsonString = String(data: data, encoding: .utf8) {
            task?.send(.string(jsonString)) { error in
                if let error = error {
                    print("送信エラー: \(error)")
                } else {
                    print("メッセージ送信成功: \(jsonString)")
                }
            }
        }
    }
}


struct ControllerView: View {
    @StateObject var receiver = WebSocketReceiver()
    @State private var showImageView = false
    @State private var showCloseConfirmation = false

    var body: some View {
        ZStack {
            if receiver.isConnected {
                VStack(spacing: 20) {
                    Text("アクティブなカメラ台数：\(receiver.count)")

                    Button {
                        receiver.sendMessage(type: "message", body: "setup")
                    } label: {
                        Text("疎通確認ぼたん")
                    }

                    Button {
                        showImageView = true
                        receiver.sendMessage(type: "message", body: "setup")
                    } label: {
                        Text("撮影スタート")
                    }

                    Text("サーバーからのメッセージ: \(receiver.message)")
                        .padding()
                }
                .padding()
                .fullScreenCover(isPresented: $showImageView) {
                    ImageShowView(showImageView: $showImageView, receiver: receiver)
                }
            } else {
                ProgressView("サーバーに接続中…")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
    }
}






#Preview {
    ControllerView()
}
