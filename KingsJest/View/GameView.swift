//
//  GameView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel: HostViewModel
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: HostViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        GameScenesViewControllerRepresentable(sceneType: .phaseOne)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationDestination(isPresented: $viewModel.goToGame, destination: {
            EndView()
        })
    }

//#Preview {
//    GameView()
//}

