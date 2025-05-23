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
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var windForce: CGFloat = 0
    
    var player: Player!
    var spawner: Spawner!
    var sauceOverlay: SKSpriteNode!
    var windArrow: SKSpriteNode?
    
    var lastSpawnTime: TimeInterval = 0
    let spawnInterval: TimeInterval = 2.0
    
    var lastUpdateTime: TimeInterval = 0
    
    var onPlayerMove: ((MPCEncoder, MessageType, String?) -> Void)?
    
    var lives: Int = 3
    var livesLabel: SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        setupPlayer()
        
        //setupSpawner()
        
        startMotionUpdates()
        
        GameHelpers.applyNearestFiltering(node: self)
        
        startWind()
        sauceOverlaySetup()
        
        setupLivesLabel()
        
        //tomatoRain()
        
        NotificationCenter.default.addObserver(self, selector: #selector(runTomatoRain), name: Notification.Name("sabotageReceived"), object: nil)
    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Calcula deltaTime de forma segura
        var deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        if deltaTime > 1 {
            deltaTime = 1 / 60 // Limita deltaTime para evitar saltos
        }

        // Inicializa o tempo de spawn na primeira execução
        if lastSpawnTime == 0 {
            lastSpawnTime = currentTime
        }

        // Atualiza movimentação do player
        let angle = player.tiltMove(xAcceleration: -xAcceleration, deltaTime: CGFloat(deltaTime), windForce: windForce)
        
        if angle >= 60 && player.node.isPaused == false {
            self.lives -= 1
            self.livesLabel.text = "Lives: \(self.lives)"
            self.windForce = 0

            if self.lives <= 0 {
                print("💀 Player morreu!")
                self.playerDied()
            }

            player.restartAngle()

            // Pausa temporariamente para respawn
            player.node.isPaused = true

            let wait = SKAction.wait(forDuration: 1.0)
            let unpause = SKAction.run {
                self.player.node.isPaused = false
            }
            self.run(SKAction.sequence([wait, unpause]))
        }
        

        if currentTime - lastSpawnTime >= spawnInterval {
            lastSpawnTime = currentTime
        }
    }
    
    func setupLivesLabel() {
        livesLabel = SKLabelNode(text: "Lives: \(lives)")
        livesLabel.fontName = "AvenirNext-Bold"
        livesLabel.fontSize = 24
        livesLabel.fontColor = .white
        livesLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 50)
        livesLabel.zPosition = 1000
        addChild(livesLabel)
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
            print("🎯 Botão pressionado!")

            guard let button = childNode(withName: "sabotageButton") as? SKSpriteNode else { return }

            // Se estiver em cooldown, ignora
            if button.userData?["isDisabled"] as? Bool == true {
                print("⏳ Esperando cooldown...")
                return
            }
            let encoder = SabotageEncoder(peerName: AttGameViewModel.shared.PlayerName)
            onPlayerMove?(encoder, .sabotage, nil)

            // Marca como desabilitado
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
                print("✅ Botão liberado!")
            }

            button.run(SKAction.sequence([countdownAction, enable]))
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

