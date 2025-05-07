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
                .foregroundStyle(Color.white1)
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
            .buttonStyle(CustomUIButtonStyle())
            .frame(width: 80)
            .padding(.top)
        }
        .padding(.vertical, 32)
        .background{
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.grayLight)
        }
        
    }
}

#Preview {
    NicknameAlert(label: "Time to play your part!", placeholder: "Choose a nickname", text: .constant(""), onDismiss: {print("Botão clicado")})
        .frame(width: 450)
}
