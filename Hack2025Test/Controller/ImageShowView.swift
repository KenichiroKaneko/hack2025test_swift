import SwiftUI


struct ImageShowView: View {
    @Binding var showImageView: Bool
    @ObservedObject var receiver: WebSocketReceiver  // 外から受け取る
    
    @State private var showCloseConfirmation = false
    
    var body: some View {
        ZStack {
            
            Color.gray.ignoresSafeArea()
            
            VStack {
                VStack {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 0) {
                        ForEach(receiver.images.indices, id: \.self) { index in
                            
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
                    .padding(64)
                    
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


class DummyReceiver: WebSocketReceiver {
    override init() {
        super.init()
        self.images = [
            UIImage(systemName: "person.crop.square")!,
            UIImage(systemName: "person.crop.square")!,
            UIImage(systemName: "person.crop.square")!,
            UIImage(systemName: "person.crop.square")!,
            UIImage(systemName: "star")!,
            UIImage(systemName: "heart")!
        ]
        self.emojis = [
            "😍", "😳", "😭", "😮", "💖", "⭐️"
        ]
    }
}

#Preview {
    ImageShowView(showImageView: .constant(true), receiver: DummyReceiver())
}
