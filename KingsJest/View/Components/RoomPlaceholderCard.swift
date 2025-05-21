//
//  RoomPlaceholderCard.swift
//  KingsJest
//
//  Created by Willys Oliveira on 21/05/25.
//

import SwiftUI

struct RoomPlaceholderCard: View {
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
                    
                    Text("No rooms near you at")
                    Text("the moment!")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.grayMain)
                .multilineTextAlignment(.center)
            }
        }
        .aspectRatio(264/232, contentMode: .fit)
        .scaleEffect(0.85)
    }
}

#Preview {
    RoomPlaceholderCard(isFirst: true)
}
