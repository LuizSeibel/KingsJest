//
//  PlayersGridView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct PlayerItemView: View {
    let nickname: String?
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(nickname == nil ? Color.grayLight.opacity(0.5) : Color.grayLight)
                .frame(width: 55, height: 75)

            Text(nickname ?? "")
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
    }
}


struct PlayersGridView: View {
    @Binding var players: [String]
    
    let maxPlayers = 8
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        let paddedPlayers: [String?] = players + Array(repeating: nil, count: max(0, maxPlayers - players.count))
        
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<maxPlayers, id: \.self) { index in
                PlayerItemView(nickname: paddedPlayers[index])
            }
        }
    }
}

#Preview("Some") {
    PlayersGridView(players: .constant(["Luiz", "Maju", "Willys", "Amanda"]))
        .background(Color.black.ignoresSafeArea())
}

#Preview("All") {
    PlayersGridView(players: .constant(["Player1", "Player2", "Player3", "Player4",
                                        "Player5", "Player6", "Player7", "Player8"]))
    .background(Color.black.edgesIgnoringSafeArea(.all))
}

