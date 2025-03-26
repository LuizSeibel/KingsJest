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
    
    
}

extension GameViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        
    }
    
    func sendMessage() {
        
    }
}
