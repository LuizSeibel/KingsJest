//
//  RootView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 28/03/25.
//

import SwiftUI
import SpriteKit

struct RootView: View{
    
    @StateObject var appViewModel = RootViewModel()
    
    var body: some View{
        NavigationStack{
            //EndView(winBool: true)
//            GameView(connectionManager: MPCManager(yourName: "OI"))
            ContentView()
//            GameScenesViewControllerRepresentable(sceneType: .phaseTwo, finishGame: {}, onPlayerMove: {_ in })
//                .ignoresSafeArea()
            
        }
        .environmentObject(appViewModel)
    }
}
