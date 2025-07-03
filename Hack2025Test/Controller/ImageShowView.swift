//import SwiftUI
//
//
//struct ImageShowView: View {
//    @Binding var showImageView: Bool
//    @ObservedObject var receiver: WebSocketReceiver  // 外から受け取る
//    
//    @State private var showCloseConfirmation = false
//    
//    var body: some View {
//        ZStack {
//            
//            Color.gray.ignoresSafeArea()
//            
//            VStack {
//                VStack {
//                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 0) {
//                        ForEach(receiver.images.indices, id: \.self) { index in
//                            Image(uiImage: receiver.images[index])
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .background(.white)
//                                .padding(16)
//                                .cornerRadius(8)
//                                .overlay(alignment: .bottomTrailing){
//                                    Text(receiver.emojis[index])
//                                        .font(.system(size: 80))
//                                        .padding(8)
//                                        .background(
//                                            Circle()
//                                                .fill(Color.white)
//                                        )
//                                }
//                        }
//                    }
//                    .padding(.horizontal, 64)
//                }
//                Spacer()
//                Button("閉じる") {
//                    showCloseConfirmation = true
//                }
//                .padding(.bottom)
//            }
//            
//            
//        }
//        .confirmationDialog("本当に閉じますか？", isPresented: $showCloseConfirmation) {
//            Button("閉じる", role: .destructive) {
//                receiver.images = []
//                receiver.emojis = []
//                showImageView = false
//            }
//            Button("キャンセル", role: .cancel) {}
//        }
//    }
//}
//
//
//class DummyReceiver: WebSocketReceiver {
//    override init() {
//        super.init()
//        self.images = [
//            UIImage(systemName: "person.crop.square")!,
//            UIImage(systemName: "person.crop.square")!,
//            UIImage(systemName: "person.crop.square")!,
//            UIImage(systemName: "person.crop.square")!,
//            UIImage(systemName: "star")!,
//            UIImage(systemName: "heart")!
//        ]
//        self.emojis = [
//            "😍", "😳", "😭", "😍", "😳", "😭"
//        ]
//    }
//}
//
//#Preview {
//    ImageShowView(showImageView: .constant(true), receiver: DummyReceiver())
//}









import SwiftUI
import UIKit
import Combine
import Photos

