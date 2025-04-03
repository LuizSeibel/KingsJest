//
//  MPCManager.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import MultipeerConnectivity

extension String{
    static var serviceName = "king-jest"
}

class MPCManager: NSObject, ObservableObject {
    let serviceType: String = String.serviceName
    
    var session: MCSession
    var myPeerId: MCPeerID
    let nearbyServiceBrowser: MCNearbyServiceBrowser
    let nearbyServiceAdvertiser: MCNearbyServiceAdvertiser
    
    @Published var paired: Bool = false
    @Published var nearbyPeers = [MCPeerID]()
    
    @Published var receivedInvite: Bool = false
    @Published var recievedInviteFrom: MCPeerID?
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?

    var onDisconnectPeer: ((MCPeerID) -> Void)?
    var onRecieveData: ((Data, MCPeerID) -> Void)?
    
    var hostPeerID: MCPeerID?
    
    init(yourName: String){
        
        print("-- Nova instancia MPCManager criada! --")
        
        let yourName = yourName.isEmpty ? UUID().uuidString : yourName
        
        myPeerId = MCPeerID(displayName: yourName)
        session = MCSession(peer: myPeerId)
        nearbyServiceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        nearbyServiceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        
        session.delegate = self
        nearbyServiceBrowser.delegate = self
        nearbyServiceAdvertiser.delegate = self
    }
}

extension MPCManager: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.nearbyPeers.contains(peerID){
                self.nearbyPeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.nearbyPeers.removeAll { $0 == peerID }
        }
    }
}

extension MPCManager: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            self.receivedInvite = true
            self.recievedInviteFrom = peerID
            self.invitationHandler = invitationHandler
        }
    }
}

extension MPCManager: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state{
        case .notConnected:
            print("❌ Peer desconectado: \(peerID.displayName)")
            DispatchQueue.main.async {
                if let host = self.hostPeerID, host == peerID {
                    self.paired = false
                }
                else {
                    if session.connectedPeers.isEmpty {
                        self.paired = false
                    }
                }
                
                if let onDisconnectPeer = self.onDisconnectPeer {
                    onDisconnectPeer(peerID)
                }
            }
            
        case .connected:
            print("✅ Conectado: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.paired = true
            }
        default:
            print("🔄 Conectando: \(peerID.displayName)")
            DispatchQueue.main.async {
                self.paired = false
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let onRecieveData = self.onRecieveData {
            onRecieveData(data, peerID)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: (any Error)?) {
        
    }
}

extension MPCManager {
    func send(data: Data) {
        guard !session.connectedPeers.isEmpty else {
            print("❌ Tentativa de envio sem peers conectados.")
            return
        }

        do {
            try session.send(data, toPeers: session.connectedPeers, with: .unreliable)
            print("✅ Enviado \(data.count) bytes para \(session.connectedPeers.map(\.displayName))")
        } catch {
            print("❌ Falha ao enviar dados: \(error)")
        }
    }
}

extension MPCManager{
    func disconnect() {
        print("🛑 Desconectando MPCManager...")

        // Encerra sessão com peers
        session.disconnect()
        
        // Para de anunciar e buscar
        stopAdvertising()
        stopBrowsing()
        
        // Reseta estado da aplicação
        DispatchQueue.main.async {
            self.paired = false
            self.nearbyPeers.removeAll()
        }

        // Cria nova sessão vazia para impedir uso da antiga
        let newSession = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        newSession.delegate = self
        self.session = newSession
        
        print("✅ Sessão resetada")
    }
    
    func invite(peer: MCPeerID) {
        self.hostPeerID = peer
        nearbyServiceBrowser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
    }
}

extension MPCManager {
    func startAdvertising() {
        nearbyServiceAdvertiser.startAdvertisingPeer()
    }
    
    func stopAdvertising() {
        nearbyServiceAdvertiser.stopAdvertisingPeer()
    }

    func startBrowsing() {
        nearbyServiceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        nearbyServiceBrowser.stopBrowsingForPeers()
        nearbyPeers.removeAll()
    }
}
