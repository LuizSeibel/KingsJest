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
    
    var scaleMode: SKSceneScaleMode {
        switch self {
        case .phaseOne:
            return .resizeFill
        case .phaseTwo:
            return .aspectFill
        }
    }

    func getScene(finishGame: (() -> Void)? = nil, onPlayerMove: ((MPCEncoder) -> Void)? = nil) -> SKScene? {
        switch self {
        case .phaseOne:
            let scene = PhaseOneController(fileNamed: self.rawValue)
            scene?.scaleMode = self.scaleMode
            scene?.finishGame = finishGame
            scene?.onPlayerMove = onPlayerMove
            return scene
        case .phaseTwo:
            let scene = PhaseTwoController(fileNamed: self.rawValue)
            scene?.scaleMode = self.scaleMode
            return scene
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
        
        if let scene = sceneType.getScene(
            finishGame: finishGame,
            onPlayerMove: onPlayerMove
        ) {
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
