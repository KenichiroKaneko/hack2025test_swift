//
//  ContentView.swift
//  Hack2025Test
//
//  Created by 健一郎金子 on 2025/06/18.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    var body: some View {
        NavigationStack {
            HStack {
                navigationButtonView(destination: ControllerView(), label: "Controller")
                navigationButtonView(destination: PlayView(), label: "Play")
            }
            .frame(maxWidth: .infinity)
            
        }
    }
    
    func navigationButtonView<Destination: View>(
        destination: Destination, label: String) -> some View {
            NavigationLink(destination: destination) {
                Text(label)
                    .frame(width: 120, height: 64)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue, lineWidth: 2)
                    }
                    .padding(.horizontal, 12)
            }
        }
}

#Preview {
    ContentView()
}
