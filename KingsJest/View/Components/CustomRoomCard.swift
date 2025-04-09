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
    
    @State var isFlipped: Bool = false
    @Namespace private var animation
        
    var body: some View {
        ZStack {
            if isFlipped {
                BackCard(roomName: roomName, flipAction: {
                    backCardAction()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                })
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                FrontCard(roomName: roomName, playersCount: playersCount, flipAction: {
                    frontCardAction()
                    withAnimation(.easeInOut(duration: 0.6)) {
                        isFlipped.toggle()
                    }
                })
            }
        }
        .frame(width: 320, height: 300)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.easeInOut(duration: 1), value: isFlipped)
    }
}

struct FrontCard: View {
    
    let roomName: String
    var playersCount: Int
    var flipAction: () -> Void
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .foregroundStyle(.uiBackground1)
            .overlay(
                VStack {
                    hud
                    Spacer()
                    button
                }
                .padding()
            )
    }
    
    var hud: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(roomName)'s Room")
                    .font(.title2)
                Text("\(playersCount)/8 Players")
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
                .foregroundStyle(Color.background)
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
            .foregroundStyle(.white1)
            .overlay(
                VStack{
                    hud
                        .padding()
                    button
                }
                    .padding()
                    
            )
            .frame(width: 320, height: 300)
    }
    
    var hud: some View {
        VStack(spacing: 30){
            Text("\(roomName)'s Room")
                .font(.title2)
                .fontWeight(.semibold)
            
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(2)
                .padding()
            
            VStack(spacing: 0) {
                Text("Wait while the host")
                Text("approves your request")
            }
            .fontWeight(.semibold)
        }
    }
    
    var button: some View {
        Button(action: flipAction) {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.gray1)
                .frame(maxHeight: 60)
                .overlay(
                    Text("Cancel")
                        .foregroundStyle(.black)
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
