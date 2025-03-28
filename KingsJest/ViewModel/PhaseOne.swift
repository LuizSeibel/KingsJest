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
    var lastUpdateTime: TimeInterval = 0
    var finishGame: (() -> Void)?
    
    lazy var blocoArmadilha = self.childNode(withName: "blocoArmadilha") as! SKSpriteNode
    
    lazy var backgroundLimits:CGRect = {
        let backgroundLeft = self.childNode(withName: "pilastra") as! SKSpriteNode
        let backgroundRight = self.childNode(withName: "backgroundCena6") as! SKSpriteNode
        let backgroundTop = self.childNode(withName: "backgroundCena6") as! SKSpriteNode
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
        
        if let sceneTrigger = self.childNode(withName: "triggerLava") as? SKSpriteNode {
                
            let position = sceneTrigger.position
            let size = sceneTrigger.size
            let lavaTrigger = Trigger(
                position: position,
                size: size,
                categoryBitMask: 3,
                contactTestBitMask: 1
            )
            
            sceneTrigger.removeFromParent()
            addChild(lavaTrigger.node)
        }
        
        if let sceneTrigger = self.childNode(withName: "bandeira") as? SKSpriteNode {
            let position = sceneTrigger.position
            let size = sceneTrigger.size
            let texture = sceneTrigger.texture!
            
            let flagTrigger = Trigger(
                position: position,
                size: size,
                categoryBitMask: 5,
                contactTestBitMask: 1,
                texture: texture
            )
            
            sceneTrigger.removeFromParent()
            addChild(flagTrigger.node)
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
        player.bufferJump()
        
        if isOnGround() {  // Verifica se o personagem está no chão antes de pular
            player.jump()
            player.jumpBufferCounter = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.endJump()
    }
    
    func isOnGround() -> Bool {
        guard let playerPhysicsBody = player.node.physicsBody else { return false }
        return playerPhysicsBody.velocity.dy == 0 // Se a velocidade vertical for 0, significa que ele está no chão
    }
    
    override func update(_ currentTime: TimeInterval) {
                
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Atualiza a movimentação horizontal
        player.move(xAcceleration: xAcceleration, deltaTime: CGFloat(deltaTime))
        
        // Continua o pulo se o botão estiver pressionado
        player.continueJump(deltaTime: CGFloat(deltaTime))
        
        player.updateCoyoteTime(deltaTime: deltaTime)
        
        player.updateJumpBuffer(deltaTime: deltaTime)
        
        player.updateJumpState()
        
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
        let trigger = (bodyA.categoryBitMask == 3) ? bodyA : bodyB
        let flag = (bodyA.categoryBitMask == 5) ? bodyA : bodyB

        if playerBody.categoryBitMask == 1 && lavaBody.categoryBitMask == 2 {
            print("🔥 Player caiu na Lava! Chamando die()...")
            player.die()
        }
        
        // Lava Trigger
        if playerBody.categoryBitMask == 1 && trigger.categoryBitMask == 3 {
            print("🎉 Player ativou o Trigger!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("🔥 Lava Subindo...")
                self.lava.move()
            }
        }
        
        // Flag Trigger
        if playerBody.categoryBitMask == 1 && flag.categoryBitMask == 5 {
            print("🎉 Terminou a Fase!")
            if let finishGame{
                finishGame()
            }
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
                    let adjusted = pow(abs(rawY), 1.2) * (rawY < 0 ? -1 : 1) // suaviza o controle
                    let rawAcceleration = CGFloat(-adjusted) * 8
                    
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
