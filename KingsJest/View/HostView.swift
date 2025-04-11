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
    
    @State var disableStartButton: Bool = false
    
    // Animation Connecting Peer
    let maxDots = 3
    @State var connectingPeerString: String = "Connecting Peer"
    @State private var dotCount: Int = 0
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    init(connectionManager: MPCManager){
        _viewModel = StateObject(wrappedValue: HostViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .topLeading) {
                background
                
                GeometryReader { geometry in
                    ZStack {
                        VStack{
                            Text("Room Overview")
                                .font(.custom("STSongti-TC-Bold", size: 32))
                                .foregroundStyle(Color(.gray1))
                                .offset(y: 10)
                                .padding()
                            HStack(spacing: 10){
                                // TODO: Colocar verificação de players no startButton
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                CustomBackButton()
                    .padding(.top, 40)
                    .padding(.leading, 50)
                
            }
            
            // MARK: View States
            
            .onReceive(timer) { _ in
                viewModel.removeExpiredInvites()
            }
            
            .onAppear {
                viewModel.onAppear()
                playerNames = viewModel.connectedPlayers.map { $0.displayName }
            }
            .onChange(of: viewModel.connectedPlayers) { newPeers in
                playerNames = newPeers.map { $0.displayName }
                
                
            }
            
            .onChange(of: viewModel.connectedNewPeer) { value in
                
                if value{
                    disableStartButton = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        disableStartButton = false
                        viewModel.connectedNewPeer = false
                    }
                }
            }
            
            .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
                if !isPresented && !viewModel.startGame{
                    viewModel.disconnect()
                }
            }
            
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % (maxDots + 1)
            }
            
            // MARK: Navigation
            .navigationDestination(isPresented: $viewModel.startGame) {
                GameView(connectionManager: viewModel.connectionManager)
                    .id(viewModel.gameSessionID)
            }
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
                    viewModel.startRoom()
                    PhaseOneController.didShowCountdownOnce = false
                }, label: {
                    Text(disableStartButton ? "\(connectingPeerString)\(String(repeating: ".", count: dotCount))" : viewModel.isConnected ? "Start Match" : "Play Solo")
                })
                .buttonStyle(CustomUIButtonStyle())
                .disabled(disableStartButton)
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
}

#Preview {
    HostView(connectionManager: MPCManager(yourName: ""))
}
