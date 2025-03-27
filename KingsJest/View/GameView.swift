//
//  GameView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel: GameViewModel
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: GameViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        VStack{
            GameScenesViewControllerRepresentable(sceneType: .phaseOne)
                .edgesIgnoringSafeArea(.all)
        }
        
        
        // TODO: Antes de ir para a EndView, ele tem que parar o serviço do MPC
        // TODO: Passar a variável de ganhador se ele ganhou
        .navigationDestination(isPresented: $viewModel.isFinishedGame, destination: {
            EndView(winBool: true)
        })
    }
}

#Preview {
    GameView(connectionManager: MPCManager(yourName: ""))
}