// MARK: - SwiftUI View
//struct ImageShowView: View {
//    @Binding var showImageView: Bool
//    @ObservedObject var receiver: WebSocketReceiver
//
//    @State private var showCloseConfirmation = false
//    @State private var showSaveConfirmation = false
//    @State private var saveResultMessage = ""
//    @State private var showSaveResultAlert = false
//    @State private var shareImage: UIImage? = nil
//    @State private var showShareSheet = false
//
//    var body: some View {
//        ZStack {
//            Color.gray.ignoresSafeArea()
//            VStack {
//                captureContainer
//                    .padding(.vertical)
//                Spacer()
//                HStack {
//                    Button("保存") { showSaveConfirmation = true }
//                        .padding()
//                    Button("共有") { showShareSheet = true }
//                        .padding()
//                    Spacer()
//                    Button("閉じる") { showCloseConfirmation = true }
//                        .padding()
//                }
//            }
//        }
//        .confirmationDialog("本当に閉じますか？", isPresented: $showCloseConfirmation) {
//            Button("閉じる", role: .destructive) {
//                receiver.images.removeAll()
//                receiver.emojis.removeAll()
//                showImageView = false
//            }
//            Button("キャンセル", role: .cancel) {}
//        }
//        .alert("画像を保存しますか？", isPresented: $showSaveConfirmation) {
//            Button("保存") { performSave() }
//            Button("キャンセル", role: .cancel) {}
//        }
//        .alert(saveResultMessage, isPresented: $showSaveResultAlert) {
//            Button("OK", role: .cancel) {}
//        }
//        .sheet(isPresented: $showShareSheet, onDismiss: { shareImage = nil }) {
//            if let img = captureContainer.snapshot() {
//                ActivityView(activityItems: [img])
//            }
//        }
//    }
//
//    /// キャプチャ対象のグリッド部分
//    private var captureContainer: some View {
//        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
//            ForEach(receiver.images.indices, id: \.self) { index in
//                Image(uiImage: receiver.images[index])
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Color.white)
//                    .cornerRadius(8)
//                    .overlay(alignment: .bottomTrailing) {
//                        Text(receiver.emojis[index])
//                            .font(.system(size: 80))
//                            .padding(8)
//                            .background(Circle().fill(Color.white))
//                    }
//            }
//        }
//        .padding(.horizontal, 64)
//    }
//
//    // MARK: - 保存
//    private func performSave() {
//        guard let img = captureContainer.snapshot() else {
//            saveResultMessage = "画像の取得に失敗しました"
//            showSaveResultAlert = true
//            return
//        }
//        PHPhotoLibrary.requestAuthorization { status in
//            if !(status == .authorized || status == .limited) {
//                saveResultMessage = "写真ライブラリのアクセス権がありません"
//                showSaveResultAlert = true
//                return
//            }
//            PHPhotoLibrary.shared().performChanges({
//                PHAssetChangeRequest.creationRequestForAsset(from: img)
//            }) { success, error in
//                DispatchQueue.main.async {
//                    saveResultMessage = success ? "フォトライブラリに保存しました" : "保存に失敗しました: \(error?.localizedDescription ?? "不明なエラー")"
//                    showSaveResultAlert = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - View Snapshot Extension
//extension View {
//    /// この View をホストして UIImage を生成
//    func snapshot() -> UIImage? {
//        let controller = UIHostingController(rootView: self)
//        controller.view.backgroundColor = .clear
//        guard let scene = UIApplication.shared.connectedScenes
//                .compactMap({ $0 as? UIWindowScene })
//                .first(where: { $0.activationState == .foregroundActive }),
//              let window = scene.windows.first
//        else { return nil }
//        window.addSubview(controller.view)
//        controller.view.frame = window.bounds
//        controller.view.layoutIfNeeded()
//        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds)
//        let image = renderer.image { _ in
//            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
//        controller.view.removeFromSuperview()
//        return image
//    }
//}
//
//// MARK: - Share Sheet Wrapper
//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(
//            activityItems: activityItems,
//            applicationActivities: nil
//        )
//    }
//    func updateUIViewController(
//        _ uiViewController: UIActivityViewController,
//        context: Context
//    ) {}
//}
//
//// MARK: - Preview
//struct ImageShowView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dummy = WebSocketReceiver()
//        dummy.images = (0..<4).compactMap { _ in UIImage(systemName: "photo") }
//        dummy.emojis = ["😀", "😍", "😎", "🤖"]
//        return ImageShowView(showImageView: .constant(true), receiver: dummy)
//    }
//}




