//
//  Player.swift
//  KingsJest
//
//  Created by Willys Oliveira on 25/03/25.
//

import SpriteKit
import GameplayKit

class Player {
    
    let node: SKSpriteNode!
    
    var stateMachine: GKStateMachine!
    
    // Movement Var
    var currentVelocityX: CGFloat = 0.0
    
    lazy var idleFrames: [SKTexture] = {
        return loadFrames(prefix: "idle00", count: 7)
    }()
    lazy var runFrames: [SKTexture] = {
        loadFrames(prefix: "RUN00", count: 8)
    }()
    lazy var jumpFrames: [SKTexture] = {
        loadFrames(prefix: "jump00", count: 5)
    }()
    lazy var deathFrames: [SKTexture] = {
        loadFrames(prefix: "death00", count: 12)
    }()
    
    
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
    
    init(texture: SKTexture, position: CGPoint) {
        
        node = SKSpriteNode(texture: texture)
        node.position = position
        
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
        self.node.physicsBody = SKPhysicsBody(texture: self.node.texture!, size: self.node.size)
        self.node.physicsBody?.affectedByGravity = true
        self.node.physicsBody?.isDynamic = true
        self.node.physicsBody?.allowsRotation = false
        self.node.physicsBody?.categoryBitMask = .player
        self.node.physicsBody?.contactTestBitMask = 2
        self.node.physicsBody?.collisionBitMask = 4
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
        self.node.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.1)), withKey: "idle")
    }
    
    func startRunAnimation() {
        self.node.run(SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.1)), withKey: "run")
    }
    
    func startJumpAnimation() {
        self.node.run(SKAction.animate(with: jumpFrames, timePerFrame: 0.1), withKey: "jump")
    }
    
    func startDeadAnimation() {
            self.node.physicsBody = nil
            self.node.removeAllActions() // Remove todas as animações anteriores

            let deathAnimation = SKAction.animate(with: deathFrames, timePerFrame: 0.2)
            let holdLastFrame = SKAction.run {
                self.node.texture = self.deathFrames.last // Mantém o último frame
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
    // Movimentação do Player com CoreMotion
    func move(xAcceleration: CGFloat, deltaTime: CGFloat) {
        let maxSpeed: CGFloat = 100
        
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
            // Zera a velocidade vertical para um início consistente.
            self.node.physicsBody?.velocity.dy = 0
            // Impulso inicial (pode ajustar o valor para seu "feeling")
            self.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 10))
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
    
    func updateJumpState() {
        // Verifica se a velocidade vertical está próxima de zero (ou seja, está no chão)
        if let dy = node.physicsBody?.velocity.dy, abs(dy) < 0.1 {
            isJumping = false
            isJumpButtonHeld = false
            jumpTime = 0
        }
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
        print("☠️ DeadState ativado!")
        player.startDeadAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if let scene = SKScene(fileNamed: "PhaseOne") {
                print("🔄 Reiniciando a fase...")
                scene.scaleMode = .resizeFill
                self.player.node.scene?.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2))
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}


extension UInt32 {
    static var player:UInt32 { 0x1 >> 0 }
    static var flag:UInt32 { 0x1 >> 1 }
    static var ground:UInt32 { 0x1 >> 2 }
}
