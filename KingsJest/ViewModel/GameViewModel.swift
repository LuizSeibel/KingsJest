//
//  GameViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import Foundation
import MultipeerConnectivity

struct GamePlayer{
    var peerID: MCPeerID
    var identifier: PlayerIdentifier
}

// Singleton: Instanciar na GameView
class AttGameViewModel: ObservableObject {
    static var shared = AttGameViewModel()
    @Published var PlayerName: String = ""
    @Published var PlayerColor: ourColors = .none
    
    // Array dos players connectados
    @Published var players: [GamePlayer] = []
    
    // Logica para o envio do local
    @Published var snapshots: [String: [PlayerSnapshot]] = [:]
    
    
    
}

struct MessageEnvelopeHeader: Codable {
    let type: MessageType
}

class GameViewModel: ObservableObject {
    
    @Published var isFinishedGame: Bool = false
    @Published var winnerName: String?
    @Published var winGame: Bool = false
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager, players: [PlayerIdentifier]){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        AttGameViewModel.shared.players = appendPlayers(MPCArray: connectionManager.session.connectedPeers, players: players)
        AttGameViewModel.shared.PlayerName = players[0].peerName
        AttGameViewModel.shared.PlayerColor = players[0].color
        
        //print(AttGameViewModel.shared.PlayerName, AttGameViewModel.shared.PlayerColor)
    }
    
    private func appendPlayers(MPCArray: [MCPeerID], players: [PlayerIdentifier]) -> [GamePlayer]{
        var array: [GamePlayer] = []
        
        for peer in MPCArray {
            if let player = players.first(where: { $0.peerName == peer.displayName }) {
                let item = GamePlayer(peerID: peer, identifier: PlayerIdentifier(peerName: player.peerName, color: player.color))
                array.append(item)
            }
        }
        return array
    }
    
}

extension GameViewModel: P2PMessaging {
    func send<T>(_ message: T, type: MessageType, peer: MCPeerID?) where T : Decodable, T : Encodable {
        do {
            let envelope = MessageEnvelope(type: type, content: message)
            let finalData = try JSONEncoder().encode(envelope)
            
            if let peerS = peer{
                connectionManager.send(data: finalData, peer: peerS)
            }
            else{
                connectionManager.send(data: finalData)
            }
        } catch {
            print("Erro ao enviar mensagem do tipo \(type): \(error)")
        }
    }
    
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        do {
            let envelopeHeader = try JSONDecoder().decode(MessageEnvelopeHeader.self, from: data)
            
            switch envelopeHeader.type {
            case .stopGame:
                guard !self.isFinishedGame || self.winGame == false else {
//                    print("🏁 Já finalizei o jogo como vencedor, ignorando mensagem de stopGame.")
                    return }
                DispatchQueue.main.async {
                    self.winnerName = peerID.displayName
                    self.winGame = false
                    self.isFinishedGame = true
                }
                
            case .position:
                let envelope = try JSONDecoder().decode(
                    MessageEnvelope<PlayerPositionEncoder>.self,
                    from: data
                )
                let snapshot = envelope.content.snapshot
                updatePosition(peerID: peerID, snapshot: snapshot)
                
            case .sabotage:
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("sabotageReceived"), object: nil)
                }
                
            default:
                break
            }
        } catch {
            print("❌ Falha ao decodificar envelope: \(error)")
        }
    }
    

}

extension GameViewModel {
    
    func finishGame() {
        guard !self.isFinishedGame else {
//            print("⚠️ Game already finished locally, ignoring.")
            return
        }
        
        DispatchQueue.main.async{
            self.winnerName = self.connectionManager.myPeerId.displayName
            self.winGame = true
            self.isFinishedGame = true
            
            let message = StopGameEncoder(peerName: self.connectionManager.myPeerId.displayName)
            self.send(message, type: .stopGame, peer: nil)
        }
    }
    
    @MainActor
    func disconnectRoom() {
        connectionManager.disconnect()
    }
    
    func updateSabotage() {
        DispatchQueue.main.async{
            
        }
    }
    
    func updatePosition(peerID: MCPeerID, snapshot: PlayerSnapshot) {
        DispatchQueue.main.async {
            let shared = AttGameViewModel.shared
            let key = peerID.displayName
            
            if shared.snapshots[key] == nil {
                shared.snapshots[key] = []
            }
            shared.snapshots[key]?.append(snapshot)
            
            // Ordena por tempo (caso mensagens cheguem fora de ordem)
            shared.snapshots[key]?.sort { $0.time < $1.time }

            // Limita tamanho do buffer
            if shared.snapshots[key]!.count > 20 {
                shared.snapshots[key]!.removeFirst()
            }
        }
    }

    
    func onAppear() {
        self.winnerName = nil
        self.winGame = false
        self.isFinishedGame = false
    }
}
