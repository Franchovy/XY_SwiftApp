//
//  SegmentCameraViewController.swift
//  XY
//
//  Created by Maxime Franchot on 25/04/2021.
//

import UIKit
import AVFoundation

class SegmentCameraViewController: UIViewController {
    
    enum CameraState {
        case prepareToRecord
        case recording
        case finishedRecording
    }
    
    enum CameraDirection {
        case front
        case back
    }
    
    var cameraFacing:CameraDirection = .back
    var state:CameraState = .prepareToRecord
    
    // MARK: - UI Properties
    
    private var flipCameraButton = Button(image: UIImage(systemName: "arrow.triangle.2.circlepath.camera.fill"), style: .image)
    private var recordButton = Button(image: UIImage(systemName: "video.circle.fill"), style: .image)
    private var doneButton = Button(image: UIImage(systemName: "checkmark.circle.fill"), style: .image)
    private var previewView = UIView()
    
    // MARK: - AVFoundation properties
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureVideoDataOutput!
    
    private var _assetWriter: AVAssetWriter!
    private var _assetWriterInput: AVAssetWriterInput!
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _time: Double = 0
    var clips: [String] = []
    var audioPlayer: AVAudioPlayer?
    
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        
        // Make sure this device has an available rear camera and microphone
        guard let rearCamera = AVCaptureDevice.default(for: AVMediaType.video),
            let audioInput = AVCaptureDevice.default(for: AVMediaType.audio)
        else {
            print("Unable to access capture devices!")
            return
        }
        do {
            // Create the two AVCaptureDeviceInput
            let cameraInput = try AVCaptureDeviceInput(device: rearCamera)
            let audioInput = try AVCaptureDeviceInput(device: audioInput)
            // Create the AVCaptureVideoDataOutput
            let output = AVCaptureVideoDataOutput()

            if captureSession.canAddInput(cameraInput), captureSession.canAddInput(audioInput), captureSession.canAddOutput(output) {
                // Add inputs to capture session
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
                videoDeviceInput = cameraInput
                // Add output to capture session
                captureSession.addOutput(output)
                videoOutput = output
                // We will come back to this line
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "com.nidhi.tiktok.record"))
                // Set up the preview view
                setupLivePreview()
            }
        } catch {
            print("Error Unable to initialize inputs:  \(error.localizedDescription)")
        }
        
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
            x: (view.width - 40)/2,
            y: view.bottom - 40 - 25,
            width: 40,
            height: 40
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
    
    private enum _CaptureState {
        case idle, start, capturing, end
    }

    private var _captureState = _CaptureState.idle
    
    @objc private func recordButtonPressed() {
        switch _captureState {
            case .idle:
                _captureState = .start
            case .capturing:
                _captureState = .end
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
    
    public func startRecording() {
        if state == .prepareToRecord {
            
            state = .recording
        }
    }
    
    public func stopRecording(onCompletedProcessing: @escaping(URL) -> Void) {
        if state == .recording {
            state = .finishedRecording
            
        }
    }
    
    public func toggleFlash() {
        
    }
    
    public func switchCamera() {
        
    }
    
    public func deleteSegment() {
        
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

extension SegmentCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        
        switch _captureState {
        case .start:
            
            _filename = UUID().uuidString
            clips.append("\(_filename).mov")
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(_filename).mov")
            
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            let settings = videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi / 2)

            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }
            
            let startingTimeDelay = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1_000_000_000)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero + startingTimeDelay)

            _assetWriter = writer
            _assetWriterInput = input
            _adapter = adapter
            
            _captureState = .capturing
            _time = timestamp
        case .capturing:
            if _assetWriterInput?.isReadyForMoreMediaData == true {
                // Append the sample buffer at the correct time
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                _adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!, withPresentationTime: time)
            }
        case .end:
            // When we have finished recording, finish writing the video data to disk
            guard _assetWriterInput?.isReadyForMoreMediaData == true, _assetWriter!.status != .failed else { break }
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                // Move to the idle state once we are done writing
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
            }
        case .idle:
            break
        }
    }
}
