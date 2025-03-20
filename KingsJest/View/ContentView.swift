//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    @State var name: String = ""
    @State private var showAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                hud()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Nickname(text: $name)
                        .padding(.top, 40)
                        .frame(width: 160, height: 44)
                }
            }
            .alert("Don’t Stay Anonymous!", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a nickname to continue.")
            }
        }
    }
}

extension ContentView{
    
    func hud() -> some View {
        VStack{
            GeometryReader { geometry in
                Image("GameName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.3)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 5)
            }
            buttons
        }
        .padding(.vertical)
    }
    
    var buttons: some View {
        VStack{
            Button(action: {
                if self.name.isEmpty{
                    showAlert = true
                }
                else{
                    print("Join Room")
                }
            }, label: {
                Text("Join Room")
            })
            
            Button(action: {
                if self.name.isEmpty{
                    showAlert = true
                }
                else{
                    print("New Room")
                }
            }, label: {
                Text("New Room")
            })
        }
        .buttonStyle(CustomUIButtonStyle())
    }
}

#Preview {
    ContentView()
}
