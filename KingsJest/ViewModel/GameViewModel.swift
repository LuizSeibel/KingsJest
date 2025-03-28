//
//  GameViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import Foundation
import MultipeerConnectivity


class GameViewModel: ObservableObject {
    
    @Published var isFinishedGame: Bool = false
    @Published var winnerName: String?
    @Published var winGame: Bool = false
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
    }
    
}

extension GameViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        if (try? JSONDecoder().decode(StopGameEncoder.self, from: data)) != nil {
            DispatchQueue.main.async {
                self.winnerName = peerID.displayName
                self.winGame = false
                self.isFinishedGame = true
            }
        }
    }
    
    func sendMessage() {
        let message = StopGameEncoder(peerName: connectionManager.myPeerId.displayName)
        connectionManager.send(message: message)
    }
}

extension GameViewModel {
    
    func finishGame() {
        print(" - Terminou o jogo!")
        DispatchQueue.main.async{
            self.winnerName = self.connectionManager.myPeerId.displayName
            self.winGame = true
            self.isFinishedGame = true
            self.sendMessage()
        }
    }
    
    func disconnectRoom() {
        connectionManager.disconnect()
    }
}
