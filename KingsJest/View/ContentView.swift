//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI


struct ContentView: View {
    var body: some View {
        NavigationStack {
            teste()
        }
    }
}

struct teste: View {
    @State var buttonPressed: Bool = false
    
    var body: some View {
        VStack{
            Button("vai para a fase", action: {
                buttonPressed.toggle()
            })
        }
        .navigationDestination(isPresented: $buttonPressed, destination: {
            PhaseOneViewControllerRepresentable()
                    .edgesIgnoringSafeArea(.all)
        })
    }
}
