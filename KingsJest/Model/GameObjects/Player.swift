//
//  Player.swift
//  KingsJest
//
//  Created by Willys Oliveira on 25/03/25.
//

import SpriteKit
import GameplayKit

extension UInt32 {
    static let player: UInt32 = 0x1 << 0
    static let plataform: UInt32 = 0x1 << 1
    static let lava: UInt32 = 0x1 << 2
    static let trigger: UInt32 = 0x1 << 3
    static let flag: UInt32 = 0x1 << 4
    static let ground: UInt32 = 0x1 << 5
}


class Player {
    
    let node: SKSpriteNode!
    
    var stateMachine: GKStateMachine!
    
    // Movement Var
    var currentVelocityX: CGFloat = 0.0
    
    lazy var idleFrames: [SKTexture] = {
        return loadFrames(prefix: "RUN00", count: 7)
    }()
    lazy var runFrames: [SKTexture] = {
        loadFrames(prefix: "RUN00", count: 7)
    }()
    lazy var jumpFrames: [SKTexture] = {
        loadFrames(prefix: "RUN00", count: 7)
    }()
    lazy var deathFrames: [SKTexture] = {
        loadFrames(prefix: "RUN00", count: 7)
    }()
    
    var isInDynamicPlataform: SKSpriteNode? = nil

    
    // Jump vars
    var isJumping: Bool = false
    var isJumpButtonHeld = false
    var jumpTime: CGFloat = 0
    let maxJumpTime: CGFloat = 0.3  // segundos até atingir altura máxima
    let jumpForcePerFrame: CGFloat = 10
    
    // Jump Buffer
    var jumpBufferCounter: CGFloat = 0
    let jumpBufferDuration: CGFloat = 0.1
    
    // Coyote Time Properties
    var coyoteTimeCounter: CGFloat = 0
    let coyoteTimeDuration: CGFloat = 0.1
    
    // Som dos Passos Vars
    var stepSoundCooldown: TimeInterval = 0
    let stepSoundInterval: TimeInterval = 0.4 // tempo entre passos (em segundos)
    
    // Variavel de controle para Efeito sonoro de queda
    var hasPlayedLandingSound = false
    var previousDY: CGFloat = 0
    let minimumFallSpeedToPlaySound: CGFloat = -100
    
    
    init(texture: SKTexture, position: CGPoint, size: CGSize) {
        
        node = SKSpriteNode(texture: texture)
        node.position = position
        node.size = size
        self.node.color = .green
        self.node.alpha = 1
        self.node.colorBlendFactor = 1

        setupPhysics()
        
        stateMachine = GKStateMachine(states: [
            IdleState(player: self),
            RunState(player: self),
            JumpState(player: self),
            DeadState(player: self)
        ])
        stateMachine.enter(IdleState.self)
        
    }
    
    //MARK: Fisicas do Player
    func setupPhysics() {
        // Ajustes
        let rectWidth: CGFloat = 35
        let rectHeight: CGFloat = 45
        let circleRadius: CGFloat = 18

        let baseRectCenterY = circleRadius / 2
        let heightDiff = 60 - rectHeight
        let adjustedRectCenterY = baseRectCenterY - (heightDiff / 2)

        let circleCenterY = baseRectCenterY - (60 / 2)

        let rectBody = SKPhysicsBody(rectangleOf: CGSize(width: rectWidth, height: rectHeight),
                                     center: CGPoint(x: 0, y: adjustedRectCenterY))

        let footCircle = SKPhysicsBody(circleOfRadius: circleRadius,
                                       center: CGPoint(x: 0, y: circleCenterY))

        self.node.physicsBody = SKPhysicsBody(bodies: [rectBody, footCircle])
        self.node.physicsBody?.affectedByGravity = true
        self.node.physicsBody?.isDynamic = true
        self.node.physicsBody?.allowsRotation = false
        self.node.physicsBody?.restitution = 0
        self.node.physicsBody?.friction = 0
        self.node.physicsBody?.categoryBitMask = .player
        self.node.physicsBody?.contactTestBitMask = .plataform | .lava
        self.node.physicsBody?.collisionBitMask = .plataform | .ground
    }
    
    //MARK: Animações do Player
    func loadFrames(prefix: String, count: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        
        for i in 0..<count {
            let texture = SKTexture(imageNamed: "\(prefix)\(i)")
            texture.filteringMode = .nearest
            
            frames.append(texture)
        }
        
        return frames
    }
    
