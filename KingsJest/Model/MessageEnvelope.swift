//
//  MessageEnvelop.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation

enum MessageType: String, Codable {
    case startGame
    case stopGame
    case position
    case players
}

struct MessageEnvelope<T: Codable>: Codable {
    let type: MessageType
    let content: T
}
