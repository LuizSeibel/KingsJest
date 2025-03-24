//
//  CustomJoinButton.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI

struct CustomSelectPlayerButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            .fontWeight(.semibold)
            .frame(maxWidth: 90)
            .background(configuration.isPressed ? Color(.background).opacity(0.7) : Color(.background))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    Button(action: {
        print("Botão clicado")
    }, label: {
        Text("Join")
    })
    .buttonStyle(CustomSelectPlayerButton())
}