    //MARK: Animações de cada Estado do Player
    func startIdleAnimation() {
        self.node.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.06)), withKey: "idle")
    }
    
    func startRunAnimation() {
        self.node.run(SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.06)), withKey: "run")
    }
    
    func startJumpAnimation() {
        self.node.run(SKAction.animate(with: jumpFrames, timePerFrame: 0.1), withKey: "jump")
    }
    
    func startDeadAnimation() {
//        self.node.scene?.run(SKAction.playSoundFileNamed("deathEffect.wav", waitForCompletion: false))
        
        AudioManager.shared.playSound(named: "deathEffect.wav", on: self.node.scene!, waitForCompletion: false)
        
        self.node.physicsBody = nil
        self.node.removeAllActions()

        let deathAnimation = SKAction.animate(with: deathFrames, timePerFrame: 0.1)
        let holdLastFrame = SKAction.run {
            self.node.texture = self.deathFrames.last
        }

        let sequence = SKAction.sequence([deathAnimation, holdLastFrame])
        self.node.run(sequence, withKey: "dead")
    }

    
    func die() {
        stateMachine.enter(DeadState.self)
    }
}

// MARK: - Movement Mechanics
extension Player {
    
    func getPosition() -> CGPoint {
        return self.node.position
    }
    
//    func getPosition() -> (Float, Float) {
//        return (Float(self.node.position.x), Float(self.node.position.y))
//    }
    
    // Movimentação do Player com CoreMotion
    func move(xAcceleration: CGFloat, deltaTime: CGFloat) {
        let maxSpeed: CGFloat = 300
        
        let accelerationRate: CGFloat = 800
        let decelerationRate: CGFloat = 2200
        
        if xAcceleration != 0 {
            // Aceleração suave
            let targetVelocity = xAcceleration * maxSpeed
            let velocityDiff = targetVelocity - currentVelocityX
            let accelerationStep = accelerationRate * deltaTime
            currentVelocityX += min(max(velocityDiff, -accelerationStep), accelerationStep)
        }
        else {
            // Desaceleração suave
            let deceletarationStep = decelerationRate * deltaTime
            
            if currentVelocityX > 0 {
                currentVelocityX = max(0, currentVelocityX - deceletarationStep)
            }
            else if currentVelocityX < 0{
                currentVelocityX = min(0, currentVelocityX + deceletarationStep)
            }
        }
        
        currentVelocityX = max(-maxSpeed, min(maxSpeed, currentVelocityX))
        self.node.physicsBody?.velocity.dx = currentVelocityX
        
        // Verifica a direção do movimento e espelha o sprite
        if currentVelocityX < -10 {
            self.node.xScale = -1.0
        } else if currentVelocityX > 10 {
            self.node.xScale = 1.0
        }

        if !isJumping{
            if abs(currentVelocityX) > 50 {
                stateMachine.enter(RunState.self)
            } else {
                stateMachine.enter(IdleState.self)
            }
        }
    }
    
    //MARK: Pulo do Player
    func jump() {
        // Certifique-se de que só inicia o pulo se estiver no chão.
        if !isJumping {
            isJumping = true
            isJumpButtonHeld = true
            jumpTime = 0
            
            // Toca som de pulo
            AudioManager.shared.playSound(named: "puloEffect.wav", on: self.node, waitForCompletion: false)
            

            // Zera a velocidade vertical para um início consistente.
            self.node.physicsBody?.velocity.dy = 0
            // Impulso inicial (pode ajustar o valor para seu "feeling")
            self.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 65))
            stateMachine.enter(JumpState.self)
        }
    }
    
    func endJump() {
        // Quando o jogador solta o botão, encerra a extensão do pulo
        isJumpButtonHeld = false
    }
    
    func continueJump(deltaTime: CGFloat) {
        // Só aplica força se o botão ainda estiver pressionado e o tempo de pulo não tiver ultrapassado o máximo
        if isJumping && isJumpButtonHeld && jumpTime < maxJumpTime {
            self.node.physicsBody?.applyForce(CGVector(dx: 0, dy: jumpForcePerFrame))
            jumpTime += deltaTime
        }
    }
    
    func bufferJump() {
        jumpBufferCounter = jumpBufferDuration
    }
    
    //TODO: Efeito sonoro de queda está errado, ajustar depois!
    func updateJumpState() {
        guard let dy = node.physicsBody?.velocity.dy else { return }

        // Detectar aterrissagem após uma queda "real"
        if dy == 0 || (dy < 0 && previousDY < 0 && abs(dy) < 0.1) {
            if !hasPlayedLandingSound && previousDY <= minimumFallSpeedToPlaySound {
                AudioManager.shared.playSound(named: "quedasEffect.wav", on: self.node, waitForCompletion: false)
                
                hasPlayedLandingSound = true
            }
            
            isJumping = false
            isJumpButtonHeld = false
            jumpTime = 0
        } else {
            hasPlayedLandingSound = false
        }

        previousDY = dy

    }

    
    func updateCoyoteTime(deltaTime: CGFloat) {
        // Defina um threshold para considerar que o personagem está no chão
        let verticalThreshold: CGFloat = 1.0
        if let body = self.node.physicsBody, abs(body.velocity.dy) < verticalThreshold {
            // Personagem no chão: reseta o contador
            coyoteTimeCounter = coyoteTimeDuration
        } else {
            // Personagem no ar: decai o contador
            coyoteTimeCounter = max(0, coyoteTimeCounter - deltaTime)
        }
    }
    
    func updateJumpBuffer(deltaTime: CGFloat) {
        // Diminui o contador do buffer, se estiver ativo
        if jumpBufferCounter > 0 {
            jumpBufferCounter = max(0, jumpBufferCounter - deltaTime)
        }
        
        // Se houver um input armazenado e o personagem estiver no chão ou dentro do coyote time, dispara o pulo
        if jumpBufferCounter > 0 && coyoteTimeCounter > 0 && !isJumping {
            jump()
            jumpBufferCounter = 0  // reseta o buffer após pular
        }
    }
}


