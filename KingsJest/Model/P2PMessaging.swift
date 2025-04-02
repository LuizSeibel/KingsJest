//
//  P2PMessaging.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import MultipeerConnectivity

protocol P2PMessaging {
    func onReceiveMessage(data: Data, peerID: MCPeerID)
    func send<T: Codable>(_ message: T, type: MessageType)
}
