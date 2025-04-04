//
//  RootView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 28/03/25.
//

import SwiftUI

struct RootView: View{
    
    var body: some View{
        NavigationStack{
            //EndView(winBool: true)
            //GameView(connectionManager: MPCManager(yourName: "OI"))
            ContentView()
                .onAppear {
                    PermissionsManager.solicitarPermissaoMicrofone()
                }
        }
        
    }
}
