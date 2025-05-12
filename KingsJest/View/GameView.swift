//
//  GameView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var appViewModel: RootViewModel
    @StateObject private var viewModel: GameViewModel
    
    @State private var showBlackout = false
    
    init(connectionManager: MPCManager, players: [PlayerIdentifier]){
        _viewModel = StateObject(wrappedValue: GameViewModel(connectionManager: connectionManager, players: players))
    }
    
    var body: some View {
        gameViewBody()
    }
    
    private func gameViewBody() -> some View {
        ZStack {
            if !viewModel.isFinishedGame {
                GameScenesViewControllerRepresentable(sceneType: .phaseOne, finishGame: {
                    withAnimation(.easeIn(duration: 0.5)) {
                        showBlackout = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        viewModel.finishGame()
                    }
                    
                }, onPlayerMove: { snapshot in
                    viewModel.send(snapshot, type: .position, peer: nil)
                })
                .edgesIgnoringSafeArea(.all)
            }
            
            if showBlackout {
                Color.black
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            showBlackout = false
            viewModel.onAppear()
        }
        
        .onChange(of: viewModel.isFinishedGame){ value in
            if value{
                appViewModel.path.append(.end(win: viewModel.winGame, winnerName: viewModel.winnerName ?? ""))
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    viewModel.disconnectRoom()
                })
            }
        }
        
        
//        .navigationDestination(isPresented: $viewModel.isFinishedGame, destination: {
//            if viewModel.isFinishedGame {
//                EndView(winBool: viewModel.winGame, winnerName: viewModel.winnerName ?? "")
//                    .onAppear{
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                            viewModel.disconnectRoom()
//                        })
//                    }
//            }
//            else{
//                EmptyView()
//            }
//            
//            
//        })
        
        .navigationBarBackButtonHidden(true)
    }
}
//
//#Preview {
//    GameView(connectionManager: MPCManager(yourName: ""), players: <#[PlayerIdentifier]#>)
//}
