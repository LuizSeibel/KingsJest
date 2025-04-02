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
    
    // Chama o singleton
    var ghostNodes: [String: SKShapeNode] = [:]
    var ghostInterpolationProgress: [String: CGFloat] = [:]
    
    var ghostManager: GhostManager!
    var player: Player!
    var lava: Lava!
    let cameraNode = SKCameraNode()
    let motionManager = CMMotionManager() // Gerenciador de movimento
    var xAcceleration: CGFloat = 0 // Variável para armazenar a aceleração
    var lastUpdateTime: TimeInterval = 0
    var finishGame: (() -> Void)?
    
    
    private var sendTimer: TimeInterval = 0
    var onPlayerMove: ((PlayerSnapshot) -> Void)?
    
    
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
        
        self.physicsWorld.contactDelegate = self
        applyNearestFiltering(node: self)
        startMotionUpdates()
        updateCamera()
        
        
        ghostManager = GhostManager(scene: self, playerName: player.node.name!)
        ghostManager.onPlayerMove = { [weak self] snapshot in
            self?.onPlayerMove?(snapshot)
        }

        for peerID in AttGameViewModel.shared.players {
            ghostManager.createGhost(for: peerID.displayName, at: player.node.position)
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
        
        //updateRemoteGhosts(currentTime: currentTime)
        
        // O que eu quero atualizar num framerate menor
        guard Int(currentTime*60) % 10 == 0 else { return }
        updateCamera()
    }
    
    // Função para dar update nos fantasmas remotos
//    private func updateRemoteGhosts(currentTime: TimeInterval) {
//        sendTimer += currentTime - lastUpdateTime
//
//        if sendTimer >= 0.03 {
//            let now = CACurrentMediaTime()
//            let velocity = player.node.physicsBody?.velocity ?? .zero
//
//            let snapshot = PlayerSnapshot(
//                time: now,
//                position: player.getPosition(),
//                velocity: velocity
//            )
//            sendTimer = 0
//            onPlayerMove?(snapshot)
//        }
//
//        let renderDelay: TimeInterval = 0.15
//        let renderTime = currentTime - renderDelay
//
//        for (peerID, snapshots) in AttGameViewModel.shared.snapshots {
//            if peerID == player.node.name { continue }
//            guard let ghostNode = ghostNodes[peerID] else { continue }
//
//            if let interpolatedPos = interpolatedPosition(for: snapshots, at: renderTime) {
//                ghostNode.position = interpolatedPos
//            }
//        }
//    }
    
    // Snapshot-based interpolation.
    // Podemos ainda melhorar usando Extrapolação usando velocidade, trocar a interpolação linear por Catmull-Rom splines,
    // SmoothDamp, ou outras abordagens, gerando movimentos mais suaves e utilizar predição quando os snapshots chegarem Dead Reckoning.
//    private func interpolatedPosition(for snapshots: [PlayerSnapshot], at renderTime: TimeInterval) -> CGPoint? {
//        guard !snapshots.isEmpty else { return nil }
//
//        var s0: PlayerSnapshot?
//        var s1: PlayerSnapshot?
//
//        for i in 0 ..< snapshots.count {
//            if snapshots[i].time >= renderTime {
//                s1 = snapshots[i]
//                if i > 0 {
//                    s0 = snapshots[i - 1]
//                }
//                break
//            }
//        }
//
//        // Se não encontrou um par válido, usa fallback
//        if s0 == nil && s1 == nil {
//            // Nenhum snapshot está depois do renderTime, então usamos o último
//            return snapshots.last?.position
//        }
//
//        // Se achou s0 e s1, interpola
//        if let start = s0, let end = s1 {
//            let totalTime = end.time - start.time
//            let elapsed = renderTime - start.time
//            let t = (totalTime == 0) ? 1 : CGFloat(elapsed / totalTime)
//
//            let x = start.position.x + (end.position.x - start.position.x) * t
//            let y = start.position.y + (end.position.y - start.position.y) * t
//            return CGPoint(x: x, y: y)
//        } else if let only = s1 {
//            return only.position
//        }
//
//        return nil
//    }
    
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
            //print("🎉 Player ativou o Trigger!")
            lastLava = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("🔥 Lava Subindo...")
                self.lava.move()
            }
        }
    
        // Flag Trigger
        if playerBody.categoryBitMask == 1 && flag.categoryBitMask == 5 {
            print("🎉 Terminou a Fase!")
            if let finishGame {
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
