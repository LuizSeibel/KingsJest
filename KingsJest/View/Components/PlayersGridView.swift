//
//  PlayersGridView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct PlayerItemView: View {
    let nickname: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray)
                .frame(width: 60, height: 80)
            
            Text(nickname)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

struct PlayersGridView: View {
    @Binding var players: [String]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(players, id: \.self) { player in
                PlayerItemView(nickname: player)
            }
        }
    }
}

#Preview {
    PlayersGridView(players: .constant(["Player1", "Player2", "Player3", "Player4",
                                        "Player5", "Player6", "Player7", "Player8"]))
    .background(Color.black.edgesIgnoringSafeArea(.all))
}

