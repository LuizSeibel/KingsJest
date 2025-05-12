//
//  GhostManager.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation
import SpriteKit

// TODO: Colocar os fantasmas com as animações
class GhostManager {
    private var ghostPlayers: [String: GhostPlayer] = [:]
    private var sendTimer: TimeInterval = 0
    private weak var scene: SKScene? // Para adicionar/remover nós
    private var playerName: String = ""
    private var isRunning: Bool = true
    
    var onPlayerMove: ((MPCEncoder) -> Void)?

    init(scene: SKScene, playerName: String) {
        self.scene = scene
        self.playerName = playerName
    }
    
    func createGhost(for identifier: PlayerIdentifier, at position: CGPoint = .zero) {
        guard identifier.peerName != playerName, ghostPlayers[identifier.peerName] == nil else { return }
        let ghost = GhostPlayer(position: position, identifier: identifier)
        scene?.addChild(ghost.node)
        ghostPlayers[identifier.peerName] = ghost
    }
    
    func update(currentTime: TimeInterval, lastUpdateTime: TimeInterval, player: Player) {
        guard isRunning else { return }
        
        sendTimer += currentTime
        if sendTimer >= 0.1 {
            sendTimer = 0

            // Determina o estado atual do player
            let currentState: PlayerAnimationState
            switch player.stateMachine.currentState {
            case is RunState:
                currentState = .run
            case is JumpState:
                currentState = .jump
            case is DeadState:
                currentState = .dead
            default:
                currentState = .idle
            }

            let snapshot = PlayerSnapshot(
                time: CACurrentMediaTime(),
                position: player.node.position,
                velocity: player.node.physicsBody?.velocity ?? .zero,
                state: currentState
            )

            let encoder = PlayerPositionEncoder(peerName: playerName, snapshot: snapshot)
            onPlayerMove?(encoder)
        }

        // Atualização dos fantasmas
        let renderDelay: TimeInterval = 0.15
        let renderTime = currentTime - renderDelay

        for (peerID, snapshots) in AttGameViewModel.shared.snapshots {
            if peerID == playerName { continue }
            guard let ghost = ghostPlayers[peerID] else { continue }

            if let position = interpolatedPosition(for: snapshots, at: renderTime) {
                ghost.node.position = position

                if let latest = snapshots.last {
                    ghost.update(for: latest)
                }
            }
        }
    }

    
    private func interpolatedPosition(for snapshots: [PlayerSnapshot], at renderTime: TimeInterval) -> CGPoint? {
        guard !snapshots.isEmpty else { return nil }
        
        var s0: PlayerSnapshot?
        var s1: PlayerSnapshot?
        
        for i in 0 ..< snapshots.count {
            if snapshots[i].time >= renderTime {
                s1 = snapshots[i]
                if i > 0 { s0 = snapshots[i - 1] }
                break
            }
        }
        
        if s0 == nil && s1 == nil {
            return snapshots.last?.position
        }
        
        if let start = s0, let end = s1 {
            let totalTime = end.time - start.time
            let elapsed = renderTime - start.time
            let t = (totalTime == 0) ? 1 : CGFloat(elapsed / totalTime)

            return CGPoint(
                x: start.position.x + (end.position.x - start.position.x) * t,
                y: start.position.y + (end.position.y - start.position.y) * t
            )
        } else if let only = s1 {
            return only.position
        }
        
        return nil
    }
    
    func stop() {
        isRunning = false
    }
    
}
