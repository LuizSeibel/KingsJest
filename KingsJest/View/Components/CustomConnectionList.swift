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
                                .foregroundStyle(.black)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            
                            Button {
                                onDecline(peer.wrappedValue)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .buttonStyle(CustomSelectButton2())
                            
                            Button {
                                onAccept(peer.wrappedValue)
                            } label: {
                                Image(systemName: "checkmark")
                            }
                            .buttonStyle(CustomSelectPlayerButton2())
                            
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


//#Preview {
//    CustomConnectionList(peers: .constant([MCPeerID(displayName: "Flavio"), MCPeerID(displayName: "Rafaerl")]))
//}
