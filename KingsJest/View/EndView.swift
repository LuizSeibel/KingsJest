//
//  EndView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import SwiftUI

struct EndView: View {
    
    @Environment(\.openURL) var openURL
    
    @StateObject private var viewModel: EndViewModel
    
    let formsUrl: String = "https://forms.gle/A1AwYC8LkspddA9x9"
    
    var winBool: Bool = false
    
    init(winBool: Bool){
        self.winBool = winBool
        _viewModel = StateObject(wrappedValue: EndViewModel())
    }
    
    var body: some View {
        ZStack{
            background
            
            hud
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $viewModel.goToMainMenu, destination: {
            ContentView()
        })
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}


extension EndView {
    
    var hud: some View {
        VStack(spacing: 20){
            winMessage
            message
            buttons
        }
    }
    
    var winMessage: some View {
        VStack{
            Image(winBool ? "coroa2" : "touca2")
                .frame(width: 78, height: 52)
            
            Text(winBool ? "You Dodged the Dungeon!" : "The King was not Amused...")
                .font(Font.custom("Songti TC", size: 32).weight(.bold))
        }
        .foregroundStyle(winBool ? .yellow1 : .red1)
    }
    
    var buttons: some View {
        VStack(spacing: 12){
            Button(action: {
                guard let url = URL(string: formsUrl) else { return }
                openURL(url)
            }, label: {
                Text("Send Review")
            })
            .buttonStyle(CustomUIButtonStyle(isDarkMode: true))
            
            Button(action: {
                viewModel.toMainMenu()
            }, label: {
                Text("Back to Menu")
            })
            .buttonStyle(CustomUIButtonStyle())
        }
    }
    
    var message: some View {
        Text("""
            Thank's for testing our game!
            Your feedback helps us make it even better.
            """)
        .foregroundStyle(.gray)
        .fontWeight(.semibold)
        .multilineTextAlignment(.center)
    }
    
    var background: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            Image("bricks1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    EndView(winBool: false)
}
