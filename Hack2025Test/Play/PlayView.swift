//import SwiftUI
//import AVFoundation
//import Combine
//
////struct PlayView: View {
////    @StateObject private var client = WebSocketClient()
////    @State private var isFrozen = false
////    @State private var cancellables = Set<AnyCancellable>()
////
////    var body: some View {
////        GeometryReader { geo in
////            VStack(spacing: 0) {
////                // ── 上半分：カメラ ──
////                CameraView()
////                    .frame(width: geo.size.width,
////                           height: geo.size.height * 0.5)
////                // ── 下半分：ランダムテキスト ──
////                RandomFaceView(isFrozen: isFrozen)
////                    .frame(width: geo.size.width,
////                           height: geo.size.height * 0.5)
////                    .background(Color.gray.opacity(0.2))
////            }
//////            .edgesIgnoringSafeArea(.all)
////            .ignoresSafeArea(edges: .bottom)   
////            .navigationTitle("接続数: \(client.clientCount)")
////            .navigationBarTitleDisplayMode(.inline)
////            .onAppear {
////                client.connect()
////                
////                // サーバーからキャプチャ通知が来たら…
////                client.captureTrigger
////                    .sink { _ in
////                        // ① 絵文字を凍結
////                        isFrozen = true
////                        // ② 3秒後に撮影 & 凍結解除
////                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
////                            client.takePhoto()
////                            isFrozen = false
////                        }
////                    }
////                    .store(in: &cancellables)
////
////            }
////        }
////    }
////}
////
////
//////#Preview {
//////    PlayView()
//////}
////struct PlayView_Previews: PreviewProvider {
////    static var previews: some View {
////        NavigationStack {
////            PlayView()
////        }
////    }
////}
//
//// PlayView.swift
//// Hack2025Test
//
//import SwiftUI
//import Combine
//
//struct PlayView: View {
//    @StateObject private var client = WebSocketClient()
//    @State private var isFrozen = false
//    @State private var showCaptureAlert = false
//    @State private var cancellables = Set<AnyCancellable>()
//
//    var body: some View {
//        GeometryReader { geo in
//            let side = geo.size.width
//            VStack(spacing: 0) {
//                // ── 上半分：カメラプレビュー ──
////                CameraView()
////                    .frame(width: geo.size.width,
////                           height: geo.size.height * 0.5)
////                    .clipped()
//                HStack {
//                    Spacer()  // 左余白
//                    CameraView()
//                        .aspectRatio(1, contentMode: .fill)    // 1:1 の正方形
//                        .frame(width: side, height: side)
//                        .clipped()
//                    Spacer()  // 右余白
//                }
//                .frame(height: side)
//
//                // ── 下半分：ランダム顔文字表示 ──
////                RandomFaceView(isFrozen: isFrozen)
////                    .frame(width: geo.size.width,
////                           height: geo.size.height * 0.5)
////                    .background(Color.gray.opacity(0.2))
//                ZStack {
//                    RandomFaceView(isFrozen: isFrozen)
//                        .frame(width: geo.size.width,
//                               height: geo.size.height * 0.5)
//                        .background(Color.gray.opacity(0.2))
//                    // 撮影ボタン
//                    Button(action: {
//                        isFrozen = true
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                            client.takePhoto()
//                            isFrozen = false
//                        }
//                    }) {
//                        Text("撮影")
//                            .font(.headline)
//                            .padding(.horizontal, 24)
//                            .padding(.vertical, 12)
//                            .background(Color.blue.cornerRadius(8))
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .ignoresSafeArea(edges: .bottom)
//            .navigationTitle("接続数: \(client.clientCount)")
//            .navigationBarTitleDisplayMode(.inline)
//            .onAppear {
//                // WebSocket 接続開始
//                client.connect()
//
//                // サーバーからキャプチャ命令を受け取ったら
//                client.captureTrigger
//                    .sink { isPrimary in
//                        isFrozen = true
//                        if isPrimary {
//                            // primary の場合のみ1秒後に撮影し、絵文字固定解除
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                                client.takePhoto()
//                                isFrozen = false
//                            }
//                        }
//                    }
//                    .store(in: &cancellables)
//            }
//        }
//    }
//}
//
//struct PlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            PlayView()
//        }
//    }
//}
//
