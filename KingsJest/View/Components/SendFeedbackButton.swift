//
//  SendFeedbackButton.swift
//  KingsJest
//
//  Created by Luiz Seibel on 11/04/25.
//

import SwiftUI

struct SendFeedbackButton: View {
    @Environment(\.openURL) var openURL
    
    let formsUrl: String = "https://forms.gle/A1AwYC8LkspddA9x9"
    
    var body: some View {
        Button(action: {
            guard let url = URL(string: formsUrl) else { return }
            openURL(url)
        }) {
            Text("Send Feedback")
                .font(.footnote)
                .foregroundColor(Color(.white1))
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.white1), lineWidth: 4)
                )
        }
        .background(Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview{
    ZStack{
        Color.black
        SendFeedbackButton()
    }
    .ignoresSafeArea()
}
