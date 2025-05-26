//
//  JesterLoadingRun.swift
//  KingsJest
//
//  Created by Willys Oliveira on 26/05/25.
//

import SwiftUI

struct JesterLoadingRun: View {
    let color: ourColors = ourColors.allCases.filter { $0 != .none && $0 != .black}.randomElement()!
    let prefix = "RUN00"
    let frameCount = 7
    let frameRate = 0.1

    @State private var currentFrame = 0
    @State private var frames: [UIImage] = []
    @State private var timer: Timer?

    var body: some View {
        Group {
            if frames.indices.contains(currentFrame) {
                Image(uiImage: frames[currentFrame])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 68, height: 68)
            } else {
                Color.clear.frame(width: 100, height: 100)
            }
        }
        .onAppear {
            frames = loadFramesAsImages(prefix: prefix, count: frameCount, color: color)
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: frameRate, repeats: true) { _ in
            currentFrame = (currentFrame + 1) % frameCount
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func loadFramesAsImages(prefix: String, count: Int, color: ourColors) -> [UIImage] {
        var frames: [UIImage] = []
        let colors = ourColors.returnColors(color: color)
        
        for i in 0..<count {
            if let original = UIImage(named: "\(prefix)\(i)"),
               let colored = original.gradientMapImage(from: colors) {
                frames.append(colored)
            }
        }
        return frames
    }

}




#Preview {
    JesterLoadingRun()
}
