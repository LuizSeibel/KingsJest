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
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
    }
    
}

extension GameViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        //
    }
    
    func sendMessage() {
        //
    }
}

extension GameViewModel {
    func disconnectRoom() {
        connectionManager.disconnect()
    }
}
