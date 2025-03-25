//
//  HostView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct HostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: HostViewModel
    
    @State private var playerNames: [String] = []
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: HostViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .topLeading) {
                background
                
                GeometryReader { geometry in
                    ZStack {
                        if viewModel.isConnected{
                            PlayersGridView(players: $playerNames)
                                .frame(width: geometry.size.width * 0.8)
                            
                            startButton
                                .padding()
                        }
                        else {
                            hud
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                
                CustomBackButton()
                    .padding(.top, 40)
                    .padding(.leading, 50)
                
                
            }
            
            // MARK: View States
            .onAppear {
                viewModel.onAppear()
                playerNames = viewModel.connectedPlayers.map { $0.displayName }
            }
            .onChange(of: viewModel.connectedPlayers) { newPeers in
                playerNames = newPeers.map { $0.displayName }
            }
            
            .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
                if !isPresented && !viewModel.goToGame{
                    viewModel.disconnect()
                }
            }
            
            // MARK: Invites Handler
            .alert(isPresented: $viewModel.recievedInvite){
                Alert(
                    title: Text("Join request"),
                    message: Text("\(viewModel.recievedInviteFrom?.displayName ?? "Anonymous") wants to join."),
                    primaryButton: .default(Text("Accept"), action: {
                        viewModel.acceptInvitation()
                    }),
                    secondaryButton: .cancel(Text("Reject"), action: {
                        viewModel.rejectInvitation()
                    })
                )
            }
            
            // MARK: Navigation
            .navigationDestination(isPresented: $viewModel.startGame, destination: {
                GameView()
            })
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension HostView{
    
    var startButton: some View{
        VStack{
            Spacer()
            HStack{
                Spacer()
                Button(action: {
                    viewModel.sendMessage()
                }, label: {
                    Text("Start Room")
                })
                .buttonStyle(CustomUIButtonStyle())
            }
        }
    }
    
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
    
    var hud: some View {
        VStack(alignment: .center){
            Image("coroa")
            Text("Waiting for players...")
                .foregroundStyle(.gray)
                .font(.custom("STSongti-TC-Bold", size: 26))
        }
    }
}

#Preview {
    HostView(connectionManager: MPCManager(yourName: ""))
}
