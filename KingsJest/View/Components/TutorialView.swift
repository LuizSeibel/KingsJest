//
//  TutorialView.swift
//  KingsJest
//
//  Created by Luiz Seibel on 23/05/25.
//

import SwiftUI

struct TutorialView: View{
    let sceneType: GameSceneType
    @State private var progress: CGFloat = 0
    
    @State private var tiltAngle: Double = -5
    
    var body: some View{
        switch sceneType {
        case .phaseOne:
            phaseOneTutorial()
        case .phaseTwo:
            Color.red1
        }
    }
    
    @ViewBuilder
    func phaseOneTutorial() -> some View{
        ZStack{
            background
                .onAppear {
                    progress = 1
                }
            VStack {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(height: 5)
                            .foregroundColor(.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: geometry.size.width * progress, height: 5)
                            .foregroundColor(.redLight)
                            .animation(.linear(duration: 5), value: progress)
                    }
                }
                .frame(height: 5)
                
               

                Spacer()
            }
            VStack{
                
                Spacer()
                Spacer()
                
                Image("phaseOneTutorial")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.6,
                           height: UIScreen.main.bounds.height * 0.5)
                    .rotationEffect(.degrees(tiltAngle))
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            tiltAngle = 5
                        }
                        progress = 1
                    }
                
                Spacer()
                VStack{
                    HStack(spacing: 0) {
                        Text("Tilt your phone ")
                            .tutorialTextStyle()
                        Text("left or right to move the character")
                            .tutorialTextStyle(color: .secondary)
                    }
                    
                    HStack(spacing: 0) {
                        Text("tap the screen ")
                            .tutorialTextStyle()
                        Text("to jump")
                            .tutorialTextStyle(color: .secondary)
                    }
                }
                .padding()
                
                Spacer()
                
            }
            
        }
        
        
    }
    
    
    var background: some View {
        ZStack{
            Color(.grayMain)
                .ignoresSafeArea()
        }
    }
    
}

#Preview{
    TutorialView(sceneType: .phaseOne)
}
