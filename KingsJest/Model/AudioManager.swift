//
//  AudioManager.swift
//  KingsJest
//
//  Created by Willys Oliveira on 02/05/25.
//

import SpriteKit

class AudioManager {
    static let shared = AudioManager()

    private(set) var isSoundEnabled: Bool = true

    private init() {}

    func playSound(named name: String, on node: SKNode, waitForCompletion: Bool = false) {
        guard isSoundEnabled else { return }
        
        let soundAction = SKAction.playSoundFileNamed(name, waitForCompletion: waitForCompletion)
        node.run(soundAction)
    }

    func toggleSound(enabled: Bool) {
        isSoundEnabled = enabled
    }

    func mute() {
        isSoundEnabled = false
    }

    func unmute() {
        isSoundEnabled = true
    }
}
