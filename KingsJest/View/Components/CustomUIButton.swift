//
//  CustomUIButton.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct CustomUIButtonStyle: ButtonStyle {
    var isDarkMode: Bool = false
    var backgroundColor: Color?
    var textColor: Color?
    var fontSize: CGFloat = 20
    var maxWidth: CGFloat = 180
    var maxHeight: CGFloat = 50

    func makeBody(configuration: Configuration) -> some View {
        let bgColor = backgroundColor ??
            (isDarkMode ? Color(.uiBackground1) : Color(.beigeMain))
        let fgColor = textColor ??
            (isDarkMode ? .white : Color("BackgroundColor"))

        configuration.label
            .padding(8)
            .font(.custom("STSongti-TC-Bold", size: fontSize))
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .background(
                configuration.isPressed
                ? bgColor.opacity(0.7)
                : bgColor
            )
            .foregroundColor(fgColor)
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
