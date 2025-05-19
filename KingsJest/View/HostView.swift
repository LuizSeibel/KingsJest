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
    @EnvironmentObject var appViewModel: RootViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: HostViewModel

    @State private var playerNames: [String] = []
    
    private let removeInvitationsPublisher = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    init(connectionManager: MPCManager) {
        _viewModel = StateObject(wrappedValue: HostViewModel(connectionManager: connectionManager))
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            background
            
            VStack(spacing: 16) {
                Title("Room Overview")
                
                Spacer()
                PlayersAndInvites(playerNames: $viewModel.players, viewModel: viewModel)
                Spacer()
                
                startButton
                    .padding(.bottom, 12)
                    .padding(.horizontal, 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 28)
            
            CustomBackButton()
                .padding(.top, 40)
                .padding(.horizontal)
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
        .onChange(of: viewModel.startGame){ value in
            if value{
                appViewModel.path.append(.game(connectionManager: viewModel.connectionManager, players: viewModel.players))
            }
        }
//        .navigationDestination(isPresented: $viewModel.startGame) {
//            GameView(connectionManager: viewModel.connectionManager, players: viewModel.players)
//                .id(viewModel.gameSessionID)
//        }
    }
}

extension HostView {
    var startButton: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.startRoom()
//                    PhaseOneController.didShowCountdownOnce = false
            }, label: {
                ZStack {
                    Image("SubtractMainRedDark")
                    Text(
                        viewModel.isConnected
                        ? "Start Match"
                        : (viewModel.recentlyConnected ? "Connecting" : "Play Solo")
                    )
                }
            })
            .buttonStyle(CustomUIButtonStyle(isDarkMode: true, backgroundColor: Color.redLight, textColor: Color.beigeMain, fontSize: 30, maxWidth: 200, maxHeight: 47))
            .disabled(viewModel.recentlyConnected)
        }
    }
    
    var background: some View {
        ZStack {
            Color.grayMain
                .ignoresSafeArea()
//            Image("bricks2")
//                .resizable()
//                .scaledToFill()
//                .ignoresSafeArea()
        }
    }
}

#Preview {
    HostView(connectionManager: MPCManager(yourName: ""))
}

private struct Title: View {
    var text: LocalizedStringKey
    init(_ text: LocalizedStringKey) { self.text = text }

    var body: some View {
        Text(text)
            .font(.custom("ø", size: 32))
            .foregroundStyle(Color.beigeMain)
    }
}

private struct PlayersAndInvites: View {
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Binding var playerNames: [PlayerIdentifier]
    @ObservedObject var viewModel: HostViewModel

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top, spacing: 20) {

                PlayersGridView(players: $playerNames)
                    .frame(
                        width: proxy.size.width * playerColumnRatio
                    )
//                    .offset(y: 12)

                CustomConnectionList(
                    peers: $viewModel.pendingInvitations,
                    onAccept: viewModel.acceptInvitation,
                    onDecline: viewModel.declineInvitation
                )
                
                .frame(
                    width: proxy.size.width * inviteColumnRatio,
                    height: proxy.size.height * 1
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxHeight: .infinity)
    }
    
    private var playerColumnRatio: CGFloat { hSizeClass == .regular ? 0.45 : 0.50 }
    private var inviteColumnRatio: CGFloat { hSizeClass == .regular ? 0.50 : 0.45 }
}
