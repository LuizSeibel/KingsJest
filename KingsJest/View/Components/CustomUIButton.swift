//
//  CustomUIButton.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct CustomUIButtonStyle: ButtonStyle {
    var isDarkMode: Bool = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .font(.custom("STSongti-TC-Bold", size: 20))
            .frame(maxWidth: 180)
            .background(configuration.isPressed ?
                        (isDarkMode ? Color(.uiBackground1).opacity(0.7) : Color(.beigeMain)).opacity(0.7) :
                        (isDarkMode ? Color(.uiBackground1) : Color(.beigeMain)))
            .foregroundColor(isDarkMode ? .white : Color("BackgroundColor"))
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
#Preview {
    Button(action: {
        print("Botão clicado")
    }, label: {
        Text("Join Room")
    })
    .buttonStyle(CustomUIButtonStyle())
}
