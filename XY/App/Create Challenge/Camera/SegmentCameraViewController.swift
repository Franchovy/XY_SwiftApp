//
//  SegmentCameraViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/04/2021.
//

import UIKit
import AVFoundation

class SegmentCameraViewController: UIViewController, VideoWriterDelegate {
    
    enum CameraState {
        case recording
        case ending
        case idle
    }
    
    enum CameraDirection {
        case front
        case back
    }
    
    var cameraFacing:CameraDirection = .back
    var state:CameraState = .idle
    
    // MARK: - UI Properties
    
    private var flipCameraButton = Button(image: UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill"), style: .image)
    private var recordButton = RecordButton()
    private var doneButton = Button(image: UIImage(systemName: "checkmark.circle.fill"), style: .image)
    private var previewView = UIView()
    
    // MARK: - AVFoundation properties
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    fileprivate var videoWriter: VideoWriter?
    
    var videoConnection: AVCaptureConnection?
    var audioConnection: AVCaptureConnection?
    
    private var _assetWriter: AVAssetWriter!
    private var _assetWriterInput: AVAssetWriterInput!
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _time: Double = 0
    var clips: [String] = []
    var audioPlayer: AVAudioPlayer?
    
    var screenDimensions: (Int, Int) = (0, 0)
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(previewView)
        view.addSubview(flipCameraButton)
        view.addSubview(doneButton)
        view.addSubview(recordButton)
        
        flipCameraButton.addTarget(self, action: #selector(flipCameraButtonPressed), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(recordButtonPressed), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        
        screenDimensions = (Int(view.width), Int(view.height))
        
        captureSession = AVCaptureSession()
        
        // Make sure this device has an available rear camera and microphone
        guard let rearCamera = AVCaptureDevice.default(for: AVMediaType.video),
              let audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
        else {
            print("Unable to access capture devices!")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Create the two AVCaptureDeviceInput
                let cameraInput = try AVCaptureDeviceInput(device: rearCamera)
                let audioInput = try AVCaptureDeviceInput(device: audioInput)
                
                // Create the AVCaptureVideoDataOutput
                if self.captureSession.canAddInput(cameraInput), self.captureSession.canAddInput(audioInput) {
                    // Add inputs to capture session
                    self.captureSession.addInput(cameraInput)
                    self.captureSession.addInput(audioInput)
                    self.videoDeviceInput = cameraInput
                    
                    // Set up the preview view
                    DispatchQueue.main.async {
                        self.setupLivePreview()
                    }
                }
            } catch {
                print("Error Unable to initialize inputs:  \(error.localizedDescription)")
            }
            
            do {
                let videoDataOutput = AVCaptureVideoDataOutput()
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: NSNumber(value: kCVPixelFormatType_32BGRA)]
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                let queue = DispatchQueue(label: "com.shu223.videosamplequeue")
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                guard self.captureSession.canAddOutput(videoDataOutput) else {
                    fatalError()
                }
                self.captureSession.addOutput(videoDataOutput)
                
                self.videoConnection = videoDataOutput.connection(with: .video)
                self.videoConnection?.videoOrientation = .portrait
            }
            
            // setup audio output
            do {
                let audioDataOutput = AVCaptureAudioDataOutput()
                let queue = DispatchQueue(label: "com.shu223.audiosamplequeue")
                audioDataOutput.setSampleBufferDelegate(self, queue: queue)
                guard self.captureSession.canAddOutput(audioDataOutput) else {
                    fatalError()
                }
                self.captureSession.addOutput(audioDataOutput)
                
                self.audioConnection = audioDataOutput.connection(with: .audio)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
        } catch let error {
            print(error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewView.frame = view.bounds
        
        recordButton.frame = CGRect(
            x: (view.width - 80)/2,
            y: view.bottom - 80 - 25,
            width: 80,
            height: 80
        )
        
        flipCameraButton.frame = CGRect(
            x: view.width - 20 - 15,
            y: 15,
            width: 20,
            height: 20
        )
        
        doneButton.frame = CGRect(
            x: flipCameraButton.left - 15 - 20,
            y: 15,
            width: 20,
            height: 20
        )
    }
    
    // MARK: - Private Camera Setup Methods
    
    func setupLivePreview() {
        // Create a new AVCaptureVideoPreviewLayer from our capture session
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        // Insert this sublayer into our previewView's layer
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        // On a background queue, start the capture session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
            // Make sure to set the frame of the preview layer on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    // MARK: - Objc private functions
    
    
    @objc private func recordButtonPressed() {
        switch state {
        case .idle:
            state = .recording
            videoWriter?.start()
            recordButton.setState(.recording)
        case .recording:
            state = .ending
            videoWriter?.stop()
            recordButton.setState(.notRecording)
        default:
            break
        }
    }
    
    @objc private func flipCameraButtonPressed() {
        guard let newInputDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: cameraFacing == .back ? .front : .back
        ) else { return }
        
        cameraFacing = cameraFacing == .back ? .front : .back
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                
                // Create the two AVCaptureDeviceInput
                let cameraInput = try AVCaptureDeviceInput(device: newInputDevice)
                
                self.captureSession.beginConfiguration()
                self.captureSession.removeInput(self.videoDeviceInput)
                
                if self.captureSession.canAddInput(cameraInput) {
                    self.captureSession.addInput(cameraInput)
                    
                    self.videoDeviceInput = cameraInput
                    
                    self.captureSession.outputs.forEach( { output in
                        if let videoOutput = output as? AVCaptureVideoDataOutput {
                            videoOutput.connections.forEach({ $0.videoOrientation = .portrait })
                        }
                    })
                    
                    self.captureSession.commitConfiguration()
                }
            } catch {
                print("Error Unable to initialize inputs:  \(error.localizedDescription)")
            }
        }
    }
    
    @objc private func doneButtonPressed() {
        self.mergeSegmentsAndUpload(clips: clips)
    }
    
    // MARK: - Public Methods
    
    public func toggleFlash() {
        
    }
    
    public func switchCamera() {
        
    }
    
    // MARK: - Video manipulation functions
    
    func mergeSegmentsAndUpload(clips _: [String]) {
        DispatchQueue.main.async {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                VideoCompositionWriter().mergeAudioVideo(dir, filename: "\(self._filename).mov", clips: self.clips) { success, outUrl in
                    if success {
                        if let outURL = outUrl {
                            let previewVC = PreviewViewController(previewVideoURL: outURL)
                            self.navigationController?.pushViewController(previewVC, animated: true)
                        }
                    }
                }
            }
        }
    }
}

extension SegmentCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        
        let isVideo = captureOutput is AVCaptureVideoDataOutput
        if videoWriter == nil {
            if !isVideo {
                if let fmt = CMSampleBufferGetFormatDescription(sampleBuffer) {
                    if let asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt) {
                        let channels = Int(asbd.pointee.mChannelsPerFrame)
                        let samples = asbd.pointee.mSampleRate
                        
                        videoWriter = VideoWriter(height: 1280, width: 720, channels: channels, samples: samples, recordingTime: 5)
                        videoWriter?.delegate = self
                    }
                }
            }
        }
        
        guard state == .recording || state == .ending else { return }

        if videoWriter != nil {
            videoWriter?.write(sampleBuffer: sampleBuffer, isVideo: isVideo)
        }
    }

    func changeRecordingTime(s: Int64) {

    }
    
    func finishRecording(fileUrl: URL) {
        state = .idle
        let vc = PreviewViewController(previewVideoURL: fileUrl)
        navigationController?.pushViewController(vc, animated: true)
    }
}
