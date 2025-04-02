//
//  PlayerSnapshot.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation

struct PlayerSnapshot: Codable {
    let time: TimeInterval
    let position: CGPoint
    let velocity: CGVector
}
