import SwiftUI
import AVFoundation
import Combine

struct PlayView2: View {
    @StateObject private var client = WebSocketCameraClient()
    
    @State private var currentEmoji = "😀"
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CameraPreviewView2(session: client.cameraSession)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                
                VStack {
                    Spacer()
                    Button(action: {
                        client.cameraStatus = "capture"
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    }
                    .padding(.bottom, 10)
                    Button(action: {
                        client.cameraStatus = "start"
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    }
                    .padding(.bottom, 10)
//                    Button(action: {
//                        client.capturePhoto()
//                    }) {
//                        Circle()
//                            .fill(Color.white)
//                            .frame(width: 70, height: 70)
//                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
//                    }
//                    .padding(.bottom, 10)
                }
            }
            RandomFaceView(cameraStatus: client.cameraStatus, currentEmoji: $currentEmoji)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                .background(Color.gray.opacity(0.2))
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // WebSocket 接続開始
            client.connect()

            // サーバーからキャプチャ命令を受け取ったら
            client.captureTrigger
                .sink { _ in
                    client.emojiAtCapture = self.currentEmoji
                    print("capture emoji: " + self.currentEmoji)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        client.capturePhoto()
                    }
                }
                .store(in: &cancellables)
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

