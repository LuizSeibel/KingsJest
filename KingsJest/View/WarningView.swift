//
//  WarningView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 23/05/25.
//

import SwiftUI

struct WarningView: View{
    
    private var backgroundColor = Color("gray_light")
    
    var body: some View{
        ZStack{
            //background
            VStack(spacing: 20){
                Image("audioButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.11,
                           height: UIScreen.main.bounds.height * 0.11)
                warningText
            }
        }
    }
    
    var background: some View {
        ZStack{
            backgroundColor
            
            VStack{
                Spacer()
                Image("homeIlustration")
                    .resizable()
                    .scaledToFit()
            }
            Color.black.opacity(0.5)
        }
        .ignoresSafeArea()
    }
    
    var warningText: some View{
        VStack(spacing: 0){
            Text("This game uses sound effects to enhance your")
                .tutorialTextStyle(color: .secondary)
            HStack(spacing: 0){
                Text(" experience. Please ")
                    .tutorialTextStyle(color: .secondary)
                Text("turn up the volume!")
                    .tutorialTextStyle()
            }
        }
    }
}

#Preview {
    WarningView()
}
