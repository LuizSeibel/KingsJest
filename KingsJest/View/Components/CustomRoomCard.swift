//
//  CustomRoomCard.swift
//  KingsJest
//
//  Created by Luiz Seibel on 09/04/25.
//

import SwiftUI

struct CustomRoomCard: View {

    let roomName: String
    var playersCount: Int
    
    var frontCardAction: () -> Void = {}
    var backCardAction: () -> Void = {}
    
    @State private var isFlipped: Bool = false
    @State private var flipResetTask: Task<Void, Never>? = nil

    var body: some View {
        ZStack {
            if isFlipped {
                BackCard(roomName: roomName) {
                    backCardAction()
                    flipCard()
                }
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                FrontCard(roomName: roomName, playersCount: playersCount) {
                    frontCardAction()
                    flipCard()
                }
            }
        }
        .compositingGroup()
        .aspectRatio(264/232, contentMode: .fit)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0),
                          axis: (x: 0, y: 1, z: 0),
                          perspective: 0.5)
        .scaleEffect(0.85)
        .animation(.easeInOut(duration: 0.6), value: isFlipped)
    }

    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isFlipped.toggle()
        }
        
        // Cancela qualquer tarefa anterior antes de iniciar uma nova
        flipResetTask?.cancel()
        flipResetTask = Task {
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped = false
                    }
                }
            }
        }
    }
}

struct FrontCard: View {
    let roomName: String
    var playersCount: Int
    var flipAction: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.grayLight)
            .overlay(
                ZStack{
                    Image("Subtract")
                        .resizable()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                    VStack {
                        hud
                        Spacer()
                        button
                    }
                    .padding()
                }
            )
            .aspectRatio(1, contentMode: .fit)
    }
    
    var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(roomName)'s Room")
                    .font(.title2)
                //Text("Max. 8 Players")
            }
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            Spacer()
        }
        .padding()
    }
    
    var button: some View {
        Button(action: flipAction) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.redLight)
                .frame(maxHeight: 60)
                .overlay(
                    Text("Join")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                )
        }
    }
}

struct BackCard: View {
    let roomName: String
    var flipAction: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(Color.redMain)
            .overlay(
                
                ZStack{
                    Image("Subtract")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.redLight)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                    
                    VStack {
                        hud
                            .padding()
                        button
                    }
                    .padding()
                }
                
            )
            .aspectRatio(1, contentMode: .fit)
    }
    
    var hud: some View {
        VStack(spacing: 20) {
            Text("\(roomName)'s Room")
                .font(.title2)
                .fontWeight(.semibold)
            
            ProgressView()
                .tint(.white1)
                .progressViewStyle(.circular)
                .scaleEffect(2)
                .padding(6)
            
            VStack(spacing: 0) {
                Text("Wait while the host")
                Text("approves your request...")
            }
            .font(.callout)
            .fontWeight(.medium)
        }
        .foregroundStyle(.white1)
    }
    
    var button: some View {
        Button(action: flipAction) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(Color.redDark)
                .frame(maxHeight: 60)
                .overlay(
                    Text("Cancel")
                        .foregroundStyle(.redLight)
                        .fontWeight(.semibold)
                )
        }
    }
}

#Preview("Card") {
    CustomRoomCard(roomName: "Nickname", playersCount: 1)
}

#Preview("Front/Back") {
    BackCard(roomName: "Nickname", flipAction: {})
    FrontCard(roomName: "Nickname", playersCount: 1, flipAction: {})
}
