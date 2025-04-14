//
//  GuestViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import Foundation
import MultipeerConnectivity

class GuestViewModel: ObservableObject {
    // MCPeerID(displayName: "Rafael"), MCPeerID(displayName: "Carlos"), MCPeerID(displayName: "AAAA"), MCPeerID(displayName: "Paula")
    @Published var availableRooms: [MCPeerID] = []
    @Published var isConnected: Bool = false
    
    @Published var startGame: Bool = false
    
    @Published var gameSessionID: UUID?
    
    @Published var startDelay: Bool = false
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        self.gameSessionID = UUID()
        setupBindings()
    }
}

extension GuestViewModel: P2PMessaging {
    
    func send<T>(_ message: T, type: MessageType, peer: MCPeerID? = nil) where T : Decodable, T : Encodable {
        
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        guard let header = try? JSONDecoder().decode(MessageEnvelopeHeader.self, from: data) else {
            print("❌ Falha ao decodificar cabeçalho do envelope")
            return
        }
        
        switch header.type {
        case .startGame:
            DispatchQueue.main.async {
                PhaseOneController.didShowCountdownOnce = false
                self.startGame = true
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
    
    func cancelInvite(peer: MCPeerID){
        startDelay = true
    }
    
    @MainActor
    func disconnect(){
        connectionManager.disconnect()
    }
}
