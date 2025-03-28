//
//  GameScene.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI
import CoreMotion

class PhaseOneController: SKScene, SKPhysicsContactDelegate {
    
    var player: Player!
    var lava: Lava!
    let cameraNode = SKCameraNode()
    let motionManager = CMMotionManager() // Gerenciador de movimento
    var xAcceleration: CGFloat = 0 // Variável para armazenar a aceleração
    
    override func didMove(to view: SKView) {
        
        if let scenePlayerNode = self.childNode(withName: "player") {
            let texture = SKTexture(imageNamed: "RUN000")
            player = Player(texture: texture, position: scenePlayerNode.position)
            scenePlayerNode.removeFromParent()
            player.node.zPosition = 5
            addChild(player.node)
        }
        
        lava = Lava(scene: self)

        camera = cameraNode
        addChild(cameraNode)
        
        self.physicsWorld.contactDelegate = self
        applyNearestFiltering(node: self)
        setupWorldBounds()
        startMotionUpdates()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOnGround() {  // Verifica se o personagem está no chão antes de pular
            player.jump()
        }
    }
    
    func isOnGround() -> Bool {
        guard let playerPhysicsBody = player.node.physicsBody else { return false }
        return playerPhysicsBody.velocity.dy == 0 // Se a velocidade vertical for 0, significa que ele está no chão
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        cameraNode.position = player.node.position

        
        if player.isJumping && isOnGround() {
            player.endJump()
        }
        
        player.move(xAcceleration: xAcceleration)
        player.stateMachine.update(deltaTime: currentTime)
    }
    
    func updateCamera() {
        
        let cameraBounds = self.frame.width/6
        let bounds = calculateAccumulatedFrame().width/2 - cameraBounds
        
        
        if let positionPlayer = self.player.node?.position {
            if positionPlayer.x < bounds &&
                positionPlayer.x > -bounds {
                cameraNode.run(.moveTo(x: player.node.position.x, duration: 0.2))
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let playerBody = (bodyA.categoryBitMask == 1) ? bodyA : bodyB
        let lavaBody = (bodyA.categoryBitMask == 2) ? bodyA : bodyB

        if playerBody.categoryBitMask == 1 && lavaBody.categoryBitMask == 2 {
            print("🔥 Player caiu na Lava! Chamando die()...")
            player.die()
        }
    }
    
    
    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.02 // Atualiza a cada 20ms
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let accelerometerData = data {
                    
                    // Corrigir para landscape
                    let rawY = accelerometerData.acceleration.y
                    
                    // Se o jogo estiver em landscape, o eixo X do acelerômetro é, na verdade, o eixo Y
                    let rawAcceleration = CGFloat(-rawY) * 10  //
                    
                    let deadZone: CGFloat = 0.5  // Limite para a "dead zone"
                    
                    // Se a aceleração estiver dentro da "dead zone", não movimenta o personagem
                    if abs(rawAcceleration) < deadZone {
                        self.xAcceleration = 0  // Não há movimento
                    } else {
                        self.xAcceleration = rawAcceleration  // Movimenta o personagem normalmente
                    }
                }
                
                
            }
        }
    }
        
    func setupWorldBounds() {
        let worldWidth: CGFloat = 10000
        let worldHeight: CGFloat = 2160
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(
            x: -worldWidth / 2,  // Ajuste para considerar o novo ponto de origem
            y: -worldHeight / 2, // Ajuste para o eixo Y centralizado
            width: worldWidth,
            height: worldHeight
        ))
        
        borderBody.friction = 0
        borderBody.restitution = 0 // Evita que o personagem quique ao bater na parede
        self.physicsBody = borderBody
    }
    
    func applyNearestFiltering(node: SKNode) {
        if let sprite = node as? SKSpriteNode {
            sprite.texture?.filteringMode = .nearest
        }
        
        for child in node.children {
            applyNearestFiltering(node: child) // Aplica recursivamente para todos os filhos
        }
    }

}
