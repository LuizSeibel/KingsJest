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
    func onReceiveMessage(data: Data, peerID: MCPeerID) {
        guard let envelope = try? JSONDecoder().decode(MessageEnvelope.self, from: data) else {
            print("❌ Falha ao decodificar envelope")
            return
        }

        switch envelope.type {
        case .stopGame:
            do {
                let _ = try JSONDecoder().decode(StopGameEncoder.self, from: envelope.payload)
                DispatchQueue.main.async {
                    self.winnerName = peerID.displayName
                    self.winGame = false
                    self.isFinishedGame = true
                }
            } catch {
                print("❌ Erro ao decodificar StopGameEncoder: \(error)")
                if let raw = String(data: envelope.payload, encoding: .utf8) {
                    print("Payload bruto: \(raw)")
                }
            }

        case .position:
            do {
                let data = try JSONDecoder().decode(PlayerPositionEncoder.self, from: envelope.payload)
                let snapshot = data.snapshot
                updatePosition(peerID: peerID, position: snapshot.position, time: snapshot.time, velocity: snapshot.velocity)
            } catch {
                print("❌ Erro ao decodificar PlayerPositionEncoder: \(error)")
                if let json = String(data: envelope.payload, encoding: .utf8) {
                    print("Payload bruto: \(json)")
                }
            }
            
        default:
            break
        }
    }
    
    func send<T: Codable>(_ message: T, type: MessageType) {
        do {
            let payload = try JSONEncoder().encode(message)
            let envelope = MessageEnvelope(type: type, payload: payload)
            let finalData = try JSONEncoder().encode(envelope)
            connectionManager.send(data: finalData)
        } catch {
            print("Erro ao enviar mensagem do tipo \(type): \(error)")
        }
    }
}

extension GameViewModel {
    
    func finishGame() {
        DispatchQueue.main.async{
            self.winnerName = self.connectionManager.myPeerId.displayName
            self.winGame = true
            self.isFinishedGame = true
            
            let message = StopGameEncoder(peerName: self.connectionManager.myPeerId.displayName)
            self.send(message, type: .stopGame)
        }
    }
    
    func disconnectRoom() {
        connectionManager.disconnect()
    }
    
    func updatePosition(peerID: MCPeerID, position: CGPoint, time: TimeInterval, velocity: CGVector) {
        DispatchQueue.main.async {
            let shared = AttGameViewModel.shared
            
            let key = peerID.displayName
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
    
    func onAppear() {
        self.winnerName = nil
        self.winGame = false
        self.isFinishedGame = false
    }
}

extension GameViewModel{
    
    func iniciarGravação(){
        ReplayKitManager.shared.startRecording(microphoneEnabled: true) { error in
            if let error = error {
                print("Erro ao iniciar gravação:", error.localizedDescription)
            } else {
                print("Gravação iniciada com sucesso!")
            }
        }
    }
}
