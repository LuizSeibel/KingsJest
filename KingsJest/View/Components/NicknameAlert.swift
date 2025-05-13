//
//  NicknameAlert.swift
//  KingsJest
//
//  Created by Luiz Seibel on 05/05/25.
//

import SwiftUI

struct nicknameLabel{
    let title: String
    let placeholder: String
}

struct NicknameAlert: View {
    
    var label: String
    var placeholder: String
    @Binding var text: String
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20){
            Text(label)
                .font(.custom(appFonts.Libra.rawValue, size: 26))
                .foregroundStyle(Color("beige_main"))
                .padding(.bottom)
            
            Nickname(text: $text, placeholder: placeholder)
                .padding(.horizontal, 32)
                
            Button(action: {
                if text != ""{
                    onDismiss()
                }
            }, label: {
                Text("Done")
            })
            .buttonStyle(CustomUIButtonStyle(isDarkMode: true, backgroundColor: Color("beige_main"), textColor: Color("red_light"), fontSize: 15, maxWidth: 135, maxHeight: 47))
            .padding(.top)
        }
        .frame(width: 400, height: 200)
        .background{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.redMain)
                .overlay(
                    ZStack {
                        Image("SubtractHorizontalRed")
                    }
                )

        }
        
    }
}

#Preview {
    NicknameAlert(label: "Time to play your part!", placeholder: "Choose a nickname", text: .constant(""), onDismiss: {print("Botão clicado")})
        .frame(width: 450)
}
