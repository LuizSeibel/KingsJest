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
        }
    }

}

struct container: View {
    let isFirst: Bool
    
    var body: some View {
        ZStack {
            
            
            if isFirst {
                VStack {
                    Image("tower")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color.grayConfigMenu)
                        .frame(height: 80)
                        .padding(.bottom, 24)
                    
                    Text("No rooms near you at\nthe moment! Try\ncreating a new room")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.grayConfigMenu)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(isFirst ? Color.grayLight : Color.grayLight.opacity(0.4))
                
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
}

#Preview {
    RoomPlaceholderCard(isFirst: true)
}
