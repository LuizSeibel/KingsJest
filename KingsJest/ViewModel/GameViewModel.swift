//
//  GameViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import Foundation
import MultipeerConnectivity

// Singleton: Instanciar na GameView
class AttGameViewModel: ObservableObject {
    static var shared = AttGameViewModel()
    @Published var PlayerName: String = ""
    @Published var snapshots: [String: [PlayerSnapshot]] = [:]
    @Published var players: [MCPeerID] = []
}

struct MessageEnvelopeHeader: Codable {
    let type: MessageType
}

class GameViewModel: ObservableObject {
    
    @Published var isFinishedGame: Bool = false
    @Published var winnerName: String?
    @Published var winGame: Bool = false
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
        AttGameViewModel.shared.players = connectionManager.session.connectedPeers
        AttGameViewModel.shared.PlayerName = connectionManager.session.myPeerID.displayName
    }
    
}

extension GameViewModel: P2PMessaging {
    func send<T>(_ message: T, type: MessageType, peer: MCPeerID?) where T : Decodable, T : Encodable {
        do {
            let envelope = MessageEnvelope(type: type, content: message)
            let finalData = try JSONEncoder().encode(envelope)
            connectionManager.send(data: finalData)
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
