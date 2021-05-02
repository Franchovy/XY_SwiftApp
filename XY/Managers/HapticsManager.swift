//
//  HapticsManager.swift
//  XY
//
//  Created by Maxime Franchot on 21/02/2021.
//

import Foundation
import UIKit
import CoreHaptics

final class HapticsManager {
    static let shared = HapticsManager()
    private init() { }
    
    public func vibrateForSelection() {
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
    
    public func vibrateImpact(for style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    public func vibrateImpact(with strength: CGFloat) {
        DispatchQueue.main.async {
            if let generator = self.generator {
                generator.impactOccurred(intensity: strength)
            } else {
                let generator = UIImpactFeedbackGenerator()
                generator.prepare()
                generator.impactOccurred(intensity: strength)
            }
        }
    }
    
    var generator: UIImpactFeedbackGenerator?
    public func beginImpactSession(with style: UIImpactFeedbackGenerator.FeedbackStyle) {
        generator = UIImpactFeedbackGenerator(style: style)
        generator!.prepare()
    }
    
    public func endImpactSession() {
        generator = nil
    }
    
    public func vibrateImpact() {
        guard let generator = generator else {
            return
        }
        
        DispatchQueue.main.async {
            generator.impactOccurred()
        }
    }
    
//    let hapticEngine: CHHapticEngine
//
//    init?() {
//        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
//        guard hapticCapability.supportsHaptics else {
//            return nil
//        }
//
//        do {
//            hapticEngine = try CHHapticEngine()
//        } catch let error {
//            print("Haptic engine Creation Error: \(error)")
//            return nil
//        }
//    }
//
//    public func playSlowVibrate() {
//        do {
//            let pattern = try slicePattern()
//            try hapticEngine.start()
//            let player = try hapticEngine.makePlayer(with: pattern)
//            try player.start(atTime: CHHapticTimeImmediate)
//
//            hapticEngine.notifyWhenPlayersFinished { _ in
//                return .stopEngine
//            }
//        } catch {
//            print("Failed to play slice: \(error)")
//        }
//
//    }
//
//    public func stopSlowVibrate() {
//        hapticEngine.stop(completionHandler: nil)
//    }
//
//    private func slicePattern() throws -> CHHapticPattern {
//        let slice = CHHapticEvent(
//            eventType: .hapticContinuous,
//            parameters: [
//                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.15),
//                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.15)
//            ],
//            relativeTime: 0)
//
//        return try CHHapticPattern(events: [slice], parameters: [])
//    }
}
