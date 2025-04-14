//
//  HostView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 20/03/25.
//

import SwiftUI

struct MockPeerID {
    let displayName: String
}

struct HostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: HostViewModel

    @State private var playerNames: [String] = []
    
    private let removeInvitationsPublisher = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(connectionManager: MPCManager) {
        _viewModel = StateObject(wrappedValue: HostViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                background
                
                GeometryReader { geometry in
                    VStack {
                        Text("Room Overview")
                            .font(.custom("STSongti-TC-Bold", size: 32))
                            .foregroundStyle(Color(.gray1))
                            .padding(.top, 10)
                        
                        HStack(spacing: 10) {
                            PlayersGridView(players: $playerNames)
                                .frame(width: geometry.size.width * 0.45)
                                .offset(x: 10)
                            
                            CustomConnectionList(
                                peers: $viewModel.pendingInvitations,
                                onAccept: { peerID in
                                    viewModel.acceptInvitation(peerID: peerID)
                                },
                                onDecline: { peerID in
                                    viewModel.declineInvitation(peerID: peerID)
                                }
                            )
                            .frame(width: geometry.size.width * 0.45, height: geometry.size.height * 0.5)
                            .cornerRadius(20)
                        }
                        .padding(.top, 30)
                        
                        startButton
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                CustomBackButton()
                    .padding(.top, 40)
                    .padding(.leading, 50)
            }
            
            .onReceive(removeInvitationsPublisher) { _ in
                viewModel.removeExpiredInvites()
            }
            
            .onAppear {
                viewModel.onAppear()
                playerNames = viewModel.connectedPlayers.map { $0.displayName }
            }
            
            .onChange(of: viewModel.recentlyConnected){ value in
                if value{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        viewModel.recentlyConnected = false
                    }
                }
            }
            
            .onChange(of: viewModel.connectedPlayers) { newPeers in
                playerNames = newPeers.map { $0.displayName }
            }
            .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
                if !isPresented && !viewModel.startGame {
                    viewModel.disconnect()
                }
            }
            // Navegação para GameView quando o jogo for iniciado.
            .navigationDestination(isPresented: $viewModel.startGame) {
                GameView(connectionManager: viewModel.connectionManager)
                    .id(viewModel.gameSessionID)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension HostView {
    var startButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.startRoom()
                    PhaseOneController.didShowCountdownOnce = false
                }, label: {
                    Text(
                        viewModel.isConnected
                                    ? "Start Match"
                                    : (viewModel.recentlyConnected ? "Connecting" : "Play Solo")
                    )
                })
                .buttonStyle(CustomUIButtonStyle())
                .disabled(viewModel.recentlyConnected)
            }
        }
    }
    
    var background: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            Image("bricks2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    HostView(connectionManager: MPCManager(yourName: ""))
}
