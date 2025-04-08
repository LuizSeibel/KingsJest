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
    
    @Published var gameSessionID: UUID?
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        self.gameSessionID = UUID()
        setupBindings()
    }
}

extension GuestViewModel: P2PMessaging {
    
    func send<T>(_ message: T, type: MessageType) where T : Decodable, T : Encodable {
        
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        guard let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) else { return }

        switch envelope.type {
        case .startGame:
            if (try? JSONDecoder().decode(StartGameEncoder.self, from: envelope.payload)) != nil {
                DispatchQueue.main.async {
                    PhaseOneController.didShowCountdownOnce = false
                    self.startGame = true
                }
            }
        default:
            break
        }
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
