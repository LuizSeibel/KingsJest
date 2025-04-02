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
}

struct MessageEnvelope: Codable {
    let type: MessageType
    let payload: Data
}
