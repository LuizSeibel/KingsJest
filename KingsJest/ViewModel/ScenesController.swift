//
//  ScenesController.swift
//  KingsJest
//
//  Created by Willys Oliveira on 26/03/25.
//

import SwiftUI
import SpriteKit

enum GameSceneType: String {
    case phaseOne = "PhaseOne"
    case phaseTwo = "PhaseTwo"

    func getScene() -> SKScene? {
        switch self {
        case .phaseOne:
            return PhaseOneController(fileNamed: self.rawValue)
        case .phaseTwo:
            return PhaseTwoController(fileNamed: self.rawValue)
        }
    }
}


struct GameScenesViewControllerRepresentable: UIViewControllerRepresentable {
    
    let sceneType: GameSceneType
    let finishGame: () -> Void
    let onPlayerMove: (MPCEncoder) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let skView = SKView(frame: UIScreen.main.bounds)
        viewController.view = skView
        
        if let scene = sceneType.getScene() {
            scene.scaleMode = .resizeFill
            
            //TODO: Retirar do codigo
//            skView.showsPhysics = true

            
            (scene as? PhaseOneController)?.finishGame = finishGame
            (scene as? PhaseOneController)?.onPlayerMove = onPlayerMove
            
            skView.presentScene(scene)
        }

        skView.ignoresSiblingOrder = false
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Atualizações futuras, se necessário
    }
}
