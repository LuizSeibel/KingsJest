//
//  PhaseTwo.swift
//  KingsJest
//
//  Created by Luiz Seibel on 08/04/25.
//

import SpriteKit
import CoreMotion

// SKPhysicsContactDelegate
class PhaseTwoController: SKScene{
    
    // Player & Moviment
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    var player: Player!
    var lives: Int = 3
    
    // Ui
    var windArrow: SKSpriteNode?
    var livesLabel: SKLabelNode!
    
    // Wind Mechanic
    var windForce: CGFloat = 0
    
    // MPC
    var onPlayerMove: ((MPCEncoder, MessageType, String?) -> Void)?
    
    // Scene Life Cycle
    var lastSpawnTime: TimeInterval = 0
    let spawnInterval: TimeInterval = 2.0
    var lastUpdateTime: TimeInterval = 0
    
    // Sabotage
    let sabotage = SabotageManager()
    
    override func didMove(to view: SKView) {
        // Setup
        self.physicsWorld.contactDelegate = self
        setup()
    
        // MPC - Notification Observer
        NotificationCenter.default.addObserver(self, selector: #selector(runSabotage), name: Notification.Name("sabotageReceived"), object: nil)
    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        let deltaTime = min(currentTime - lastUpdateTime, 1/60)
        lastUpdateTime = currentTime

        // Atualiza movimentação do player
        let angle = player.tiltMove(xAcceleration: -xAcceleration, deltaTime: CGFloat(deltaTime), windForce: windForce)
        playerVerify(angle: angle)
    }
    
    private func setup(){
        setupPlayer()
        GameHelpers.applyNearestFiltering(node: self)
        startMotionUpdates()
        setupLivesLabel()
        startWind()
        
        sabotage.setup(size: self.size)
        addChild(sabotage)
    }
}

// MARK: - Touches Controller
extension PhaseTwoController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Trata o toque inicial na tela
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let nodesAtPoint = nodes(at: location)

        if nodesAtPoint.contains(where: { $0.name == "sabotageButton" }) {
            handleSabotageButtonTap()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Trata o movimento do toque na tela
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Trata quando o toque termina
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Trata quando o sistema cancela um toque
    }
}

// MARK: - Contact Delegate
extension PhaseTwoController: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (UInt32.player | UInt32.tomato) {
            let tomato = (contact.bodyA.node as? TomatoNode) ?? (contact.bodyB.node as? TomatoNode)
            if let tomato, !tomato.hasContacted {
                tomato.hasContacted = true
                print("🍅 Tomate acertou o player!")
                sabotage.tomatoSabotageEffect()
            }
        }
    }
}

// MARK: - Game Rules
extension PhaseTwoController {
    private func playerVerify(angle: CGFloat){
        if angle >= 60 && !player.node.isPaused {
            lives -= 1
            livesLabel.text = "Lives: \(lives)"
            windForce = 0

            if lives <= 0 {
                print("💀 Player morreu!")
                loseGame()
            }

            player.restartAngle()

            player.node.isPaused = true

            let wait = SKAction.wait(forDuration: 1.0)
            let unpause = SKAction.run { self.player.node.isPaused = false }
            run(.sequence([wait, unpause]))
        }
    }
    
    private func loseGame() {
        print("Morreu")
        self.isPaused = true

        // Cria o label de Game Over
        let gameOverLabel = SKLabelNode(text: "GAME OVER")
        gameOverLabel.fontName = "AvenirNext-Bold"
        gameOverLabel.fontSize = 60
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.zPosition = 2000
        addChild(gameOverLabel)
    }
}

// MARK: - Wind Mechanics
extension PhaseTwoController{
    private func startWind() {
        let windCycle = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.randomizeWindForce()
            },
            SKAction.wait(forDuration: 3.0),

