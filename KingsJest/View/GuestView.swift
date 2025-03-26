//
//  GuestView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct GuestView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: GuestViewModel
    
    @State var goToGame: Bool = false
    
    // Animation vars
    @State private var dotCount: Int = 0
    let maxDots = 3
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: GuestViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .topLeading) {
                background
                
                ZStack {
                    if viewModel.isConnected{
                        lobbyHud
                    }
                    else{
                        hud
                    }
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomBackButton()
                    .padding(.top, 40)
                    .padding(.leading, 50)
            }
            
            // MARK: View States
            .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
                if !isPresented && !goToGame{
                    viewModel.disconnect()
                }
            }
            
            .onAppear{
                viewModel.onAppear()
            }
            
            // MARK: Navigation
            .navigationDestination(isPresented: $viewModel.startGame, destination: {
                GameView(connectionManager: viewModel.connectionManager)
            })
            
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension GuestView {
    var background: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            Image("bricks2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    var title: some View {
        Text("Join Room")
            .font(.custom("STSongti-TC-Bold", size: 32))
            .foregroundStyle(Color(.gray1))
    }
    
    var list: some View{
        List(viewModel.availableRooms, id: \.self){ peer in
            CustomListIndexView(label: "\(peer.displayName)'s Room", labelButton1: "Join", labelButton2: "0/8", button1Closure: {viewModel.sendInvite(peer: peer)}, button2Disable: true, isSmallStyle: true)
                .padding(.horizontal, 144)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
    
    var hud: some View {
        VStack(alignment: .center){
            title
                .padding(48)
            list
        }
    }
    
    var lobbyHud: some View {
        VStack {
            Image("coroa")
            Text("Waiting for host's start game \(String(repeating: ".", count: dotCount))")
                .foregroundStyle(.gray)
                .font(.custom("STSongti-TC-Bold", size: 26))
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % (maxDots + 1)
        }
    }
}

#Preview {
    GuestView(connectionManager: MPCManager(yourName: ""))
}
