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
        gameViewBody()
    }
    
    private func gameViewBody() -> some View {
        ZStack {
            GameScenesViewControllerRepresentable(sceneType: .phaseOne, finishGame: {
                withAnimation(.easeIn(duration: 0.5)) {
                    showBlackout = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    viewModel.finishGame()
                }
                
            }, onPlayerMove: { snapshot in
                viewModel.send(snapshot, type: .position)
            })
            .edgesIgnoringSafeArea(.all)

            if showBlackout {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            showBlackout = false
            viewModel.onAppear()
            viewModel.iniciarGravação()
        }
        
        .navigationDestination(isPresented: $viewModel.isFinishedGame, destination: {
            if viewModel.isFinishedGame {
                EndView(winBool: viewModel.winGame)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            viewModel.disconnectRoom()
                        })
                    }
            }
            else{
                EmptyView()
            }
            
            
        })
        
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    GameView(connectionManager: MPCManager(yourName: ""))
}
