//
//  CustomSelectButton2.swift
//  KingsJest
//
//  Created by Luiz Seibel on 21/03/25.
//

import SwiftUI

struct CustomSelectButton2: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(8)
            //.padding(.horizontal, 8)
            .background(configuration.isPressed ? Color.beigeDark.opacity(0.5) : Color(.beigeDark))
            .foregroundColor(Color(.darkGray).opacity(0.8))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct CustomSelectButton: View {
    
    var label: String
    var actionClosure: (() -> Void)
    var disable: Bool = false
    
    var body: some View {
        Button(action: {
            actionClosure()
        },
        label: {
            Text(label)
        })
        .buttonStyle(CustomSelectButton2())
        .disabled(disable)
    }
}

#Preview {
    CustomSelectButton(label: "Ignore", actionClosure: {})
    
    CustomSelectButton(label: "0/8", actionClosure: {})
        .frame(width: 55)
}
