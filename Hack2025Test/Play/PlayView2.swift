import SwiftUI
import AVFoundation
import Combine

struct PlayView2: View {
//    @StateObject private var client = WebSocketClient()
//    @StateObject private var vm = CameraViewModel2()
    @StateObject private var vmclient = WebSocketCameraClient()
    
    @State private var isFrozen = false
    @State private var frozenEmoji = "" // 撮影時の絵文字を保存
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CameraPreviewView2(session: vmclient.cameraSession)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                
                VStack {
                    Spacer()
                    Button(action: {
                        vmclient.capturePhoto()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    }
                    .padding(.bottom, 10)
                }
            }
            
//            if let image = vm.capturedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxHeight: UIScreen.main.bounds.height / 2)
//                    .background(Color.black.opacity(0.1))
//            } else {
//                Text("撮影した画像がここに表示されます")
//                    .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
//                    .background(Color.gray.opacity(0.2))
//            }
                
            RandomFaceView(isFrozen: isFrozen)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
                .background(Color.gray.opacity(0.2))
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
//            setupWebSocketHandlers()
            // WebSocket 接続開始
            vmclient.connect()

            // サーバーからキャプチャ命令を受け取ったら
//            client.captureTrigger
//                .sink { isPrimary in
//                    isFrozen = true
//                    if isPrimary {
//                        // primary の場合のみ1秒後に撮影し、絵文字固定解除
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            client.takePhoto()
//                            isFrozen = false
//                        }
//                    }
//                }
//                .store(in: &cancellables)
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

