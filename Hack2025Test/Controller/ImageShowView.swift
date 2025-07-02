import SwiftUI


struct ImageShowView: View {
    @Binding var showImageView: Bool
    @ObservedObject var receiver: WebSocketReceiver  // 外から受け取る

    @State private var showCloseConfirmation = false

    var body: some View {
        ZStack {
            Color.gray.ignoresSafeArea()

            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 10) {
                        ForEach(receiver.images.indices, id: \.self) { index in
                            Image(uiImage: receiver.images[index])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }

                Button("閉じる") {
                    showCloseConfirmation = true
                }
                .padding(.bottom)
            }
        }
        .confirmationDialog("本当に閉じますか？", isPresented: $showCloseConfirmation) {
            Button("閉じる", role: .destructive) {
                showImageView = false
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}



#Preview {
//    ImageShowView()
}
