//
//  HostViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI
import MultipeerConnectivity

struct inviteModel{
    var peerID: MCPeerID

}

class HostViewModel: ObservableObject {
    
    @Published var recievedInvite: Bool = false
    @Published var recievedInviteFrom: MCPeerID?
    @Published var isConnected: Bool = false
    
    @Published var goToGame: Bool = false
    @Published var connectedPlayers: [MCPeerID] = []
    
    @Published var startGame: Bool = false
    
    var connectionManager: MPCManager
    
    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        connectionManager.onDisconnectPeer = disconnectedPeer
        setupBindings()
    }
}

extension HostViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        
    }
    
    func sendMessage() {
        let message = StartGameEncoder(peerName: connectionManager.myPeerId.displayName)
        connectionManager.send(message: message)
        self.startGame = true
    }
}

extension HostViewModel {
    func startAdvertising() {
        connectionManager.startAdvertising()
    }
}

extension HostViewModel {
    
    func disconnectedPeer(peer: MCPeerID){
        connectedPlayers.count > 0 ? connectedPlayers.removeAll(where: { $0 == peer }) : ()
    }
    
    func disconnect(){
        connectionManager.disconnect()
    }
    
    func onAppear() {
        startAdvertising()
    }
    
    func setupBindings(){
        connectionManager.$receivedInvite.assign(to: &$recievedInvite)
        connectionManager.$recievedInviteFrom.assign(to: &$recievedInviteFrom)
        connectionManager.$paired.assign(to: &$isConnected)
    }
    
    func acceptInvitation() {
        if let handler = connectionManager.invitationHandler {
            handler(true, connectionManager.session)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.startAdvertising()
            }
            
            if connectedPlayers.isEmpty {
                self.isConnected = true
            }
            
            self.connectedPlayers.append(recievedInviteFrom!)
        }
    }
    
    func rejectInvitation() {
        if let handler = connectionManager.invitationHandler {
            handler(false, nil)
        }
    }
}
