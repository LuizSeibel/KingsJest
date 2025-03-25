//
//  Player.swift
//  KingsJest
//
//  Created by Willys Oliveira on 25/03/25.
//

import SpriteKit
import GameplayKit

class Player: SKSpriteNode {
    
    var stateMachine: GKStateMachine!
    
    var idleFrames: [SKTexture] = []
    var runFrames: [SKTexture] = []
    var jumpFrames: [SKTexture] = []
    var deathFrames: [SKTexture] = []
    
    var isJumping: Bool = false
    
    init(texture: SKTexture) {
        super.init(texture: texture, color: .clear, size: texture.size())
        
        setupPhysics()
        loadAnimations()
        
        stateMachine = GKStateMachine(states: [
            IdleState(player: self),
            RunState(player: self),
            JumpState(player: self),
            DeadState(player: self)
        ])
        stateMachine.enter(IdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Fisicas do Player
    func setupPhysics() {
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.size)
        self.physicsBody?.affectedByGravity = true
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.collisionBitMask = 2
        self.physicsBody?.contactTestBitMask = 4
    }
    
    //MARK: Animações do Player
    func loadAnimations() {
        idleFrames = loadFrames(prefix: "idle00", count: 7)
        runFrames = loadFrames(prefix: "run00", count: 8)
        jumpFrames = loadFrames(prefix: "jump00", count: 12)
        deathFrames = loadFrames(prefix: "dead00", count: 7)
    }
    
    func loadFrames(prefix: String, count: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        
        for i in 1...count {
            frames.append(SKTexture(imageNamed: "\(prefix)\(i))"))
        }
        return frames
    }
    
    //MARK: Animações de cada Estado do Player
    func startIdleAnimation() {
        self.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.1)), withKey: "idle")
    }
    
    func startRunAnimation() {
        self.run(SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.1)), withKey: "run")
    }
    
    func startJumpAnimation() {
        self.run(SKAction.animate(with: jumpFrames, timePerFrame: 0.1), withKey: "jump")
    }
    
    func startDeadAnimation() {
        self.run(SKAction.animate(with: deathFrames, timePerFrame: 0.1), withKey: "dead")
        self.physicsBody = nil
    }
    
    //MARK: Movimentação do Player com CoreMotion
    func move(xAcceleration: CGFloat) {
        let maxSpeed: CGFloat = 300
        let sensitivity: CGFloat = 600
        let newVelocity = xAcceleration * sensitivity
        self.physicsBody?.velocity.dx = max(min(newVelocity, maxSpeed), -maxSpeed)
        
        if abs(newVelocity) > 50 {
            stateMachine.enter(RunState.self)
        } else {
            stateMachine.enter(IdleState.self)
        }
    }
    
    //MARK: Pulo do Player
    func jump() {
        if !isJumping {
            isJumping = true
            self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
            stateMachine.enter(JumpState.self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isJumping = false
                self.stateMachine.enter(IdleState.self)
            }
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
                self.player.scene?.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 2))
            }
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return false
    }
}
