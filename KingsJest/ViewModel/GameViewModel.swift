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


class AttGameViewModel: ObservableObject {
    @Published var playerPositions: [String: CGPoint] = [:]
    
}

class GameViewModel: ObservableObject {
    
    @Published var isFinishedGame: Bool = false
    @Published var winnerName: String?
    @Published var winGame: Bool = false
    
    
    
    var connectionManager: MPCManager

    init(connectionManager: MPCManager){
        self.connectionManager = connectionManager
        self.connectionManager.onRecieveData = onReceiveMessage
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
            if let position = try? JSONDecoder().decode(PlayerPositionEncoder.self, from: envelope.payload) {
                updatePosition(peerID: peerID, x: position.x, y: position.y)
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
    
    func sendPosition(x: Float, y: Float) {
        let message = PlayerPositionEncoder(peerName: connectionManager.myPeerId.displayName, x: x, y: y)
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
    
    func updatePosition(peerID: MCPeerID, x: Float, y: Float) {
        DispatchQueue.main.async {
            self.playerPositions[peerID.displayName] = CGPoint(x: CGFloat(x), y: CGFloat(y))
        }
    }
}
