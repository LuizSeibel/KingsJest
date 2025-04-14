//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI


struct ContentView: View {
    @EnvironmentObject var appViewModel: RootViewModel
    
    @State private var showAlert = false
    @State private var navigateToHost = false
    @State private var navigateToGuest = false
    
    var body: some View {
        VStack(alignment: .leading){
           
            Nickname(text: $appViewModel.name)
                .padding(.top, 50)
                .padding(.leading, 50)
                .frame(width: 200)
        
            hud
                .hideKeyboardWhenTapped()
            
            
        }
        .background{
                background
                    .hideKeyboardWhenTapped()
                    .ignoresSafeArea(.all)
        }
        .ignoresSafeArea(.keyboard)
        
        .alert("Don’t Stay Anonymous!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a nickname to continue.")
        }
        
        // MARK: Navigation
        // Testar com um arquio de View
        .navigationDestination(isPresented: $navigateToHost) {
            if let mpc = appViewModel.manager {
                HostView(connectionManager: mpc)
            } else {
                EmptyView()
            }
        }
        
        .navigationDestination(isPresented: $navigateToGuest) {
            if let mpc = appViewModel.manager {
                GuestView(connectionManager: mpc)
            } else {
                EmptyView()
            }
        }
        .navigationBarBackButtonHidden(true)
    
        
    }
}

// MARK: - UI Components & Layout
extension ContentView{
    var hud: some View {
        ZStack{
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
            
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    SendFeedbackButton()
                }
            }
        }
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
                if appViewModel.name.isEmpty {
                    showAlert = true
                } else {
                    Task{
                        appViewModel.createManagerIfNeeded()
                        navigateToGuest.toggle()
                    }
                }
            }, label: {
                Text("Join Room")
            })
            
            Button(action: {
                if appViewModel.name.isEmpty {
                    showAlert = true
                } else {
                    Task{
                        appViewModel.createManagerIfNeeded()
                        navigateToHost.toggle()
                    }
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
