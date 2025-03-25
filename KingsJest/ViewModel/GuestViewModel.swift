//
//  GuestViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import Foundation
import MultipeerConnectivity

class GuestViewModel: ObservableObject {
    
    @Published var availableRooms: [MCPeerID] = []
    @Published var isConnected: Bool = false
    
    @Published var startGame: Bool = false
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        setupBindings()
    }
}

extension GuestViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        if (try? JSONDecoder().decode(StartGameEncoder.self, from: data)) != nil {
            DispatchQueue.main.async {
                self.startGame = true
            }
        }
    }
    
    func sendMessage() {
        
    }
}

extension GuestViewModel {
    private func setupBindings() {
        connectionManager.$nearbyPeers.assign(to: &$availableRooms)
        connectionManager.$paired.assign(to: &$isConnected)
    }
    
    func onAppear(){
        connectionManager.startBrowsing()
    }
    
    func sendInvite(peer: MCPeerID){
        connectionManager.invite(peer: peer)
    }
    
    func disconnect(){
        connectionManager.disconnect()
    }
}

