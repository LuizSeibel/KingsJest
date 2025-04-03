//
//  GameScene.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI
import CoreMotion
import UIKit

class PhaseOneController: SKScene, SKPhysicsContactDelegate {
    
    var ghostManager: GhostManager!
    var player: Player!
    var lava: Lava!
    var plataform: Plataform!
    var ground: Ground!
    let cameraNode = SKCameraNode()
    let motionManager = CMMotionManager() // Gerenciador de movimento
    var xAcceleration: CGFloat = 0 // Variável para armazenar a aceleração
    var lastUpdateTime: TimeInterval = 0
    var finishGame: (() -> Void)?
    
    var isFinishedGame: Bool = false
    
    private var sendTimer: TimeInterval = 0
    var onPlayerMove: ((MPCEncoder) -> Void)?
    
    var lastLava: Bool = false
    
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
        
        if let scenePlayerNode = self.childNode(withName: "player") {
            let texture = SKTexture(imageNamed: "RUN000")
            player = Player(texture: texture, position: scenePlayerNode.position)
            scenePlayerNode.removeFromParent()
            player.node.zPosition = 4
            addChild(player.node)
        }
        
        if let sceneTrigger = self.childNode(withName: "triggerLava") as? SKSpriteNode {
            
            let position = sceneTrigger.position
            let size = sceneTrigger.size
            let lavaTrigger = Trigger(
                position: position,
                size: size,
                categoryBitMask: .trigger,
                contactTestBitMask: .player
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
                categoryBitMask: .flag,
                contactTestBitMask: .player,
                texture: texture
            )
            
            sceneTrigger.removeFromParent()
            addChild(flagTrigger.node)
        }
        
        lava = Lava(scene: self)
        plataform = Plataform(scene: self)
        ground = Ground(scene: self)
        
        camera = cameraNode
        addChild(cameraNode)
        
        self.physicsWorld.contactDelegate = self
        applyNearestFiltering(node: self)
        startMotionUpdates()
        updateCamera()
        
        
        ghostManager = GhostManager(scene: self, playerName: AttGameViewModel.shared.PlayerName)
        ghostManager.onPlayerMove = { [weak self] snapshot in
            self?.onPlayerMove?(snapshot)
        }
        
        for peerID in AttGameViewModel.shared.players {
            ghostManager.createGhost(for: peerID.displayName, at: player.node.position)
            //print(peerID.displayName)
        }
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
    
    var playerlastPosition: [CGPoint] = []
    
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
        
        ghostManager.update(
            currentTime: currentTime,
            lastUpdateTime: lastUpdateTime,
            playerPosition: player.getPosition(),
            playerVelocity: player.node.physicsBody?.velocity ?? .zero
        )
        
        // O que eu quero atualizar num framerate menor
        guard Int(currentTime*60) % 10 == 0 else { return }
        updateCamera()
    }
    
    func updateCamera() {
        let playerY = player.node.position.y
        let cameraMoveDuration = 0.3
        
        // =============================
        // MOVIMENTAÇÃO VERTICAL
        // =============================
        if lastLava && playerY >= 90 {
            let targetY = (playerY >= 720) ? 720 : (playerY - 30)
            cameraNode.run(.moveTo(y: targetY, duration: cameraMoveDuration))
        } else {
            cameraNode.run(.moveTo(y: 0, duration: cameraMoveDuration))
        }
        
        // =============================
        // MOVIMENTAÇÃO HORIZONTAL
        // =============================
        if lastLava {
            cameraNode.run(.moveTo(x: backgroundLimits.maxX, duration: cameraMoveDuration))
        } else {
            // Verifica se a câmera está dentro dos limites
            let currentX = cameraNode.position.x
            guard currentX >= backgroundLimits.minX,
                  currentX <= backgroundLimits.maxX else { return }
            
            // Limita a posição da câmera ao mínimo e máximo permitido
            let playerX = player.node.position.x
            let clampedX = min(max(playerX, backgroundLimits.minX), backgroundLimits.maxX)
            cameraNode.run(.moveTo(x: clampedX, duration: cameraMoveDuration))
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let (body1, body2) = bodyA.categoryBitMask < bodyB.categoryBitMask ? (bodyA, bodyB) : (bodyB, bodyA)
        
        if let node = [body1.node, body2.node].compactMap({ $0 }).first {
            handleBlocoArmadilha(node)
        }
        
        if body1.categoryBitMask == .player && body2.categoryBitMask == .lava {
            handlePlayerLavaCollision()
        }
        
        if body1.categoryBitMask == .player && body2.categoryBitMask == .trigger {
            handleLavaTrigger()
        }
        
        if body1.categoryBitMask == .player && body2.categoryBitMask == .flag {
            handleFlagTrigger()
        }
    }
    
    private func handleBlocoArmadilha(_ node: SKNode) {
        if node.name == "blocoArmadilha", let spriteNode = node as? SKSpriteNode {
            spriteNode.physicsBody?.affectedByGravity = true
            spriteNode.physicsBody?.collisionBitMask = 0
        }
    }
    
    private func handlePlayerLavaCollision() {
        print("🔥 Player caiu na Lava! Chamando die()...")
        vibrate(.heavy) // Vibração forte
        player.die()
    }
    
    private func handleLavaTrigger() {
        print("🎉 Player ativou o Trigger!")
        lastLava = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("🔥 Lava Subindo...")
            self.lava.move()
        }
    }
    
    private func handleFlagTrigger() {
        
//        guard !isFinishedGame else { return }
//        isFinishedGame = true
        
        
        guard let finishGame else {
            print("Error: finishGame not defined!")
            return
        }
        
        print("🎉 Terminou a Fase!")
        
        finishGame()
        
        ghostManager.stop()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            if let skView = self.view {
//                print("🎉 Matei a cena!")
//                
//                skView.presentScene(nil) // Remove a cena do SKView
//            }
//        }
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
                    let rawAcceleration = CGFloat(-adjusted) * 10
                    
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

    
    func vibrate(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = point.x - self.x
        let dy = point.y - self.y
        return sqrt(dx * dx + dy * dy)
    }
}

extension CGPoint {
    func isNear(to point: CGPoint, threshold: CGFloat = 1.0) -> Bool {
        return self.distance(to: point) < threshold
    }
}