            SKAction.run { [weak self] in
                self?.windForce = 0.0000001
                self?.windUIUpdate()
                print("🌬️ Vento zerado")
            },
            SKAction.wait(forDuration: 0.5)
        ])

        let windAction = SKAction.repeatForever(windCycle)

        self.run(windAction, withKey: "windTimer")
    }
    
    private func randomizeWindForce(){
        let possibleValues =  [0.1, 0.25, 0.35, -0.001, 0.001, -0.1, -0.25, -0.35]
        if let random = possibleValues.randomElement() {
            self.windForce = random
            print("Vento alterado para: \(windForce)")
            windUIUpdate()
        }
    }
    
    private func windUIUpdate() {
        windArrow?.removeFromParent()

        guard abs(windForce) > 0.09 else {
            windArrow = nil
            return
        }

        let arrow = SKSpriteNode(imageNamed: "arrow")
        arrow.size = CGSize(width: 60, height: 60)
        arrow.zPosition = 1500
        arrow.alpha = 0.8

        if let cameraNode = camera {
            arrow.position = CGPoint(x: 0, y: cameraNode.frame.height / 2 - 100)
            cameraNode.addChild(arrow)
        } else {
            arrow.position = CGPoint(x: frame.midX, y: frame.maxY - 100)
            addChild(arrow)
        }

        // Direção: negativo → seta para direita | positivo → seta para esquerda
        arrow.zRotation = windForce > 0 ? .pi : 0

        windArrow = arrow
    }
}

// MARK: - Usefull Functions
extension PhaseTwoController{
    private func setupPlayer(){
        if let scenePlayerNode = self.childNode(withName: "player") {
            let texture = SKTexture(imageNamed: "RUN000")
            let size = CGSize(width: 82, height: 68)

            let newSize = CGSize(width: size.width, height: size.height)
            player = Player(texture: texture, position: scenePlayerNode.position, size: newSize, playerIdentifier: PlayerIdentifier(peerName: "", color: .black))
            scenePlayerNode.removeFromParent()
            player.node.zPosition = 4
            
            // Fator de escala, exemplo 1.5 (aumenta 50%)
            let scale: CGFloat = 2
            player.node.setScale(scale)
            player.node.physicsBody = nil
            
            player.setAnchorPreservingPhysics(to: CGPoint(x: 0.5, y: 0.0))
            
            player.setupBasicPhysics()
            
            addChild(player.node)
        }
    }
    
    private func startMotionUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.02 // Atualiza a cada 20ms
            motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
                if let accelerometerData = data {
                    
                    // Corrigir para landscape
                    let rawY = accelerometerData.acceleration.y
                    
                    // Se o jogo estiver em landscape, o eixo X do acelerômetro é, na verdade, o eixo Y
                    let adjusted = pow(abs(rawY), 1.2) * (rawY < 0 ? -1 : 1) // suaviza o controle
                    let rawAcceleration = CGFloat(-adjusted) * 10
                    
                    let deadZone: CGFloat = 0.25  // Limite para a "dead zone"
                    
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
    
    private func setupLivesLabel() {
        livesLabel = SKLabelNode(text: "Lives: \(lives)")
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        livesLabel.zPosition = 1000
        addChild(livesLabel)
    }
    
    private func handleSabotageButtonTap(){
        guard let button = childNode(withName: "sabotageButton") as? SKSpriteNode else { return }

        if button.userData?["isDisabled"] as? Bool == true {
            print("Esperando cooldown...")
            return
        }
        
        let encoder = SabotageEncoder(peerName: AttGameViewModel.shared.PlayerName)
        onPlayerMove?(encoder, .sabotage, nil)     // Envia a sabotagem para os outros players
        
        
        // ---- Animação e cooldown ----
        
        button.userData = ["isDisabled": true]
        button.alpha = 0.5

        // Feedback visual: adiciona label de cooldown
        let cooldownLabel = SKLabelNode(text: "10")
        cooldownLabel.fontName = "AvenirNext-Bold"
        cooldownLabel.fontSize = 24
        cooldownLabel.fontColor = .white
        cooldownLabel.position = CGPoint.zero
        cooldownLabel.zPosition = 101
        cooldownLabel.name = "cooldownLabel"
        button.addChild(cooldownLabel)

        var countdown = 10

        let countdownAction = SKAction.repeat(SKAction.sequence([
            SKAction.run {
                countdown -= 1
                cooldownLabel.text = "\(countdown)"
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: 10)

        let enable = SKAction.run {
            button.userData?["isDisabled"] = false
            button.alpha = 1.0
            cooldownLabel.removeFromParent()
        }

        button.run(SKAction.sequence([countdownAction, enable]))
    }
}

extension PhaseTwoController{
    @objc func runSabotage() {
        sabotage.run(sabotage: .tomato)
    }
}
