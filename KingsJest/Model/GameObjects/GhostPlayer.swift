//
//  GhostPlayer.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation
import SpriteKit

class GhostPlayer {
    private var lastState: PlayerAnimationState?
    let node: SKSpriteNode
    let identifier: PlayerIdentifier

    // MARK: - Animações
    lazy var idleFrames: [SKTexture] = {
        return loadFrames(prefix: "idle00", count: 6)
    }()
    
    lazy var runFrames: [SKTexture] = {
        return loadFrames(prefix: "RUN00", count: 7)
    }()
    
    lazy var jumpFrames: [SKTexture] = {
        return loadFrames(prefix: "jump00", count: 6)
    }()
    
    lazy var deathFrames: [SKTexture] = {
        return loadFrames(prefix: "death00", count: 7)
    }()

    init(position: CGPoint, identifier: PlayerIdentifier) {
        self.identifier = identifier
        
        let texture = SKTexture(imageNamed: "idle000")
        self.node = SKSpriteNode(texture: texture, size: CGSize(width: 96, height: 84))
        self.node.position = position
        self.node.zPosition = 4
        
        // Aparência fantasma
        self.node.alpha = 0.6
    }
    
    

    // MARK: - Carregamento de frames
    func loadFrames(prefix: String, count: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        for i in 0..<count {
            let colors = ourColors.returnColors(color: identifier.color)
            let image: UIImage = UIImage(named: "\(prefix)\(i)")!
                .gradientMapImage(from: colors)!
            let texture = SKTexture(image: image)
            texture.filteringMode = .nearest
            frames.append(texture)
        }
        return frames
    }

    // MARK: - Funções de animação
    func startIdleAnimation() {
        node.removeAllActions()
        node.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.1)), withKey: "idle")
    }
    
    func startRunAnimation() {
        node.removeAllActions()
        node.run(SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.06)), withKey: "run")
    }
    
    func startJumpAnimation() {
        node.removeAllActions()
        let action = SKAction.animate(with: jumpFrames, timePerFrame: 0.1)
        node.run(action, withKey: "jump")
    }
    
    func startDeadAnimation() {
        node.removeAllActions()
        let deathAnimation = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let holdLastFrame = SKAction.run {
            self.node.texture = self.deathFrames.last
        }
        let sequence = SKAction.sequence([deathAnimation, holdLastFrame])
        node.run(sequence, withKey: "dead")
    }

    // MARK: - Atualização do estado
    func update(for snapshot: PlayerSnapshot) {
        // Evita reiniciar a animação se o estado não mudou
        guard snapshot.state != lastState else { return }
        lastState = snapshot.state

        switch snapshot.state {
        case .run:
            node.xScale = snapshot.velocity.dx < 0 ? -1 : 1
            startRunAnimation()
        case .idle:
            startIdleAnimation()
        case .jump:
            startJumpAnimation()
        case .dead:
            startDeadAnimation()
        }
    }
    
//    func randomGhostColor() -> UIColor {
//        ghostColors.randomElement() ?? .white
//    }


}
