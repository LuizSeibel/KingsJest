//
//  GuestView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct GuestView: View {
    @EnvironmentObject var appViewModel: RootViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: GuestViewModel
    
    // Animation vars
    @State private var dotCount: Int = 0
    let maxDots = 3
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: GuestViewModel(connectionManager: connectionManager))
    }
    
    let sizeClass = DeviceType.current()
    
    var body: some View {
//        NavigationStack{
            ZStack(alignment: .topLeading) {
                background
                
                ZStack {
                    if viewModel.isConnected{
                        playersHud
                    }
                    else{
                        hud
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomBackButton()
                    .padding(.top, 40)
                    .padding(.horizontal)
            }
            
            .onChange(of: viewModel.startDelay){ value in
                if value{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                        withAnimation(.easeInOut){
                            viewModel.startDelay.toggle()
                        }
                    })
                }
            }
            
            // MARK: View States
            .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
                if !isPresented && !viewModel.startGame{
                    viewModel.disconnect()
                }
            }
            
            .onAppear{
                viewModel.onAppear()
            }
            
            .onChange(of: viewModel.startGame){ value in
                if value{
                    appViewModel.path.append(.game(connectionManager: viewModel.connectionManager, players: viewModel.roomPlayers))
                }
            }
        
        
            // MARK: Navigation
//            .navigationDestination(isPresented: $viewModel.startGame, destination: {
//                GameView(connectionManager: viewModel.connectionManager, players: viewModel.roomPlayers)
//                    .id(viewModel.gameSessionID)
//            })
            
//        }
//        .navigationBarBackButtonHidden(true)
    }
}

extension GuestView {
    var background: some View {
        ZStack{
            Color.grayMain
                .ignoresSafeArea()
        }
    }
    
    var title: some View {
        Text("Join Room")
            .font(.custom("ø", size: 32))
            .foregroundStyle(Color(.beigeMain))
    }
    

    var list: some View{
        ZStack{
            ScrollView(.horizontal){
                HStack(spacing: -16){
                    ForEach(viewModel.availableRooms, id: \.self){ peer in
                        CustomRoomCard(
                            roomName: peer.displayName,
                            playersCount: 1,
                            frontCardAction: { viewModel.sendInvite(peer: peer) },
                            backCardAction: { viewModel.cancelInvite(peer: peer) }
                        )
                        .offset(y: 16)
                        
                    }
                }
            }
        }
    }
    
    var hud: some View {
        VStack(alignment: .center){
            title
                .padding(.top, 28)
            Spacer()
            list
                .allowsHitTesting(!viewModel.startDelay)
        }
    }
    
    var waitingView: some View {
        VStack {
            Image("coroa")
            Text("Waiting for connection \(String(repeating: ".", count: dotCount))")
                .foregroundStyle(.gray)
                .font(.custom("ø", size: 26))
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % (maxDots + 1)
        }
    }
    
    
    
    var playersHud: some View{
        VStack{
            Text("Waiting Room")
                .foregroundStyle(.beigeMain)
                .font(.custom("ø", size: 32))
                .padding(.top, 28)
            Spacer()
            if viewModel.roomPlayers.count <= 1{
                waitingView
            }
            else{
                PlayersGridView(players: $viewModel.roomPlayers)
            }
            Spacer()
        }
    }
}

#Preview {
    GuestView(connectionManager: MPCManager(yourName: ""))
}
