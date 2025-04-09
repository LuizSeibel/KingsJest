//
//  MPCEncoder.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import Foundation

protocol MPCEncoder: Codable {
    var peerName: String { get set }
}

extension MPCEncoder {
    func data() -> Data? {
        try? JSONEncoder().encode(self)
    }
}

struct StartGameEncoder: MPCEncoder {
    var peerName: String
}

struct StopGameEncoder: MPCEncoder {
    var peerName: String
}

struct PlayerPositionEncoder: MPCEncoder, Codable {
    var peerName: String
    var snapshot: PlayerSnapshot
}
