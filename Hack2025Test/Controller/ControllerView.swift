import SwiftUI

class WebSocketReceiver: ObservableObject {
    @Published var count: Int = 0
    var task: URLSessionWebSocketTask?

    init() {
        connect()
    }

    func connect() {
        let url = URL(string: "ws://localhost:8080")! // サーバーのIPアドレスに変更
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        listen()
    }

    func listen() {
        task?.receive { [weak self] result in
            switch result {
            case .success(.string(let str)):
                if let data = str.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let count = json["count"] as? Int {
                    DispatchQueue.main.async {
                        self?.count = count
                    }
                }
            case .failure(let error):
                print("エラー: \(error)")
            default:
                break
            }

            // 再度受信待ちにする
            self?.listen()
        }
    }
}


struct ControllerView: View {
    @StateObject var receiver = WebSocketReceiver()

        var body: some View {
            VStack {
                Text("接続中の台数: \(receiver.count)")
                    .font(.largeTitle)
                    .padding()
            }
        }
}

#Preview {
    ControllerView()
}
