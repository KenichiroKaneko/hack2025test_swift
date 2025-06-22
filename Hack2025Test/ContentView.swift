//
//  ContentView.swift
//  Hack2025Test
//
//  Created by 健一郎金子 on 2025/06/18.
//

import SwiftUI
import SwiftData
//import SwiftUe

struct ContentView: View {
    var body: some View {
        NavigationStack {
            HStack {
                navigationButtonView(destination: ContentView(), label: "Controller")
                navigationButtonView(destination: ContentView(), label: "Camera")
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray)
            
        }
    }
    
    func navigationButtonView<Destination: View>(
        destination: Destination, label: String) -> some View {
            NavigationLink(destination: destination) {
                Text(label)
                    .padding(8)
                    .background(in: RoundedRectangle(cornerRadius: 30))
            }
        }
}

#Preview {
    ContentView()
}
