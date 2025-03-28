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
    
    lazy var blocoArmadilha = self.childNode(withName: "blocoArmadilha") as! SKSpriteNode
    
    lazy var backgroundLimits:CGRect = {
        let backgroundLeft = self.childNode(withName: "pilastra0") as! SKSpriteNode
        let backgroundRight = self.childNode(withName: "backgroundCena6") as! SKSpriteNode
        let backgroundTop = self.childNode(withName: "backgroundCena7") as! SKSpriteNode
        return CGRect(x: backgroundLeft.frame.minX + (self.view?.frame.width ?? 0) / 2,
                      y: backgroundRight.frame.minY,
                      width: backgroundRight.frame.minX - backgroundLeft.frame.minX,
                      height: backgroundTop.frame.maxY - backgroundRight.frame.minY - (self.view?.frame.width ?? 0) / 2)
    }()
    
    override func didMove(to view: SKView) {
        
        print("backgroundLimits", backgroundLimits, backgroundLimits.midX)
        
        
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
        print("cameraNode", cameraNode)
        
        self.physicsWorld.contactDelegate = self
        applyNearestFiltering(node: self)
        startMotionUpdates()
        updateCamera()
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
        
        
//        cameraNode.position = player.node.position

        if player.isJumping && isOnGround() {
            player.endJump()
        }
        
        player.move(xAcceleration: xAcceleration)
        player.stateMachine.update(deltaTime: currentTime)
        
        
        // O que eu quero atualizar num framerate menor
        
        guard Int(currentTime*60) % 10 == 0 else { return }
        updateCamera()
        
    }
    
    //TODO: Ajustar os calculos de limite da camera.
    func updateCamera() {
        
        print("Y player: ", player.node.position.y)
        print("Y cam: ", cameraNode.frame.height)
        
        
        if player.node.position.y >= 90 {
            self.cameraNode.run(.moveTo(y: player.node.position.y - 30, duration: 0.3))
        }
        else{
            self.cameraNode.run(.moveTo(y: 0, duration: 0.3))
        }
        
//        if player.node.position.y > cameraNode.position.y * 0.8 {
//            cameraNode.position.y += cameraNode.position.y * 0.8
//        }
//        else if player.node.position.y < cameraNode.position.y * 1.2 {
//            cameraNode.position.y = cameraNode.position.y
//        }
        
        
        guard self.cameraNode.position.x >= backgroundLimits.minX,
              self.cameraNode.position.x <= backgroundLimits.maxX else { return }

        //print(self.cameraNode.position.x,  backgroundLimits.minX)
        self.cameraNode.run(.moveTo(x: min(max(player.node.position.x, backgroundLimits.minX),backgroundLimits.maxX), duration: 0.3))
                                    
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if let blocoArmadilha = [bodyA.node, bodyB.node].filter({$0?.name == "blocoArmadilha"}).first as? SKSpriteNode {
            blocoArmadilha.physicsBody?.affectedByGravity = true
            blocoArmadilha.physicsBody?.collisionBitMask = 0
        }
        
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
    
    //TODO: Ajustar os calculos de limite da cena inteira.
    func setupWorldBounds() {
//        let worldWidth: CGFloat = 10000
//        let worldHeight: CGFloat = 2160
//        
//        let borderBody = SKPhysicsBody(edgeLoopFrom: CGRect(
//            x: -worldWidth / 2,  // Ajuste para considerar o novo ponto de origem
//            y: -worldHeight / 2, // Ajuste para o eixo Y centralizado
//            width: worldWidth,
//            height: worldHeight
//        ))
//        
//        borderBody.friction = 0
//        borderBody.restitution = 0 // Evita que o personagem quique ao bater na parede
//        self.physicsBody = borderBody
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