// MARK: - SwiftUI View
//struct ImageShowView: View {
//    @Binding var showImageView: Bool
//    @ObservedObject var receiver: WebSocketReceiver
//
//    @State private var showCloseConfirmation = false
//    @State private var showSaveConfirmation = false
//    @State private var saveResultMessage = ""
//    @State private var showSaveResultAlert = false
//    @State private var shareImage: UIImage? = nil
//    @State private var showShareSheet = false
//
//    var body: some View {
//        ZStack {
//            Color.gray.ignoresSafeArea()
//            VStack {
//                captureContainer
//                    .padding(.vertical)
//                Spacer()
//                HStack {
//                    Button("保存") { showSaveConfirmation = true }
//                        .padding()
//                    Button("共有") {
//                        shareImage = captureContainer.snapshot()
//                        showShareSheet = true
//                    }
//                    .padding()
//                    Spacer()
//                    Button("閉じる") { showCloseConfirmation = true }
//                        .padding()
//                }
//            }
//        }
//        .confirmationDialog("本当に閉じますか？", isPresented: $showCloseConfirmation) {
//            Button("閉じる", role: .destructive) {
//                receiver.images.removeAll()
//                receiver.emojis.removeAll()
//                showImageView = false
//            }
//            Button("キャンセル", role: .cancel) {}
//        }
//        .alert("画像を保存しますか？", isPresented: $showSaveConfirmation) {
//            Button("保存") { performSave() }
//            Button("キャンセル", role: .cancel) {}
//        }
//        .alert(saveResultMessage, isPresented: $showSaveResultAlert) {
//            Button("OK", role: .cancel) {}
//        }
//        .sheet(isPresented: $showShareSheet, onDismiss: { shareImage = nil }) {
//            if let img = shareImage {
//                ActivityView(activityItems: [img])
//            }
//        }
//    }
//
//    /// キャプチャ対象のグリッド部分
//    private var captureContainer: some View {
//        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
//            ForEach(receiver.images.indices, id: \.self) { index in
//                Image(uiImage: receiver.images[index])
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Color.white)
//                    .cornerRadius(8)
//                    .overlay(alignment: .bottomTrailing) {
//                        Text(receiver.emojis[index])
//                            .font(.system(size: 80))
//                            .padding(8)
//                            .background(Circle().fill(Color.white))
//                    }
//            }
//        }
//        .padding(.horizontal, 64)
//    }
//
//    // MARK: - 保存処理
//    private func performSave() {
//        guard let img = captureContainer.snapshot() else {
//            saveResultMessage = "画像の取得に失敗しました"
//            showSaveResultAlert = true
//            return
//        }
//        PHPhotoLibrary.requestAuthorization { status in
//            DispatchQueue.main.async {
//                guard status == .authorized || status == .limited else {
//                    saveResultMessage = "写真ライブラリのアクセス権がありません"
//                    showSaveResultAlert = true
//                    return
//                }
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.creationRequestForAsset(from: img)
//                }) { success, error in
//                    DispatchQueue.main.async {
//                        saveResultMessage = success ? "フォトライブラリに保存しました" : "保存に失敗しました: \(error?.localizedDescription ?? "不明なエラー")"
//                        showSaveResultAlert = true
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - View Snapshot Extension
//extension View {
//    /// この View をホストして UIImage を生成
//    func snapshot() -> UIImage? {
//        let controller = UIHostingController(rootView: self)
//        controller.view.backgroundColor = .clear
//        guard let scene = UIApplication.shared.connectedScenes
//                .compactMap({ $0 as? UIWindowScene })
//                .first(where: { $0.activationState == .foregroundActive }),
//              let window = scene.windows.first
//        else { return nil }
//        window.addSubview(controller.view)
//        controller.view.frame = window.bounds
//        controller.view.layoutIfNeeded()
//        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds)
//        let image = renderer.image { _ in
//            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
//        }
//        controller.view.removeFromSuperview()
//        return image
//    }
//}
//
//// MARK: - Share Sheet Wrapper
//struct ActivityView: UIViewControllerRepresentable {
//    let activityItems: [Any]
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
//    }
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}
//
//// MARK: - Preview
//struct ImageShowView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dummy = WebSocketReceiver()
//        dummy.images = (0..<4).compactMap { _ in UIImage(systemName: "photo") }
//        dummy.emojis = ["😀", "😍", "😎", "🤖"]
//        return ImageShowView(showImageView: .constant(true), receiver: dummy)
//    }
//}


// MARK: - SwiftUI View
struct ImageShowView: View {
    @Binding var showImageView: Bool
    @ObservedObject var receiver: WebSocketReceiver

