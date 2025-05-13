//
//  PlayerIdentifier.swift
//  KingsJest
//
//  Created by Luiz Seibel on 08/05/25.
//

import Foundation

struct PlayerIdentifier: Codable, Equatable, Hashable {
    var peerName: String
    var color: ourColors
    
    static func == (lhs: PlayerIdentifier, rhs: PlayerIdentifier) -> Bool {
        return lhs.peerName == rhs.peerName
    }
}
