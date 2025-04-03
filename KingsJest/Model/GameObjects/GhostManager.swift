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
    
    func createGhost(for peerID: String, at position: CGPoint = .zero) {
        guard peerID != playerName, ghostPlayers[peerID] == nil else { return }
        let ghost = GhostPlayer(position: position)
        scene?.addChild(ghost.node)
        ghostPlayers[peerID] = ghost
    }
    
    func update(currentTime: TimeInterval, lastUpdateTime: TimeInterval, playerPosition: CGPoint, playerVelocity: CGVector) {
        
        guard isRunning else { return }
        
        // Envio do snapshot local
        guard isRunning else { return }
        sendTimer += currentTime
        if sendTimer >= 0.03 {
            sendTimer = 0
            let snapshot = PlayerSnapshot(time: CACurrentMediaTime(), position: playerPosition, velocity: playerVelocity)
            let encoder = PlayerPositionEncoder(peerName: playerName, snapshot: snapshot)
            onPlayerMove?(encoder)
        }

        // Atualização dos ghosts remotos
        let renderDelay: TimeInterval = 0.15
        let renderTime = currentTime - renderDelay

        for (peerID, snapshots) in AttGameViewModel.shared.snapshots {
            if peerID == playerName { continue }
            guard let ghost = ghostPlayers[peerID] else { continue }

            if let position = interpolatedPosition(for: snapshots, at: renderTime) {
                ghost.node.position = position
                
                if let latest = snapshots.last {
                    ghost.updateTexture(for: latest.velocity)
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
