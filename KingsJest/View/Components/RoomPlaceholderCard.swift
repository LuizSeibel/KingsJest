//
//  RoomPlaceholderCard.swift
//  KingsJest
//
//  Created by Willys Oliveira on 21/05/25.
//

import SwiftUI

struct RoomPlaceholderCard: View {
    let isFirst: Bool
    
    var body: some View{
        VStack{
            container(isFirst: isFirst)
//                .compositingGroup()
                .aspectRatio(264/232, contentMode: .fit)
                .scaleEffect(0.85)
        }
    }

}

struct container: View {
    let isFirst: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(isFirst ? Color.grayLight : Color.grayLight.opacity(0.4))
            
            if isFirst {
                VStack {
                    Image("tower")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .padding(.bottom, 24)
                    
                    Text("No rooms near you at\nthe moment! Try\ncreating a new room")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.grayMain)
                .multilineTextAlignment(.center)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
}

#Preview {
    RoomPlaceholderCard(isFirst: true)
}
