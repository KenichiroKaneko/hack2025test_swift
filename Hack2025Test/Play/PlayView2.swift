import SwiftUI
import AVFoundation
import Combine

struct PlayView2: View {
    @StateObject private var client = WebSocketCameraClient()
    
    @State private var currentEmoji = "😀"
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            CameraPreviewView2(session: client.cameraSession)
                .frame(height: UIScreen.main.bounds.height / 2)
                .clipped()
            RandomFaceView(cameraStatus: client.cameraStatus, currentEmoji: $client.currentEmoji)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                .background(backgroundColor(for: client.cameraStatus))
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // WebSocket 接続開始
            client.connect()

            // サーバーからキャプチャ命令を受け取ったら
            client.captureTrigger
                .sink { isCapture, emoji in
                    if isCapture {
                        print("capture emoji: " + emoji)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                            client.capturePhoto()
                        }
                    } else {
                        print("stop emoji: " + self.currentEmoji)
                    }
                }
                .store(in: &cancellables)
        }
        .onDisappear {
            // ナビゲーションの「戻る」ボタンで画面を離れるときに呼ばれる
            client.disconnect()
            print("🔌 Disconnected WebSocket on back navigation")
        }
    }
    /// cameraStatusに応じたColorを返す
    private func backgroundColor(for status: String) -> Color {
        switch status {
        case "start":
            return Color(red: 0.8, green: 1.0, blue: 0.8)  // 淡い緑
        case "capture":
            return Color(red: 1.0, green: 0.8, blue: 0.8)  // 淡い赤
        case "stop":
            return Color(red: 0.9, green: 0.9, blue: 0.9)  // 淡いグレー
        default:
            return Color.white
        }
    }
}

struct PlayView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlayView2()
        }
    }
}
