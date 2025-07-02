//
//  WebSocketModels.swift
//  Hack2025Test
//
//  Created by Sora Tanaka on 2025/07/02.
//

import Foundation

/// サーバーから送られてくる JSON メッセージの型
struct CountMessage: Codable {
    let type: String
    let count: Int
}
