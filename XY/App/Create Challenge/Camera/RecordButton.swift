//
//  RecordButton.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit
import CameraManager

class RecordButton: UIButton {
    
    enum State {
        case recording
        case notRecording
    }
    private var recordingState:State = .notRecording
    
    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor(0xF2F2F2).cgColor
        layer.lineWidth = 5
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }()
    
    private let centerLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(0xF23333).cgColor
        return layer
    }()
    
    init() {
        super.init(frame: .zero)
        
        layer.addSublayer(borderLayer)
        layer.addSublayer(centerLayer)
        
        layer.backgroundColor = UIColor.clear.cgColor
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        centerLayer.path = getCenterLayerPathForState(recordingState)
        borderLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    private func getCenterLayerPathForState(_ state: State) -> CGPath {
        return state == .notRecording ?
            UIBezierPath(roundedRect: bounds.insetBy(dx: 6, dy: 6), cornerRadius: height/2).cgPath :
            UIBezierPath(roundedRect: bounds.insetBy(dx: height/4, dy: height/4), cornerRadius: 5).cgPath
    }
    
    public func setState(_ state: State) {
        guard recordingState != state else {
            return
        }
        
        // Animate path from square to circle or vice versa
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.2
        
        animation.fromValue = getCenterLayerPathForState(recordingState)
        animation.toValue = getCenterLayerPathForState(state)
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = true
        
        centerLayer.add(animation, forKey: nil)
        recordingState = state
    }
}
