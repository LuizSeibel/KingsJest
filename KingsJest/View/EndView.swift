//
//  EndView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/03/25.
//

import SwiftUI

struct EndView: View {
    
    @StateObject private var viewModel: EndViewModel
    
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
        .navigationDestination(isPresented: $viewModel.goToMainMenu, destination: {
            ContentView()
        })
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
                print("Send Review")
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

// MARK: - WIN/LOSE MESSAGE
extension EndView {
    
}

#Preview {
    EndView(winBool: false)
}