    @State private var showCloseConfirmation = false
    @State private var showSaveConfirmation = false
    @State private var saveResultMessage = ""
    @State private var showSaveResultAlert = false
    @State private var shareImage: UIImage? = nil
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            VStack {
                captureContainer
                    .padding(.vertical)
                Spacer()
                HStack {
                    Button("保存") { showSaveConfirmation = true }
                        .padding()
                    Button("共有") {
                        shareImage = captureContainer.snapshot()
                        showShareSheet = true
                    }
                    .padding()
                    Spacer()
                    Button("閉じる") { showCloseConfirmation = true }
                        .padding()
                }
            }
        }
        .confirmationDialog("本当に閉じますか？", isPresented: $showCloseConfirmation) {
            Button("閉じる", role: .destructive) {
                receiver.images.removeAll()
                receiver.emojis.removeAll()
                showImageView = false
            }
            Button("キャンセル", role: .cancel) {}
        }
        .alert("画像を保存しますか？", isPresented: $showSaveConfirmation) {
            Button("保存") { performSave() }
            Button("キャンセル", role: .cancel) {}
        }
        .alert(saveResultMessage, isPresented: $showSaveResultAlert) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $showShareSheet, onDismiss: { shareImage = nil }) {
            if let img = shareImage {
                ActivityView(activityItems: [img])
            }
        }
    }

    /// キャプチャ対象のグリッド部分
    private var captureContainer: some View {
        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 16) {
            ForEach(receiver.images.indices, id: \.self) { index in
//                Image(uiImage: receiver.images[index])
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .background(Color.white)
//                    .cornerRadius(8)
//                    .overlay(alignment: .bottomTrailing) {
//                        Text(receiver.emojis[index])
//                            .font(.system(size: 80))
//                            .padding(8)
//                            .background(Circle().fill(Color.white))
//                    }
                Image(uiImage: receiver.images[index])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.white)
                    .padding(16)
                    .cornerRadius(8)
                    .overlay(alignment: .bottomTrailing){
                        Text(receiver.emojis[index])
                            .font(.system(size: 80))
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white)
                            )
                    }
            }
        }
        .padding(.horizontal, 64)
    }

    // MARK: - 保存処理
    private func performSave() {
        guard let img = captureContainer.snapshot() else {
            saveResultMessage = "画像の取得に失敗しました"
            showSaveResultAlert = true
            return
        }
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized || status == .limited else {
                    saveResultMessage = "写真ライブラリのアクセス権がありません"
                    showSaveResultAlert = true
                    return
                }
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: img)
                }) { success, error in
                    DispatchQueue.main.async {
                        saveResultMessage = success ? "フォトライブラリに保存しました" : "保存に失敗しました: \(error?.localizedDescription ?? "不明なエラー")"
                        showSaveResultAlert = true
                    }
                }
            }
        }
    }
}

// MARK: - View Snapshot Extension
extension View {
    /// この View をホストして UIImage を生成
    func snapshot() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        controller.view.backgroundColor = .clear
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first
        else { return nil }
        window.addSubview(controller.view)
        controller.view.frame = window.bounds
        controller.view.layoutIfNeeded()
        let renderer = UIGraphicsImageRenderer(bounds: controller.view.bounds)
        let image = renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        controller.view.removeFromSuperview()
        return image
    }
}

// MARK: - Share Sheet Wrapper
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // iPad 用ポップオーバー設定
        if let pop = controller.popoverPresentationController {
            pop.sourceView = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows.first
            pop.sourceRect = CGRect(x: UIScreen.main.bounds.midX,
                                     y: UIScreen.main.bounds.midY,
                                     width: 0, height: 0)
            pop.permittedArrowDirections = []
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
struct ImageShowView_Previews: PreviewProvider {
    static var previews: some View {
        let dummy = WebSocketReceiver()
        dummy.images = (0..<4).compactMap { _ in UIImage(systemName: "photo") }
        dummy.emojis = ["😀", "😍", "😎", "🤖"]
        return ImageShowView(showImageView: .constant(true), receiver: dummy)
    }
}
