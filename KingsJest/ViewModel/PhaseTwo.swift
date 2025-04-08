//
//  PhaseTwo.swift
//  KingsJest
//
//  Created by Luiz Seibel on 08/04/25.
//

import SpriteKit

// SKPhysicsContactDelegate
class PhaseTwoController: SKScene{
    
    var player: Player!
    
    override func didMove(to view: SKView) {
        
        setupPlayer()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Chamado antes de cada frame ser renderizado
    }
}

// MARK: - Touches Controller
extension PhaseTwoController {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Trata o toque inicial na tela
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

// MARK: - Usefull Functions
extension PhaseTwoController{
    func setupPlayer(){
        if let scenePlayerNode = self.childNode(withName: "player") {
            let texture = SKTexture(imageNamed: "RUN000")
            player = Player(texture: texture, position: scenePlayerNode.position)
            scenePlayerNode.removeFromParent()
            player.node.zPosition = 4
            addChild(player.node)
        }
    }
    
    
}
