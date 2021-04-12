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
    private var recordingState:State = .recording
    
    private let borderLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor(0xF2F2F2).cgColor
        layer.lineWidth = 5
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        drawPathForRecordButton()
        
        borderLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    }
    
    func drawPathForRecordButton() {
        centerLayer.path = recordingState == .notRecording ?
            UIBezierPath(roundedRect: bounds.insetBy(dx: height/2, dy: height/2), cornerRadius: 5).cgPath :
            UIBezierPath(ovalIn: bounds.insetBy(dx: 6, dy: 6)).cgPath
        
    }
    
    public func setState(_ state: State) {
        recordingState = state
        
        UIView.animate(withDuration: 0.4) {
            self.drawPathForRecordButton()
        }
    }
}
