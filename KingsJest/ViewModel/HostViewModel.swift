//
//  HostViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI
import MultipeerConnectivity

class HostViewModel: ObservableObject {
    @Published var isConnected: Bool = false
    @Published var pendingInvitations: [MCPeerID] = []
    @Published var connectedPlayers: [MCPeerID] = []
    @Published var startGame: Bool = false
    @Published var gameSessionID: UUID?
    @Published var recentlyConnected: Bool = false
    
    var connectionManager: MPCManager
    
    init(connectionManager: MPCManager) {
        self.connectionManager = connectionManager
        connectionManager.onDisconnectPeer = disconnectedPeer
        setupBindings()
        self.gameSessionID = UUID()
        connectedPlayers.append(connectionManager.myPeerId)
    }
}

extension HostViewModel: P2PMessaging {
    func send<T: Codable>(_ message: T, type: MessageType, peer: MCPeerID? = nil) {
        do {
            let envelope = MessageEnvelope(type: type, content: message)
            let finalData = try JSONEncoder().encode(envelope)
            connectionManager.send(data: finalData)
        } catch {
            print("Erro ao enviar mensagem do tipo \(type): \(error)")
        }
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        // Implementar se necessário.
    }
    
    func sendMessage() {
        self.startGame = true
        let message = StartGameEncoder(peerName: connectionManager.myPeerId.displayName)
        send(message, type: .startGame)
    }
}

extension HostViewModel {
    func startRoom(){
        sendMessage()
        // MARK: NAO PARAR O ADVERTISING PESA MUITO A REDE.
        //connectionManager.stopAdvertising()
    }
    
    func startAdvertising() {
        connectionManager.startAdvertising()
    }
}

extension HostViewModel {
    func disconnectedPeer(peer: MCPeerID) {
        if !connectedPlayers.isEmpty {
            connectedPlayers.removeAll(where: { $0 == peer })
        }
    }
    
    @MainActor
    func disconnect() {
        connectionManager.disconnect()
    }
    
    func onAppear() {
        startAdvertising()
    }
    
    func setupBindings() {
        connectionManager.$paired.assign(to: &$isConnected)
        connectionManager.$pendingInvitations
            .map { invitations in
                invitations.map { $0.from }
            }
            .assign(to: &$pendingInvitations)
    }
}

@MainActor
extension HostViewModel {
    func acceptInvitation(peerID: MCPeerID) {
        connectionManager.acceptInvitation(for: peerID)
        connectedPlayers.append(peerID)
        recentlyConnected = true
    }
    
    func declineInvitation(peerID: MCPeerID) {
        connectionManager.declineInvitation(for: peerID)
    }
    
    func removeExpiredInvites() {
        connectionManager.removeExpiredInvitations()
    }
}
