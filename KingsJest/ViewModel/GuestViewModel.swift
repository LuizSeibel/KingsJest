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
    
    @Published var roomPlayers: [PlayerIdentifier] = []
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        self.gameSessionID = UUID()
        setupBindings()
        
        // Adiciono o player como o primeiro da lista
        let user = PlayerIdentifier(peerName: connectionManager.myPeerId.displayName, color: .none)
        roomPlayers.append(user)
    }
}

extension GuestViewModel: P2PMessaging {
    
    func send<T>(_ message: T, type: MessageType, peer: MCPeerID? = nil) where T : Decodable, T : Encodable {
        
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        do{
            guard let header = try? JSONDecoder().decode(MessageEnvelopeHeader.self, from: data) else {
                print("❌ Falha ao decodificar cabeçalho do envelope")
                return
            }
            
            switch header.type {
            case .startGame:
                DispatchQueue.main.async {
                    self.startGame = true
                }
                
            case .players:
                let envelope = try JSONDecoder().decode(
                    MessageEnvelope<LobbyPlayersEncoder>.self,
                    from: data
                )
                let playersArray = envelope.content.players
                DispatchQueue.main.async {
                    self.updatePlayers(players: playersArray)
                }
                
            default:
                break
                
            }
        } catch{
            print("❌ Falha ao decodificar envelope: \(error)")
        }
    }
    
}

extension GuestViewModel{
    @MainActor
    func updatePlayers(players: [PlayerIdentifier]) {
        
        if !roomPlayers.isEmpty {
            let name = roomPlayers[0].peerName
            if let new = players.first(where: { $0.peerName == name }) {
                roomPlayers[0].color = new.color
                print(roomPlayers[0].color)
            }
        }
        
        for player in players {
            if !roomPlayers.contains(player) {
                roomPlayers.append(player)
            }
        }

        roomPlayers.removeAll { localPlayer in
            !players.contains(localPlayer)
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
