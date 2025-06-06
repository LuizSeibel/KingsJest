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
    
    @Namespace private var animation
    
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
                else {
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
    
    var list: some View {
        ZStack {
            if viewModel.availableRooms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (spacing: 0) {
                        ForEach(0..<4, id: \.self) { index in
                            RoomPlaceholderCard(isFirst: index == 0)
                                .padding()
                        }
                    }
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: -16) {
                        ForEach(Array(viewModel.availableRooms.enumerated()), id: \.element) { index, peer in
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
    }
    
    
    
    // View que mostra os cards de cada sala criada para entrar
    var hud: some View {
        VStack(alignment: .center){
            title
                .padding(.top, 28)
            Spacer()
            list
                .allowsHitTesting(!viewModel.startDelay)
        }
    }
    
    // View de espera até o host aceitar
    var waitingView: some View {
        VStack {
            
            JesterLoadingRun()

            Text("Waiting for connection \(String(repeating: ".", count: dotCount))")
                .foregroundStyle(.gray)
                .font(.custom("ø", size: 26))
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % (maxDots + 1)
        }
    }
    
    
    // View de espera pelo start do host (com os players na sala)
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
