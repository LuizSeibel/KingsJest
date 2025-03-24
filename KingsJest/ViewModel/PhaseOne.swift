//
//  GameScene.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI
import CoreMotion

struct PhaseOneViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let skView = SKView(frame: UIScreen.main.bounds)
        viewController.view = skView
        
        if let scene = SKScene(fileNamed: "PhaseOne") {
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
        }
        
        skView.ignoresSiblingOrder = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Atualizações futuras, se necessário
    }
}

class PhaseOneController: SKScene {
    
    var player: SKSpriteNode!
    let cameraNode = SKCameraNode()
    let motionManager = CMMotionManager() // Gerenciador de movimento
    var xAcceleration: CGFloat = 0 // Variável para armazenar a aceleração
    
    override func didMove(to view: SKView) {
        
        // 1️⃣ Pegando o personagem da cena
        player = childNode(withName: "player") as? SKSpriteNode
        player.physicsBody?.linearDamping = 2.0 // Faz o personagem desacelerar mais rápido
        player.physicsBody?.friction = 1.0 // Adiciona mais atrito com o chão
        player.physicsBody?.restitution = 0.0  // Evita que o personagem fique quicando
        player.physicsBody?.allowsRotation = false // Evita que ele gire ao cair
        player.physicsBody?.mass = 0.1  // Ajusta a massa para um pulo mais fluido
        
        let spriteSheet = [
            SKTexture(imageNamed: "RUN000"),
            SKTexture(imageNamed: "RUN001"),
            SKTexture(imageNamed: "RUN002"),
            SKTexture(imageNamed: "RUN003"),
            SKTexture(imageNamed: "RUN004"),
            SKTexture(imageNamed: "RUN005"),
            SKTexture(imageNamed: "RUN006"),
            SKTexture(imageNamed: "RUN007")
        ]
        
        player.run(SKAction.repeatForever(SKAction.animate(with: spriteSheet, timePerFrame: 0.1)))
        
        
        
        applyNearestFiltering(node: self)
        
        
        // 2️⃣ Criando e configurando a câmera
        camera = cameraNode
        //        cameraNode.position = player.position
        addChild(cameraNode)
        
        // 3️⃣ Iniciar a captura de movimentos
        startMotionUpdates()
        setupWorldBounds()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOnGround() {  // Verifica se o personagem está no chão antes de pular
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60)) // Aplica impulso para o pulo
        }
    }
    
    func isOnGround() -> Bool {
        guard let playerPhysicsBody = player.physicsBody else { return false }
        return playerPhysicsBody.velocity.dy == 0 // Se a velocidade vertical for 0, significa que ele está no chão
    }
    
    override func update(_ currentTime: TimeInterval) {
        // 4️⃣ Atualiza a câmera para seguir o personagem
        updateCamera()
        updatePlayerMovement()
    }
    
    func updateCamera() {
        //        guard let player = player else { return }
        
        let cameraBounds = self.frame.width/1.9
        let bounds = calculateAccumulatedFrame().width/2 - cameraBounds
        
        
        if let positionPlayer = self.player?.position {
            if positionPlayer.x < bounds &&
                positionPlayer.x > -bounds {
                cameraNode.run(.moveTo(x: player.position.x, duration: 0.2))
            }
        }
        
        
        
    }
    
    func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.02 // Atualiza a cada 20ms
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let accelerometerData = data {
                    
                    // Corrigir para landscape
                    _ = accelerometerData.acceleration.x
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
    
    func updatePlayerMovement() {
        guard let player = player else { return }
        
        let maxSpeed: CGFloat = 300
        let sensitivity: CGFloat = 600 // Sensibilidade da inclinação
        
        // Aplica a velocidade diretamente, evitando deslizes
        let newVelocity = xAcceleration * sensitivity
        
        // Limita a velocidade máxima do personagem
        player.physicsBody?.velocity.dx = max(min(newVelocity, maxSpeed), -maxSpeed)
        
        
        // Verifica a direção do movimento e espelha o sprite
        if newVelocity < 0 {
            player.xScale = -1.0 // Inverte a imagem do personagem (para a esquerda)
        } else if newVelocity > 0 {
            player.xScale = 1.0 // Restaura a imagem do personagem (para a direita)
        }
    }
    
    func setupWorldBounds() {
        let worldWidth: CGFloat = 2550
        let worldHeight: CGFloat = 360
        
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
