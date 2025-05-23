//
//  ContentView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 19/03/25.
//

import SpriteKit
import SwiftUI


struct ContentView: View {
    
    @Namespace private var animation
    
    @EnvironmentObject var appViewModel: RootViewModel
    
    @State private var showAlert = false
    @State private var showNicknameAlert = false
    @State private var showConfigMenu = false
    @State private var navigateToHost = false
    @State private var navigateToGuest = false
    
    @State private var backgroundColor = Color("gray_light")
    
    @Binding var warningBool: Bool
    @Binding var animationWarningBool: Bool
    
    private let nicknameLabels: [nicknameLabel] =
    [
        nicknameLabel(title: "Time to play your part!", placeholder: "Choose a nickname"),
        nicknameLabel(title: "Changing Personas?", placeholder: "Enter new nickname")
    ]
    
    @State private var indexNicknameLabel = 1
    
    let sizeClass = DeviceType.current()
    
    var body: some View {
        ZStack {
            WarningView()
                .opacity(animationWarningBool ? 1.0 : 0.0)
            
            if showNicknameAlert && !warningBool{
                nicknameAlert
            }
            
            if showConfigMenu && !warningBool{
                menu
            }
            
            VStack{
                if !warningBool{
                    // esse vem da direita para a esquerda
                    VStack{
                        hud
                            .hideKeyboardWhenTapped()
                        
                        
                        
                    }
                }
            }
            
            if !warningBool{
                configButton
            }
            
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                Task{
                    if animationWarningBool{
                        withAnimation{
                            animationWarningBool = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                            withAnimation{
                                warningBool = false
                            }
                        }
                    }
                    if appViewModel.isFirstLaunch {
                        showNicknameAlert = true
                        indexNicknameLabel = 0
                    }
                }
                
            }
        }
        .background {
            background
        }
        .ignoresSafeArea(.all)
        .ignoresSafeArea(.keyboard)
        
        
        // MARK: Alert
        
        .alert("Don’t Stay Anonymous!", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enter a nickname to continue.")
        }
        
        // MARK: Navigation
        // Testar com um arquio de View
        
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - UI Components & Layout
extension ContentView{
    var hud: some View {
        ZStack{
            VStack (spacing: 0){
                GeometryReader { geometry in
                    Image("GameName")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.52)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 10)
                }
                .frame(height: {
                    switch sizeClass {
                    case .iPhone:
                        return 200
                    case .iPadMini:
                        return 350
                    case .iPad:
                        return 500
                    }
                }())
                buttons
                Spacer()
            }
            .opacity(showConfigMenu || showNicknameAlert ? 0 : 1)

            
        }
        .padding(.vertical)
    }
    
    var background: some View {
        ZStack{
            backgroundColor
            VStack{
                Spacer()
                Image("homeIlustration")
                    .resizable()
                    .scaledToFit()
            }
            
            if warningBool{
                Color.black.opacity(0.4)
                    .opacity(animationWarningBool ? 1.0 : 0.0)
            }
        }
        .ignoresSafeArea()
    }
    
    var buttons: some View {
        VStack (spacing: 16){
            Button(action: {
                if appViewModel.name.isEmpty {
                    showAlert = true
                } else {
                    Task{
                        appViewModel.createManagerIfNeeded()
                        appViewModel.path.append(.joinRoom)
                    }
                }
            }, label: {
                ZStack {
                    Image("SubtractMainRedDark")
                    Text("Join Room")
                }
            })
            .buttonStyle(CustomUIButtonStyle(isDarkMode: true, backgroundColor: Color.redLight, textColor: Color.beigeMain, fontSize: 30, maxWidth: 220, maxHeight: 52))

            
            Button(action: {
                if appViewModel.name.isEmpty {
                    showAlert = true
                } else {
                    Task{
                        appViewModel.createManagerIfNeeded()
                        appViewModel.path.append(.createRoom)
                    }
                }
            }, label: {
                ZStack {
                    Image("SubtractSecondaryRedDark")
                    Text("Create Room")
                }
            })
            .buttonStyle(CustomUIButtonStyle(isDarkMode: true, backgroundColor: Color.redDark, textColor: Color.beigeMain, fontSize: 30, maxWidth: 220, maxHeight: 52))
        }
    }
    
    var menu: some View{
        ZStack{
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation{
                        showConfigMenu = false
                    }
                }
            
            ConfigMenu(showNicknameAlert: $showNicknameAlert, showConfigMenu: $showConfigMenu)
                .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.2), value: showConfigMenu)
        .zIndex(2)
    }

    
    var nicknameAlert: some View{
        ZStack{
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            NicknameAlert(label: nicknameLabels[indexNicknameLabel].title, placeholder: nicknameLabels[indexNicknameLabel].placeholder, text: $appViewModel.name, onDismiss: {
                withAnimation {
                    if appViewModel.isFirstLaunch {
                        showConfigMenu = false
                        appViewModel.isFirstLaunch = false
                    } else {
                        showConfigMenu = true
                    }
                    showNicknameAlert = false
                    indexNicknameLabel = 1
                }
            })
            
            .frame(width: {
                switch sizeClass {
                case .iPhone:
                    return 450
                case .iPadMini:
                    return 500
                case .iPad:
                    return 500
                }
            }())
            .onAppear{
                withAnimation{
                    showConfigMenu = false
                }
            }
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.2), value: showNicknameAlert)
        .zIndex(3)
    }
    
    var configButton: some View {
        VStack {
            HStack {
                Spacer()

                Button(action: {
                    withAnimation {
                        showConfigMenu = true
                    }
                }) {
                    Image("SettingsButton")
                }
                .padding(.trailing, sizeClass == .iPhone ? 72 : 42)
                .padding(.top, sizeClass == .iPhone ? 28 : 42)
                .opacity(showConfigMenu || showNicknameAlert ? 0 : 1)
            }

            Spacer()
        }
    }
}

#Preview {
    NavigationStack{
        ContentView(warningBool: .constant(true), animationWarningBool: .constant(true))
            .environmentObject(RootViewModel())
    }
}
