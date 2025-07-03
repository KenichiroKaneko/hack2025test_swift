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
                .background(Color.gray.opacity(0.2))
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
}

struct PlayView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlayView2()
        }
    }
}
