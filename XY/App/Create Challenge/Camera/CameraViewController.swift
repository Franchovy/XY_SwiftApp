//
//  CameraViewController.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit
import CameraManager

class CameraViewController: UIViewController {
    
    enum CameraState {
        case prepareToRecord
        case recording
        case finishedRecording
    }
    
    var state:CameraState = .prepareToRecord
    
    private let cameraManager = CameraManager()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        cameraManager.cameraOutputMode = .videoWithMic
        cameraManager.cameraOutputQuality = .high
        
        cameraManager.shouldEnableExposure = false
        cameraManager.exposureMode = .continuousAutoExposure
        
        cameraManager.writeFilesToPhoneLibrary = false
        cameraManager.shouldRespondToOrientationChanges = false
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraManager.addPreviewLayerToView(view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    public func startRecording() {
        if state == .prepareToRecord {
            
            cameraManager.startRecordingVideo()
            state = .recording
        }
    }
    
    public func stopRecording(onCompletedProcessing: @escaping(URL) -> Void) {
        if state == .recording {
            state = .finishedRecording
            cameraManager.stopVideoRecording { (videoURL, error) in
                if let error = error {
                    self.displayTempLabel(
                        centerPoint: self.view.center,
                        labelText: error.localizedDescription,
                        labelColor: UIColor(named: "XYWhite")!
                    )
                } else if let videoURL = videoURL {
                    onCompletedProcessing(videoURL)
                }
            }
        }
    }
}
