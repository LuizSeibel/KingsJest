//
//  GameScene.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI

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
        
    override func didMove(to view: SKView) {
        applyNearestFiltering(node: self)
        
        player = self.childNode(withName: "player") as? SKSpriteNode
        
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
                
        player.run(.repeatForever(SKAction.animate(with: spriteSheet, timePerFrame: 0.1)))
        
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
