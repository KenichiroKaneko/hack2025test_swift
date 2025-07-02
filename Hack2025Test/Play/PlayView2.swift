import SwiftUI
import AVFoundation
import Combine

struct PlayView2: View {
    @StateObject private var vm = CameraViewModel2()
    
    @State private var isFrozen = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CameraPreviewView2(session: vm.cameraSession)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                
                VStack {
                    Spacer()
                    Button(action: {
                        vm.capturePhoto()
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
    }
}

struct PlayView2_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PlayView2()
        }
    }
}

