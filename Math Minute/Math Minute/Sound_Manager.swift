//
//  Sound_Manager.swift
//  Math Minute
//
//  Created by Justin Gangaram on 8/8/25.
//

import Foundation
import AVFoundation
import UIKit

final class SoundManager {
    static let shared = SoundManager()
    private var correctPlayer: AVAudioPlayer?
    private var wrongPlayer: AVAudioPlayer?
    private var tickPlayer: AVAudioPlayer?

    private init() {
        correctPlayer = makePlayer(named: "correct", ext: "wav")
        wrongPlayer = makePlayer(named: "wrong", ext: "wav")
        tickPlayer = makePlayer(named: "tick", ext: "mp3")
        tickPlayer?.numberOfLoops = -1 // loop tick during countdown
    }

    private func makePlayer(named: String, ext: String) -> AVAudioPlayer? {
        guard let url = Bundle.main.url(forResource: named, withExtension: ext) else { return nil }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.prepareToPlay()
            return p
        } catch {
            print("Sound error:", error)
            return nil
        }
    }

    func playCorrect() {
        correctPlayer?.play()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func playWrong() {
        wrongPlayer?.play()
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    func startTick() {
        tickPlayer?.currentTime = 0
        tickPlayer?.play()
    }

    func stopTick() {
        tickPlayer?.stop()
    }
}