// MARK: - Player se move com a plataforma dinamica
extension Player {
    func syncWithMovingPlatform(deltaTime: TimeInterval) {
        guard let plataforma = isInDynamicPlataform else { return }

        if plataforma.userData == nil {
            plataforma.userData = NSMutableDictionary()
        }

        let previousPosition = plataforma.userData?["previousPosition"] as? CGPoint ?? plataforma.position
        let currentPosition = plataforma.position

        let deltaX = currentPosition.x - previousPosition.x
        let deltaY = currentPosition.y - previousPosition.y

        // Limita o quanto o movimento pode afetar o player
        let maxDelta: CGFloat = 20.0
        let clampedDeltaX = max(-maxDelta, min(deltaX, maxDelta))
        let clampedDeltaY = max(-maxDelta, min(deltaY, maxDelta))

        // Aplica deltaX normalmente
        node.position.x += clampedDeltaX

        // 🔐 Bloqueia Y somente se o player está com velocidade baixa (em cima da plataforma)
        if let velocityY = node.physicsBody?.velocity.dy, abs(velocityY) < 10 {
            node.position.y += clampedDeltaY
            // Resetar velocidade vertical para evitar impulso extra
            node.physicsBody?.velocity.dy = 0
        }

        plataforma.userData?["previousPosition"] = currentPosition
    }

}

// MARK: - Efeito sonoro do player
extension Player {
    func playStepSound(currentTime: TimeInterval) {
        if currentTime > stepSoundCooldown {
            AudioManager.shared.playSound(named: "passosEffect.wav", on: node)
            stepSoundCooldown = currentTime + stepSoundInterval
        }
    }
}

//MARK: - PlayerStates
class IdleState: GKState {
    unowned let player: Player
    
    init(player: Player) {
        self.player = player
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        player.startIdleAnimation()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == RunState.self || stateClass == JumpState.self || stateClass == DeadState.self
    }
}

class RunState: GKState {
    unowned let player: Player
    
    init(player: Player) {
        self.player = player
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        player.startRunAnimation()
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // Toca som se estiver realmente correndo (velocidade relevante)
        if abs(player.currentVelocityX) > 50 {
            player.playStepSound(currentTime: seconds)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self || stateClass == JumpState.self || stateClass == DeadState.self

    }
}

class JumpState: GKState {
    unowned let player: Player
    
    init(player: Player) {
        self.player = player
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        player.startJumpAnimation()
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == IdleState.self || stateClass == RunState.self || stateClass == DeadState.self

    }
}

class DeadState: GKState {

    unowned let player: Player
    
    init(player: Player) {
        self.player = player
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        player.startDeadAnimation()

        guard let currentScene = player.node.scene as? PhaseOneController else { return }
        
        // Closure para continuar a referencia
        let oldFinishGame = currentScene.finishGame
        let oldOnPlayerMove = currentScene.onPlayerMove
        
        // Usa para saber se o player morreu na lava final
        let wasOnFinalLava = currentScene.lastLava
        // Usa para pegar a posicao do trigger
        let triggerPos = currentScene.lavaTriggerPosition

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if let newScene = PhaseOneController(fileNamed: "PhaseOne") {
                newScene.scaleMode = .resizeFill
                newScene.finishGame = oldFinishGame
                newScene.onPlayerMove = oldOnPlayerMove
                
                // Variaveis para reiniciar a cena sem o countdown e sem bloquear os controles
                newScene.isGameStarted = true
                newScene.didShowCountdownOnce = true
                
                if wasOnFinalLava, let trigger = triggerPos {
                    let offsetX: CGFloat = -200
                    let offsetY: CGFloat = -140
                    let respawn = CGPoint(x: trigger.x + offsetX, y: trigger.y + offsetY)

                    newScene.respawnPoint = respawn
                }


                currentScene.view?.presentScene(newScene, transition: .fade(withDuration: 0.8))
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}



