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
    
    var isGameStarted: Bool = false
    var didShowCountdownOnce: Bool = false
    
    
    var isFinishedGame: Bool = false
    
    
    

    private var sendTimer: TimeInterval = 0
    var onPlayerMove: ((MPCEncoder) -> Void)?
    
    var lastLava: Bool = false
    var lavaTriggerPosition: CGPoint?
    var respawnPoint: CGPoint? = nil
    
    lazy var blocoArmadilha = self.childNode(withName: "blocoArmadilha") as! SKSpriteNode
    
    lazy var backgroundLimits: CGRect = {
        let backgroundLeft = self.childNode(withName: "pilastra0") as! SKSpriteNode
        let backgroundRight = self.childNode(withName: "backgroundCena6") as! SKSpriteNode
        let backgroundTop = self.childNode(withName: "backgroundCena6") as! SKSpriteNode

        let halfWidth = (self.view?.frame.width ?? 0) / 2

        return CGRect(
            x: backgroundLeft.frame.minX + halfWidth,
            y: backgroundRight.frame.minY,
            width: backgroundRight.frame.maxX - backgroundLeft.frame.minX - halfWidth * 2,
            height: backgroundTop.frame.maxY - backgroundRight.frame.minY - halfWidth
        )
    }()

    override func didMove(to view: SKView) {
        
        if let scenePlayerNode = self.childNode(withName: "player") {
            let texture = SKTexture(imageNamed: "RUN000")
            let size = CGSize(width: 94, height: 78)
            player = Player(texture: texture, position: scenePlayerNode.position, size: size)
            scenePlayerNode.removeFromParent()
            player.node.zPosition = 4
            addChild(player.node)
        }
        
        if let respawn = respawnPoint {
            player.node.position = respawn
        }
        
        if let sceneTrigger = self.childNode(withName: "triggerLava") as? SKSpriteNode {
            let position = sceneTrigger.position
            let size = sceneTrigger.size
            lavaTriggerPosition = position

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
            
            flagTrigger.node.zPosition = -11
            
            sceneTrigger.removeFromParent()
            addChild(flagTrigger.node)
        }
        
        lava = Lava(scene: self)
        
        plataform = Plataform(scene: self)
        plataform.startHorizontalPlatformsMovement()
        plataform.startVerticalPlatformsMovement()

        ground = Ground(scene: self)
        
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.position = CGPoint(x: player.node.position.x, y: 5)

        self.physicsWorld.contactDelegate = self
        applyNearestFiltering(node: self)
        startMotionUpdates()
        updateCamera()
        
        startCountdown()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
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
        
        guard self.isGameStarted else { return }

        player.bufferJump()
        
        if isOnGround() {  // Verifica se o personagem está no chão antes de pular
            player.jump()
            player.jumpBufferCounter = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard self.isGameStarted else { return }

        player.endJump()
    }
    
    func isOnGround() -> Bool {
        guard let playerPhysicsBody = player.node.physicsBody else { return false }
        return playerPhysicsBody.velocity.dy == 0 // Se a velocidade vertical for 0, significa que ele está no chão
    }
    
    var playerlastPosition: [CGPoint] = []
    
    override func update(_ currentTime: TimeInterval) {
        
        guard self.isGameStarted else { return }


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
        player.syncWithMovingPlatform(deltaTime: deltaTime)

        
        ghostManager.update(
            currentTime: currentTime,
            lastUpdateTime: lastUpdateTime,
            player: player
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
            // Mesmo com lava, continua acompanhando o player no eixo X
            let playerX = player.node.position.x
            let clampedX = min(max(playerX, backgroundLimits.minX), backgroundLimits.maxX)
            cameraNode.run(.moveTo(x: clampedX, duration: cameraMoveDuration))
        } else {
            // Verifica se a câmera está dentro dos limites
            let currentX = cameraNode.position.x
            guard currentX >= backgroundLimits.minX,
                  currentX <= backgroundLimits.maxX else { return }
            
            let playerX = player.node.position.x
            let clampedX = min(max(playerX, backgroundLimits.minX), backgroundLimits.maxX)
            cameraNode.run(.moveTo(x: clampedX, duration: cameraMoveDuration))
        }

    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let (body1, body2) = bodyA.categoryBitMask < bodyB.categoryBitMask ? (bodyA, bodyB) : (bodyB, bodyA)

        if body1.categoryBitMask == .player && body2.categoryBitMask == .plataform {
            if let plataforma = body2.node as? SKSpriteNode,
               plataforma.name == "plataformaDinamicaHorizontal" || plataforma.name == "plataformaDinamicaVertical" {
                player.isInDynamicPlataform = nil
            }
        }


    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        let (body1, body2) = bodyA.categoryBitMask < bodyB.categoryBitMask ? (bodyA, bodyB) : (bodyB, bodyA)
        
        if let plataformaNode = [body1.node, body2.node].first(where: { $0?.name == "blocoArmadilha" }) {
            handleBlocoArmadilha(plataformaNode!)
        }
        
        if body1.categoryBitMask == .player && body2.categoryBitMask == .plataform {
            if let plataforma = body2.node as? SKSpriteNode,
               plataforma.name == "plataformaDinamicaHorizontal" || plataforma.name == "plataformaDinamicaVertical" {
                player.isInDynamicPlataform = plataforma
            }
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
        guard node.name == "blocoArmadilha",
              let spriteNode = node as? SKSpriteNode else { return }

        // 🔹 Previne que o bloco seja ativado mais de uma vez
        if spriteNode.userData?["activated"] as? Bool == true { return }
        if spriteNode.userData == nil {
            spriteNode.userData = NSMutableDictionary()
        }
        spriteNode.userData?["activated"] = true

        let shake = SKAction.sequence([
            SKAction.rotate(toAngle: .pi / 32, duration: 0.05),
            SKAction.rotate(toAngle: -.pi / 32, duration: 0.05)
        ])
        let continuousShake = SKAction.repeat(shake, count: 1)
        let resetRotation = SKAction.rotate(toAngle: 0, duration: 0.05)

        let fallAction = SKAction.run {
            spriteNode.physicsBody?.affectedByGravity = true
            spriteNode.physicsBody?.isDynamic = true
            spriteNode.physicsBody?.collisionBitMask = 0
        }

        let fullSequence = SKAction.sequence([
            continuousShake,
            resetRotation,
            fallAction
        ])
        spriteNode.run(fullSequence, withKey: "fallWithShake")
    }

    
    private func handlePlayerLavaCollision() {
        
        player.die()
        
        DispatchQueue.global().async {
            for _ in 1...10 {
                DispatchQueue.main.async {
                    self.vibrate(.medium)
                }
                Thread.sleep(forTimeInterval: 0.05)
            }
        }
    }
    
    private func handleLavaTrigger() {
        lastLava = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.lava.move()
        }
    }
    
    private func handleFlagTrigger() {
        guard let finishGame else {
            print("Error: finishGame not defined!")
            return
        }
        player.node.physicsBody = nil
        player.node.zPosition = -5

        finishGame()
        ghostManager.stop()
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
    
    func startCountdown() {
        guard !self.didShowCountdownOnce else { return }
        self.didShowCountdownOnce = true
        
        let countdownLabel = SKLabelNode(fontNamed: "STSongti-TC-Bold")
        countdownLabel.fontSize = 120
        countdownLabel.fontColor = .white
        countdownLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        countdownLabel.zPosition = 100
        cameraNode.addChild(countdownLabel)
        
        let countdownNumbers = ["3", "2", "1", "GO!"]
        var actions: [SKAction] = []
        
        for (_, number) in countdownNumbers.enumerated() {
            let show = SKAction.run {
                countdownLabel.text = number
                countdownLabel.setScale(1.0)
                countdownLabel.alpha = 1.0
            }
            
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
            let pulse = SKAction.sequence([
                SKAction.scale(to: 2.0, duration: 0.1),
                SKAction.scale(to: 1.5, duration: 0.1)
            ])
            let wait = SKAction.wait(forDuration: 0.4)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)

            let combined = SKAction.sequence([show, scaleUp, pulse, wait, fadeOut])
            actions.append(combined)
        }
        
        let startGame = SKAction.run {
            countdownLabel.removeFromParent()
            self.enablePlayerControls()
        }
        
        self.disablePlayerControls()
        
        actions.append(startGame)
        
        countdownLabel.run(SKAction.sequence(actions))
    }
    
    func disablePlayerControls() {
        self.isGameStarted = false
    }

    func enablePlayerControls() {
        self.isGameStarted = true
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
