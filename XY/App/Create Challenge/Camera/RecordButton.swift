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
    
    init() {
        super.init(frame: .zero)
        
        setBackgroundColor(color: .lightGray, forState: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = height/2
    }
    
    public func setState(_ state: State) {
        setBackgroundColor(
            color: state == .recording ? .red : .lightGray,
            forState: .normal
        )
        
        recordingState = state
    }
}
