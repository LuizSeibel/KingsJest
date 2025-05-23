//
//  RootView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 28/03/25.
//

import SwiftUI
import SpriteKit

enum Destination: Hashable {
    case createRoom
    case joinRoom
    case game(connectionManager: MPCManager, players: [PlayerIdentifier])
    case end(win: Bool, winnerName: String)
    case settings
}

struct RootView: View{
    
    @StateObject var appViewModel = RootViewModel()

    var body: some View{
        
        NavigationStack(path: $appViewModel.path){
            //EndView(winBool: true)
//            GameView(connectionManager: MPCManager(yourName: "OI"))
            
//            GameScenesViewControllerRepresentable(sceneType: .phaseTwo, finishGame: {}, onPlayerMove: {_,_,_  in })
//                .ignoresSafeArea()
//            
            ContentView()
                .navigationBarBackButtonHidden()
                .navigationDestination(for: Destination.self) { destination in
                    Group {
                        switch destination {
                        case .createRoom:
                            if let mpc = appViewModel.manager {
                                HostView(connectionManager: mpc)
                            }
                        case .joinRoom:
                            if let mpc = appViewModel.manager {
                                GuestView(connectionManager: mpc)
                            }
                        case .game(let connectionManager, let players):
                            GameView(connectionManager: connectionManager, players: players)
                            //                            .id(viewModel.gameSessionID)
                        case .end(let win, let winnerName):
                            EndView(winBool: win, winnerName: winnerName)
                        case .settings:
                            Text("settings")
                        }
                    }
                    .navigationBarBackButtonHidden()
                }
        }
        .environmentObject(appViewModel)
    }
}



extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let blue = CGFloat(rgb & 0x0000FF) / 255

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
