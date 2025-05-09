//
//  PlayerIdentifier.swift
//  KingsJest
//
//  Created by Luiz Seibel on 08/05/25.
//

import Foundation

enum ourColors: Int, Codable, CaseIterable{
    case yellow = 1
    case blue = 2
    case orange = 3
    case black = 4
    case pink = 5
    case purple = 6
    case red = 7
    case green = 8
    case none = 0
}

struct PlayerIdentifier: Codable, Equatable {
    var peerName: String
    var color: ourColors
    
    static func == (lhs: PlayerIdentifier, rhs: PlayerIdentifier) -> Bool {
        return lhs.peerName == rhs.peerName
    }
}
