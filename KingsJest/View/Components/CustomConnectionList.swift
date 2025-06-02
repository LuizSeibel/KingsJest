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
                    Image("tower")
                        .foregroundStyle(Color.grayConfigMenu)

                    
                    Text("No jesters at the door yet...")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.grayConfigMenu)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
            }
            else{
                List {
                    ForEach($peers, id: \.self) { peer in
                        HStack {
                            Text(peer.wrappedValue.displayName)
                                .foregroundStyle(Color.grayLight)
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
                    .background(.beigeMain)
                    .cornerRadius(12)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .padding(.vertical)
            }
        }
        .background(.grayLight)
    }
}


#Preview {
    CustomConnectionList(peers: .constant([MCPeerID(displayName: "Flavio")]), onAccept: {_ in }, onDecline: {_ in })
}
