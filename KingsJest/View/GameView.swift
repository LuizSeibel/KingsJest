//
//  GameView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct GameView: View {
    
    @StateObject private var viewModel: GameViewModel
    
    @State private var showBlackout = false
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: GameViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        ZStack{
            GameScenesViewControllerRepresentable(sceneType: .phaseOne, finishGame: {
                withAnimation(.easeIn(duration: 0.5)) {
                    showBlackout = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    viewModel.finishGame()
                    viewModel.disconnectRoom()
                }
            })
                .edgesIgnoringSafeArea(.all)
            if showBlackout {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity) // animação de fade-in
            }
        }
        
        .navigationDestination(isPresented: $viewModel.isFinishedGame, destination: {
            EndView(winBool: viewModel.winGame)
        })
    }
}

#Preview {
    GameView(connectionManager: MPCManager(yourName: ""))
}

