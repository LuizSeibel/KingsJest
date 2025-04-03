//
//  Lava.swift
//  KingsJest
//
//  Created by Willys Oliveira on 28/03/25.
//

import SpriteKit

class Lava {
    
    var nodes: [SKSpriteNode] = []
    
    var lava: SKSpriteNode?
    
    var moveLava: Bool = false
    
    let scene: SKScene
    
    lazy var lavaFrames: [SKTexture] = {
        return loadFrames(prefix: "File", count: 20)
    }()
    
    
    init(scene: SKScene) {
        self.scene = scene
        
        for node in scene.children{
            
            if node.name == "cena2Lava"{
                if let lavaNode = node as? SKSpriteNode {
                    setupPhysics(for: lavaNode)
                    nodes.append(lavaNode)
                }
            }
            
            if node.name == "lava"{
                if let lavaNode = node as? SKSpriteNode {
                    setupPhysics(for: lavaNode)
                    self.lava = lavaNode
                }
            }
        }
    }
    
    func move() {
        guard self.lava != nil else { return }
        subirLavaAteOFim()
    }
    
    private func setupPhysics(for lavaNode: SKSpriteNode) {
        lavaNode.physicsBody = SKPhysicsBody(texture: lavaNode.texture!, size: lavaNode.size)
        lavaNode.physicsBody?.isDynamic = false
        lavaNode.physicsBody?.categoryBitMask = .lava
        lavaNode.physicsBody?.contactTestBitMask = .player
        lavaNode.physicsBody?.collisionBitMask = 0
    }
    
    func subirLavaAteOFim() {
        guard let lava = self.lava else { return }
        
        let alturaDaLava = lava.frame.size.height
        let posicaoFinalY = scene.size.height + alturaDaLava - 500
        
        print("Altura da cena: \(scene.size.height) & Altura da lava:\(alturaDaLava) & Position final Y:\(posicaoFinalY)")

        
        let moveAction = SKAction.moveTo(y: posicaoFinalY, duration: 30.0)
        let animationAction = SKAction.repeatForever(SKAction.animate(with: lavaFrames, timePerFrame: 0.1))
        
        let group = SKAction.group([moveAction, animationAction])
        
        lava.run(group, withKey: "lavaMovement")
    }
    
    
    func loadFrames(prefix: String, count: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        
        for i in 1..<count {
            let texture = SKTexture(imageNamed: "\(prefix)\(i)")
            texture.filteringMode = .nearest
            
            frames.append(texture)
        }
        
        return frames
    }
}
