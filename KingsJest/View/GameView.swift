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
            Text("GameView")
        }
        .navigationDestination(isPresented: $viewModel.isFinishedGame, destination: {
            EndView()
        })
    }
}

#Preview {
    GameView(connectionManager: MPCManager(yourName: "Hi"))
}