// MARK: Game Mechanics
extension PhaseTwoController: SKPhysicsContactDelegate{
    
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if mask == (UInt32.player | UInt32.tomato) {
            let tomato = (contact.bodyA.node as? TomatoNode) ?? (contact.bodyB.node as? TomatoNode)
            if let tomato, !tomato.hasContacted {
                tomato.hasContacted = true
                print("🍅 Tomate acertou o player!")
                self.splashSauce()
            }
        }
    }
    
    
    func startWind() {
        let windCycle = SKAction.sequence([
            // 🔸 Ativa vento por 3 segundos
            SKAction.run { [weak self] in
                self?.randomizeWindForce()
            },
            SKAction.wait(forDuration: 3.0),

            // 🔹 Desativa vento (zera)
            SKAction.run { [weak self] in
                self?.windForce = 0.0000001
                self?.updateWindArrow()
                print("🌬️ Vento zerado")
            },
            SKAction.wait(forDuration: 0.5) // tempo sem vento
        ])

        let windAction = SKAction.repeatForever(windCycle)

        self.run(windAction, withKey: "windTimer")
    }
    
    func randomizeWindForce(){
        let possibleValues =  [0.1, 0.25, 0.35, -0.001, 0.001, -0.1, -0.25, -0.35]
        if let random = possibleValues.randomElement() {
            self.windForce = random
            print("Vento alterado para: \(windForce)")
            updateWindArrow()
        }
    }
    
    func splashSauce() {
        sauceOverlay.removeAllActions()  // cancela fade anterior, se houver
        sauceOverlay.alpha = 1        // intensidade inicial da mancha
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        sauceOverlay.run(fadeOut)
    }
    
    func sauceOverlaySetup(){
        sauceOverlay = SKSpriteNode(color: .red, size: self.size)
        sauceOverlay.alpha = 0
        sauceOverlay.zPosition = 1_000
        sauceOverlay.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//        sauceOverlay.blendMode = .multiplyAlpha
        addChild(sauceOverlay)
    }
    
    @objc func runTomatoRain() {
        tomatoRain()
    }
    
    func spawnTomato(position: CGPoint){
        
        let randomX = position.x + CGFloat.random(in: -50...50)
        let randomY = position.y + CGFloat.random(in: 80...200)
        let spawnPos = CGPoint(x: randomX, y: randomY)
        
        let randomAngle = CGFloat.random(in: 0.5...1.5) * .pi
        
        let randomScale = CGFloat.random(in: 1...2)
        let targetScale = 0.5 / randomScale
        
        let tomato = TomatoNode(position: spawnPos, scale: randomScale, angle: randomAngle)
        
        addChild(tomato)

        // Animação do tomate
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let moveX = SKAction.moveTo(x: position.x, duration: 0.5)
        let moveY = SKAction.moveTo(y: position.y, duration: 0.5)
        
        let scale = SKAction.scale(to: targetScale, duration: 0.5)
        let rotate = SKAction.rotate(byAngle: randomAngle, duration: 0.5)
        
        let group = SKAction.group([moveX, moveY, scale, rotate])
        
        let enablePhysics = SKAction.run {
            
            let physics = SKPhysicsBody(rectangleOf: tomato.frame.size)
            physics.isDynamic = true
            physics.categoryBitMask = .tomato
            physics.contactTestBitMask = .player
            physics.collisionBitMask = 0
            physics.affectedByGravity = false
            
            tomato.physicsBody = physics
        }
        let sequence = SKAction.sequence([group, enablePhysics, fadeOut, remove])
        tomato.run(sequence)
    }
    
    func tomatoRain() {
        let tomatoCount = 5

        var actions: [SKAction] = []

        for _ in 0..<tomatoCount {
            let randomX = CGFloat.random(in: -88...91)
            let randomY = CGFloat.random(in: -160...0)
            let spawnPosition = CGPoint(x: randomX, y: randomY)

            let spawn = SKAction.run { [weak self] in
                self?.spawnTomato(position: spawnPosition)
            }

            let wait = SKAction.wait(forDuration: Double.random(in: 0.2...0.8))

            actions.append(spawn)
            actions.append(wait)
        }

        let sequence = SKAction.sequence(actions)
        self.run(sequence, withKey: "tomatoRain")
    }
}


// MARK: Player Movement
    extension PhaseTwoController{
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
    }

// MARK: - Usefull Functions
extension PhaseTwoController{
    func setupPlayer(){
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
    
    // MARK: - Game Over/Death Placeholder
    
    
}

extension PhaseTwoController {
    func playerDied() {
        
        print("Morreu")
//        // Pausa o jogo
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
    
    func updateWindArrow() {
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
