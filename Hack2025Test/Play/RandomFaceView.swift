//
//  RandomFaceView.swift
//  Hack2025Test
//
//  Created by Sora Tanaka on 2025/07/02.
//

//import SwiftUI
//
//struct RandomFaceView: View {
//    let isFrozen: Bool
//    // ランダムに表示したい文字列の配列
//    private let texts = [
//        "😅",
//        "😄",
//        "😘",
//        "😜",
//        "😫"
//    ]
//    
//    // 現在表示中の文字列
//    @State private var currentText: String = ""
//    // タイマー：1秒ごとに発火
//    private let timer = Timer.publish(every: 0.3, on: .main, in: .common)
//                             .autoconnect()
//    
//    var body: some View {
//        GeometryReader { geo in
//            Text(currentText)
//                // フォントサイズは画面サイズに応じて調整
//                .font(.system(size: max(geo.size.width, geo.size.height) * 0.8))
//                .frame(width: geo.size.width, height: geo.size.height)
//                .multilineTextAlignment(.center)
//                .onAppear {
//                    currentText = texts.randomElement() ?? ""
//                }
//                .onReceive(timer) { _ in
////                    currentText = texts.randomElement() ?? ""
//                    if !isFrozen {
//                        currentText = texts.randomElement()!
//                    }
//                }
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//struct RandomFaceView_Previews: PreviewProvider {
//    static var previews: some View {
//        RandomFaceView(isFrozen: false)
//    }
//}

// RandomFaceView.swift
// Hack2025Test

import SwiftUI

/// ランダムに顔文字を表示し、必要に応じて固定できるビュー
struct RandomFaceView: View {
    /// 固定フラグが true の間は顔文字を切り替えない
    let isFrozen: Bool
    /// ランダムに表示したい顔文字の配列
    private let texts: [String] = [
        "😅",
        "😄",
        "😘",
        "😜",
        "😫"
    ]

    /// 現在表示中の顔文字
    @State private var currentText: String = ""
    /// タイマー：0.3秒ごとに発火
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common)
                             .autoconnect()

    var body: some View {
        GeometryReader { geo in
            Text(currentText)
                // フォントサイズはビューの短辺の 80%
                .font(.system(size: min(geo.size.width, geo.size.height) * 0.8))
                .frame(width: geo.size.width, height: geo.size.height)
                .multilineTextAlignment(.center)
                .onAppear {
                    // 初期表示
                    currentText = texts.randomElement() ?? ""
                }
                .onReceive(timer) { _ in
                    // isFrozen が false のときだけ切替
                    if !isFrozen {
                        currentText = texts.randomElement() ?? ""
                    }
                }
        }
        .ignoresSafeArea() // セーフエリアまでカバー
    }
}

struct RandomFaceView_Previews: PreviewProvider {
    static var previews: some View {
        RandomFaceView(isFrozen: false)
    }
}

