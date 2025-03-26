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
        loadFrames(prefix: "dead00", count: 12)
    }()
    
    var isJumping: Bool = false
    
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
        self.node.physicsBody?.categoryBitMask = 1
        self.node.physicsBody?.collisionBitMask = 2
        self.node.physicsBody?.contactTestBitMask = 4
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
        self.node.run(SKAction.animate(with: deathFrames, timePerFrame: 0.1), withKey: "dead")
        self.node.physicsBody = nil
    }
    
    //MARK: Movimentação do Player com CoreMotion
    func move(xAcceleration: CGFloat) {
        let maxSpeed: CGFloat = 300
        let sensitivity: CGFloat = 600
        let newVelocity = xAcceleration * sensitivity
        self.node.physicsBody?.velocity.dx = max(min(newVelocity, maxSpeed), -maxSpeed)
        
        // Verifica a direção do movimento e espelha o sprite
        if newVelocity < 0 {
            self.node.xScale = -1.0 // Inverte a imagem do personagem (para a esquerda)
        } else if newVelocity > 0 {
            self.node.xScale = 1.0 // Restaura a imagem do personagem (para a direita)
        }

        if !isJumping{
            if abs(newVelocity) > 50 {
                stateMachine.enter(RunState.self)
            } else {
                stateMachine.enter(IdleState.self)
            }
        }
    }
    
    //MARK: Pulo do Player
    func jump() {
        
        if !isJumping {
            isJumping = true
            self.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 8))
            stateMachine.enter(JumpState.self)
        }
    }
    
    func endJump() {
        if self.isJumping {
            self.isJumping = false
        }
    }
    
    func die() {
        stateMachine.enter(DeadState.self)
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
        return stateClass == RunState.self || stateClass == JumpState.self
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
        return stateClass == IdleState.self || stateClass == JumpState.self
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
        return stateClass == IdleState.self || stateClass == RunState.self
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let scene = SKScene(fileNamed: "PhaseOne") {
                scene.scaleMode = .resizeFill
                self.player.node.scene?.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2))
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
