//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI

@MainActor var spriteView : PhaseOne?

struct ContentView: View {
    var body: some View {
        VStack {
            GeometryReader { geo in
                SpriteView(scene: scene(size: geo.size))
                    .ignoresSafeArea()
            }
        }
    }
    
    func scene(size: CGSize) -> SKScene {
        spriteView = PhaseOne(size: size)
        spriteView?.size = size
        
        return spriteView!
    }
}
