//
//  CustomConnectionList.swift
//  KingsJest
//
//  Created by Luiz Seibel on 07/04/25.
//

import Foundation
import MultipeerConnectivity
import SwiftUI

struct CustomConnectionList: View {
    
    @Binding var peers: [MCPeerID]
    
    var onAccept: (MCPeerID) -> Void
    var onDecline: (MCPeerID) -> Void
    
    var body: some View {
        VStack{
            
            if peers.isEmpty {
                VStack(spacing: 16){
                    Image("touca")
                    
                    Text("Your requests will appear here")
                        .font(.custom("STSongti-TC-Bold", size: 20))
                        .foregroundStyle(Color.background)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
            }
            else{
                List {
                    ForEach($peers, id: \.self) { peer in
                        HStack {
                            Text(peer.wrappedValue.displayName)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button("Ignore") {
                                onDecline(peer.wrappedValue)
                            }
                            .buttonStyle(CustomSelectButton2())
                            
                            Button("Accept") {
                                onAccept(peer.wrappedValue)
                            }
                            .buttonStyle(CustomSelectPlayerButton())
                            
                        }
                    }
                    .padding(12)
                    .background(.white1)
                    .cornerRadius(12)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .padding(.vertical)
            }
        }
        .background(.uiBackground1)
    }
}

//
//#Preview {
//    CustomConnectionList(peers: .constant([MCPeerID(displayName: "Flavio"), MCPeerID(displayName: "Rafaerl")]))
//}
