//
//  PlayersGridView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 24/03/25.
//

import SwiftUI

struct PlayerItemView: View {
    /// `nil` quando o slot está vazio.
    let player: PlayerIdentifier?
    let index: Int

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(index == 0 ? Color.beigeMain : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(backgroundColor)
                )
                .overlay {
                    if let p = player {
                        Image("J_\(p.color.rawValue)")
                            .resizable()
                            .scaledToFill()
                    }
                }
                .frame(width: 55, height: 75)


            Text(player?.peerName ?? "")
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
    }
    
    private var backgroundColor: Color {
        if player == nil {
            return Color.gray.opacity(0.5)
        } else {
            return index == 0 ? Color.beigeDark : Color.grayLight
        }
    }
}

struct PlayersGridView: View {
    @Binding var players: [PlayerIdentifier]

    private let maxPlayers = 8
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    /// Array com exatamente `maxPlayers` posições (com `nil` para slots vazios).
    private var paddedPlayers: [PlayerIdentifier?] {
        var list = players.map(Optional.init)
        list.append(contentsOf: Array(repeating: nil, count: max(0, maxPlayers - list.count)))
        return list
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<maxPlayers, id: \.self) { index in
                PlayerItemView(player: paddedPlayers[index], index: index)
            }
        }
    }
}

// MARK: – Previews ------------------------------------------------------------

private let demoPlayersSome: [PlayerIdentifier] = [
    .init(peerName: "Luiz",    color: .blue),
    .init(peerName: "Maju",    color: .pink),
    .init(peerName: "Willys",  color: .orange),
    .init(peerName: "Amanda",  color: .yellow)
]

private let demoPlayersAll: [PlayerIdentifier] = [
    .init(peerName: "Player1", color: .red),
    .init(peerName: "Player2", color: .green),
    .init(peerName: "Player3", color: .purple),
    .init(peerName: "Player4", color: .blue),
    .init(peerName: "Player5", color: .yellow),
    .init(peerName: "Player6", color: .orange),
    .init(peerName: "Player7", color: .pink),
    .init(peerName: "Player8", color: .black)
]

#Preview("Some") {
    PlayersGridView(players: .constant(demoPlayersSome))
        .background(Color.black.ignoresSafeArea())
}

#Preview("All") {
    PlayersGridView(players: .constant(demoPlayersAll))
        .background(Color.black.ignoresSafeArea())
}
