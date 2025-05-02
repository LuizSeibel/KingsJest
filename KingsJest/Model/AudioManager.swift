//
//  AudioManager.swift
//  KingsJest
//
//  Created by Willys Oliveira on 02/05/25.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var engine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var pitchControl = AVAudioUnitTimePitch()
    
    init() {
        setup()
    }

    private func setup() {
        engine.attach(playerNode)
        engine.attach(pitchControl)
        
        engine.connect(playerNode, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        try? engine.start()
    }

    func playSound(named name: String, withRandomPitchIn range: ClosedRange<Float> = 900...1100) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else { return }
        let audioFile = try? AVAudioFile(forReading: url)
        guard let file = audioFile else { return }

        pitchControl.pitch = Float.random(in: range)

        playerNode.stop()
        playerNode.scheduleFile(file, at: nil, completionHandler: nil)
        playerNode.play()
    }
}
