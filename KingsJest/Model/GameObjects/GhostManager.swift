//
//  GhostManager.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation
import SpriteKit

class GhostManager {
    private var ghostNodes: [String: SKShapeNode] = [:]
    private var sendTimer: TimeInterval = 0
    private weak var scene: SKScene? // Para adicionar/remover nós
    private var playerName: String = ""
    
    var onPlayerMove: ((PlayerSnapshot) -> Void)?

    init(scene: SKScene, playerName: String) {
        self.scene = scene
        self.playerName = playerName
    }
    
    func createGhost(for peerID: String, at position: CGPoint = .zero) {
        guard peerID != playerName, ghostNodes[peerID] == nil else { return }
        let ghost = SKShapeNode(rectOf: CGSize(width: 40, height: 40))
        ghost.fillColor = .green
        ghost.strokeColor = .clear
        ghost.position = position
        ghost.zPosition = 4
        scene?.addChild(ghost)
        ghostNodes[peerID] = ghost
    }
    
    func update(currentTime: TimeInterval, lastUpdateTime: TimeInterval, playerPosition: CGPoint, playerVelocity: CGVector) {
        // Envio do snapshot local
        sendTimer += currentTime - lastUpdateTime
        if sendTimer >= 0.03 {
            sendTimer = 0
            let snapshot = PlayerSnapshot(time: CACurrentMediaTime(), position: playerPosition, velocity: playerVelocity)
            onPlayerMove?(snapshot)
        }

        // Atualização dos ghosts remotos
        let renderDelay: TimeInterval = 0.15
        let renderTime = currentTime - renderDelay

        for (peerID, snapshots) in AttGameViewModel.shared.snapshots {
            if peerID == playerName { continue }
            guard let ghostNode = ghostNodes[peerID] else { continue }

            if let position = interpolatedPosition(for: snapshots, at: renderTime) {
                ghostNode.position = position
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
}
