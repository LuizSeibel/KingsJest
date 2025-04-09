//
//  PlayerSnapshot.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation

enum PlayerAnimationState: String, Codable {
    case idle
    case run
    case jump
    case dead
}


struct PlayerSnapshot: Codable {
    let time: TimeInterval
    let position: CGPoint
    let velocity: CGVector
    let state: PlayerAnimationState
}
