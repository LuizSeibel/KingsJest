//
//  GameHelpers.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/05/25.
//

import SpriteKit


class GameHelpers{
    static func applyNearestFiltering(node: SKNode) {
        if let sprite = node as? SKSpriteNode {
            sprite.texture?.filteringMode = .nearest
        }
        
        for child in node.children {
            applyNearestFiltering(node: child) // Aplica recursivamente para todos os filhos
        }
    }
}
