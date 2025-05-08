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
    
    @Published var players: [PlayerIdentifier] = []
    
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
        randomizeColor()
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
    
    func sendPlayersToAll(){
        let data = returnPlayersIdentifier(players: players)
        let message = LobbyPlayersEncoder(peerName: connectionManager.myPeerId.displayName, players: data)
        send(message, type: .players)
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
            players.removeAll { $0.peerName == peer.displayName }
        }
        sendPlayersToAll()
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
        
        randomizeColor()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            self.sendPlayersToAll()
        }
    }
    
    func declineInvitation(peerID: MCPeerID) {
        connectionManager.declineInvitation(for: peerID)
    }
    
    func removeExpiredInvites() {
        connectionManager.removeExpiredInvitations()
    }
}

// MARK: Helpers
extension HostViewModel{
    func returnPlayersIdentifier(players: [PlayerIdentifier]) -> [PlayerIdentifier]{
        var data: [PlayerIdentifier] = []
        for player in players{
            let x = PlayerIdentifier(peerName: player.peerName, color: player.color)
            data.append(x)
        }
        return data
    }
    
    func randomizeColor() {
        var usedColors = Set(players.map { $0.color })
        var availableColors = ourColors.allCases.filter { $0 != .none && !usedColors.contains($0) }

        for peer in connectedPlayers {
            guard !players.contains(where: { $0.peerName == peer.displayName }) else { continue }

            if availableColors.isEmpty {
                availableColors = ourColors.allCases.filter { $0 != .none }
                usedColors.removeAll()
            }

            guard let color = availableColors.randomElement() else { continue }
            usedColors.insert(color)
            availableColors.removeAll { $0 == color }

            let newPlayer = PlayerIdentifier(peerName: peer.displayName, color: color)
            players.append(newPlayer)
        }
    }
}
