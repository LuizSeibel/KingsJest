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
    var winnerName: String = ""
    
    let sizeClass = DeviceType.current()
    
    init(winBool: Bool, winnerName: String){
        self.winBool = winBool
        self.winnerName = winnerName
        _viewModel = StateObject(wrappedValue: EndViewModel())
    }
    
    var body: some View {
        ZStack{
            background
            hud
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: {
                Button(action: {
                    withAnimation{
                        guard let url = URL(string: formsUrl) else { return }
                        openURL(url)
                    }
                }) {
                    Image("InfoButton")
                }
                .font(.title)
                .padding(.top, sizeClass == .iPhone ? 48 : 24)
                .padding(.trailing, sizeClass == .iPhone ? 0 : 24)
                
            })
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
            buttons
        }
    }
    
    var winMessage: some View {
        VStack(spacing: 32){
            Image(winBool ? "coroa2" : "touca2")
                .frame(width: 78, height: 52)
            
            VStack(spacing: 6){
                Text(winBool ? "You Dodged the Dungeon!" : "The King was not Amused...")
                    .font(Font.custom(appFonts.Libra.rawValue, size: 32).weight(.bold))
                message
            }
            
        }
        .foregroundStyle(.beigeMain)
    }
    
    var buttons: some View {
        HStack(spacing: 12){
            Button(action: {
                viewModel.toMainMenu()
            }, label: {
                Text("Back to Menu")
            })
            .buttonStyle(CustomUIButtonStyle())
        }
    }
    
    var message: some View {
        
        VStack{
            if winBool{
                Text("Victory Is Yours... this time")
            }
            else{
                Text("Winner: playername")
            }
        }
        .font(Font.custom(appFonts.Libra.rawValue, size: 20).weight(.bold))
        .foregroundStyle(.yellowMain)
        
    
    }
    
    var background: some View {
        ZStack{
            Color(.grayMain)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack{
        EndView(winBool: false, winnerName: "playername")
    }
}

