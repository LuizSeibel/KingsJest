//
//  GameViewModel.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import Foundation
import MultipeerConnectivity

enum MessageType: String, Codable {
    case stopGame
    case position
}

struct MessageEnvelope: Codable {
    let type: MessageType
    let payload: Data
}

struct PlayerSnapshot: Codable {
    let time: TimeInterval
    let position: CGPoint
    let velocity: CGVector
}

// Singleton: Instanciar na GameView
class AttGameViewModel: ObservableObject {
    static var shared = AttGameViewModel()
    // @Published var playerPositions: [String: [CGPoint]] = [:]
    @Published var snapshots: [String: [PlayerSnapshot]] = [:]
    @Published var players: [MCPeerID] = []
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
    }
    
}

extension GameViewModel: P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        guard let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) else {
            print("❌ Falha ao decodificar envelope")
            return
        }

        switch envelope.type {
        case .stopGame:
            if (try? JSONDecoder().decode(StopGameEncoder.self, from: envelope.payload)) != nil {
                DispatchQueue.main.async {
                    self.winnerName = peerID.displayName
                    self.winGame = false
                    self.isFinishedGame = true
                }
            }

        case .position:
            if let data = try? JSONDecoder().decode(PlayerPositionEncoder.self, from: envelope.payload) {
                updatePosition(peerID: peerID, position: data.position, time: data.time, velocity: data.velocity)
            }
        }
    }
    
    func sendMessage() {
        let message = StopGameEncoder(peerName: connectionManager.myPeerId.displayName)
        do {
            let payload = try JSONEncoder().encode(message)
            let envelope = MessageEnvelope(type: .stopGame, payload: payload)
            let finalData = try JSONEncoder().encode(envelope)
            connectionManager.send(data: finalData)
        } catch {
            print("Erro ao enviar mensagem de fim de jogo: \(error)")
        }
    }
    
    func sendPosition(snapshot: PlayerSnapshot) {
        let message = PlayerPositionEncoder(peerName: connectionManager.myPeerId.displayName, position: snapshot.position, time: snapshot.time, velocity: snapshot.velocity)
        do {
            let payload = try JSONEncoder().encode(message)
            let envelope = MessageEnvelope(type: .position, payload: payload)
            let finalData = try JSONEncoder().encode(envelope)
            connectionManager.send(data: finalData)
        } catch {
            print("Erro ao enviar mensagem de fim de jogo: \(error)")
        }
    }
}

extension GameViewModel {
    
    func finishGame() {
        print(" - Terminou o jogo!")
        DispatchQueue.main.async{
            self.winnerName = self.connectionManager.myPeerId.displayName
            self.winGame = true
            self.isFinishedGame = true
            self.sendMessage()
        }
    }
    
    func disconnectRoom() {
        connectionManager.disconnect()
    }
    
    func updatePosition(peerID: MCPeerID, position: CGPoint, time: TimeInterval, velocity: CGVector) {
        DispatchQueue.main.async {
            let shared = AttGameViewModel.shared
            
            let key = peerID.displayName
            
            // if shared.playerPositions[key] == nil {
            //     shared.playerPositions[key] = []
            // }
            
            // if let last = shared.playerPositions[key]?.last {
            //     if last.distance(to: position) < 1 { return } // ignora pontos muito próximos
            // }
            // shared.playerPositions[key]?.append(position)
            
            let snap = PlayerSnapshot(time: time, position: position, velocity: velocity)
            if shared.snapshots[key] == nil {
                shared.snapshots[key] = []
            }
            shared.snapshots[key]?.append(snap)
            // Ordena por tempo (caso mensagens cheguem fora de ordem)
            shared.snapshots[key]?.sort { $0.time < $1.time }
            // Limita tamanho do buffer
            if shared.snapshots[key]!.count > 20 {
                shared.snapshots[key]!.removeFirst()
            }
        }
    }
}
