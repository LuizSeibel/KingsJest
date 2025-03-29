//
//  ScenesController.swift
//  KingsJest
//
//  Created by Willys Oliveira on 26/03/25.
//

import SwiftUI
import SpriteKit

//enum GameSceneType: String {
//    case phaseOne = "PhaseOne"
//}

enum GameSceneType: String {
    case phaseOne = "PhaseOne"

    func getScene() -> SKScene? {
        switch self {
        case .phaseOne:
            return PhaseOneController(fileNamed: self.rawValue)
        }
    }
}


struct GameScenesViewControllerRepresentable: UIViewControllerRepresentable {
    
    let sceneType: GameSceneType
    let finishGame: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let skView = SKView(frame: UIScreen.main.bounds)
        viewController.view = skView
        
        if let scene = sceneType.getScene() {
            scene.scaleMode = .resizeFill
            
            (scene as? PhaseOneController)?.finishGame = finishGame
            
            skView.presentScene(scene)
        }

        
//        if let scene = SKScene(fileNamed: sceneType.rawValue) as? PhaseOneController {
//            scene.scaleMode = .resizeFill
//
//            scene.finishGame = finishGame
//
//            skView.presentScene(scene)
//        }
        
        skView.ignoresSiblingOrder = false
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Atualizações futuras, se necessário
    }
}
