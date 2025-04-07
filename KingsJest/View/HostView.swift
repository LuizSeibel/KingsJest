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
    
    // Animation vars
    @State private var dotCount: Int = 0
    let maxDots = 3
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
                        
                        HStack{
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
                                .padding(.leading, 40)
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 30)
                        
                        startButton
                            .padding()
                        
//                        else {
//                            hud
//                        }
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
                if !isPresented && !viewModel.startGame{
                    viewModel.disconnect()
                }
            }
            
            // MARK: Invites Handler
//            .alert(isPresented: $viewModel.recievedInvite){
//                Alert(
//                    title: Text("Join request"),
//                    message: Text("\(viewModel.recievedInviteFrom?.displayName ?? "Anonymous") wants to join."),
//                    primaryButton: .default(Text("Accept"), action: {
//                        viewModel.acceptInvitation()
//                    }),
//                    secondaryButton: .cancel(Text("Reject"), action: {
//                        viewModel.rejectInvitation()
//                    })
//                )
//            }
            
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
                    viewModel.sendMessage()
                }, label: {
                    Text("Start")
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
            Text("Waiting for players \(String(repeating: ".", count: dotCount))")
                .foregroundStyle(.gray)
                .font(.custom("STSongti-TC-Bold", size: 26))
        }
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % (maxDots + 1)
        }
    }
}

#Preview {
    HostView(connectionManager: MPCManager(yourName: ""))
}
