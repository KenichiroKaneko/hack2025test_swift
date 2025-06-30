import SwiftUI
import AVFoundation

struct PlayView: View {
    @StateObject var client = WebSocketClient()
    var body: some View {
        VStack(spacing: 0) {
            Text("接続中...")
            Button("接続開始") {
                client.connect()
            }
            //            CameraView()
            //                .frame(maxHeight: .infinity)
            //                .aspectRatio(contentMode: .fill)
            //                .clipped()
            
            Text("ここに好きなテキストを表示")
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
        }
    }
}


class WebSocketClient: ObservableObject {
    var task: URLSessionWebSocketTask?
    
    func connect() {
        let url = URL(string: "ws://localhost:8080")!
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
    }
}

#Preview {
    PlayView()
}
