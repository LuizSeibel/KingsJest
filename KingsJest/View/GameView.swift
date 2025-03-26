//
//  GameView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct GameView: View {
    var body: some View {
        GameScenesViewControllerRepresentable(sceneType: .phaseOne)
            .edgesIgnoringSafeArea(.all)
        }
    }

//#Preview {
//    GameView()
//}

