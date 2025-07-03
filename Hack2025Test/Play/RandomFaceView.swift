// RandomFaceView.swift
// Hack2025Test

import SwiftUI

/// ランダムに顔文字を表示し、必要に応じて固定できるビュー
struct RandomFaceView: View {
    /// 固定フラグが true の間は顔文字を切り替えない
    let cameraStatus: String
    /// 顔文字
    @Binding var currentEmoji: String
    /// ランダムに表示したい顔文字の配列
    private let texts: [String] = [
        "😆", "😄", "😘", "😜", "😫", "🥹", "🫡", "🥰", "😡",
        "🥱", "😱", "😢", "🙄", "😑", "☺️", "🤗", "😉", "😍",
        "🥺", "🤣", "😋", "🥳"
    ]

    /// タイマー：0.3秒ごとに発火
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            Text(currentEmoji)
                .font(.system(size: min(geo.size.width, geo.size.height) * 0.8))
                .frame(width: geo.size.width, height: geo.size.height)
                .multilineTextAlignment(.center)
                .onAppear {
                    /// 初期表示
                    currentEmoji = texts.randomElement() ?? ""
                }
                .onReceive(timer) { _ in
                    /// isFrozen が false のときだけ切替
                    if cameraStatus == "start" {
                        currentEmoji = texts.randomElement() ?? ""
                        print(currentEmoji)
                    } else if cameraStatus == "stop" {
                        currentEmoji = ""
                    }
                }
        }
        .ignoresSafeArea() // セーフエリアまでカバー
    }
}

struct RandomFaceView_Previews: PreviewProvider {
    static var previews: some View {
        RandomFaceView(cameraStatus: "start", currentEmoji: .constant("😅"))
    }
}
