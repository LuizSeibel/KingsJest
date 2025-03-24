//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import Foundation
import SwiftUI

struct ContentView: View {
    
    @AppStorage("userNickname") private var name: String = ""
    
    @State private var showAlert = false
    @State private var navigateToHost = false
    @State private var navigateToGuest = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                background
                
                Nickname(text: $name)
                    .padding(.top, 50)
                    .padding(.leading, 50)
                    .frame(width: 200)
                
                hud
            }
            .alert("Don’t Stay Anonymous!", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a nickname to continue.")
            }
            
            // MARK: Navigation
            .navigationDestination(isPresented: $navigateToHost){
                if navigateToHost{
                    HostView(connectionManager: MPCManager(yourName: name))
                }
                else{
                    EmptyView()
                }
            }
            .navigationDestination(isPresented: $navigateToGuest){
                if navigateToGuest{
                    GuestView(connectionManager: MPCManager(yourName: name))
                }
                else{
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - UI Components & Layout
extension ContentView{
    var hud: some View {
        VStack{
            GeometryReader { geometry in
                Image("GameName")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.3)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2 - 20)
            }
            buttons
        }
        .padding(.vertical)
    }
    
    var background: some View {
        ZStack{
            Color("BackgroundColor")
                .ignoresSafeArea()
            Image("bricks1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
    
    var buttons: some View {
        VStack{
            Button(action: {
                if self.name.isEmpty{
                    showAlert = true
                }
                else{
                    navigateToGuest.toggle()
                }
            }, label: {
                Text("Join Room")
            })
            
            Button(action: {
                if self.name.isEmpty{
                    showAlert = true
                }
                else{
                    navigateToHost.toggle()
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
