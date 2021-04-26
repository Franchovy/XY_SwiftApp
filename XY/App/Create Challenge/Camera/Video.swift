//
//  Video.swift
//  XY
//
//  Created by Maxime Franchot on 26/04/2021.
//

//
//  VideoWriter.swift
//  AVCaptureVideoDataOutputSample_Concatenation
//
//  Created by hirauchi.shinichi on 2017/01/06.
//  Copyright © 2017年 SAPPOROWORKS. All rights reserved.
//
import UIKit
import AVFoundation


protocol VideoWriterDelegate {
    // 録画時間の更新
    func changeRecordingTime(s: Int64)
    // 録画終了
    func finishRecording(fileUrl: URL)
}

class VideoWriter : NSObject {
    
    var delegate: VideoWriterDelegate?
    
    fileprivate var writer: AVAssetWriter!
    fileprivate var videoInput: AVAssetWriterInput!
    fileprivate var audioInput: AVAssetWriterInput!
    
    fileprivate var lastTime: CMTime! // 最後に保存したデータのPTS
    fileprivate var offsetTime = CMTime.zero // オフセットPTS(開始を0とする)
    fileprivate var recordingTime:Int64 = 0 // 録画時間
    
    fileprivate enum Status {
        case Start // 初期化時
        case Write // 書き込み中
        case Pause // 一時停止
        case Restart // 一時停止からの復帰
        case End // データ保存完了
    }
    
    fileprivate var status = Status.Start
    
    var shouldStop = false
    
    init(height:Int, width:Int, channels:Int, samples:Float64, recordingTime:Int64){
        
        self.recordingTime = recordingTime
        
        // データ保存のパスを生成
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath : String? = "\(documentsDirectory)/\(UUID().uuidString).mov"
        if FileManager.default.fileExists(atPath: filePath!) {
            try? FileManager.default.removeItem(atPath: filePath!)
        }

        // AVAssetWriter生成
        writer = try? AVAssetWriter(outputURL: URL(fileURLWithPath: filePath!), fileType: AVFileType.mov)
        
        // Video入力
        let videoOutputSettings: Dictionary<String, AnyObject> = [
            AVVideoCodecKey : AVVideoCodecType.h264 as AnyObject,
            AVVideoWidthKey : width as AnyObject,
            AVVideoHeightKey : height as AnyObject
        ];
        videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        writer.add(videoInput)
        
        // Audio入力
        let audioOutputSettings: Dictionary<String, AnyObject> = [
            AVFormatIDKey : kAudioFormatMPEG4AAC as AnyObject,
            AVNumberOfChannelsKey : channels as AnyObject,
            AVSampleRateKey : samples as AnyObject,
            AVEncoderBitRateKey : 128000 as AnyObject
        ]
        audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInput.expectsMediaDataInRealTime = true
        writer.add(audioInput)
    }
    
    func RecodingTime() -> CMTime {
        return CMTimeSubtract(lastTime, offsetTime)
    }
    
    func write(sampleBuffer: CMSampleBuffer, isVideo: Bool){
        
        if writer.status == .failed {
            fatalError()
        }
        
        if status == .Start || status == .End || status == .Pause {
            return
        }

        // 一時停止から復帰した場合は、一時停止中の時間をoffsetTimeに追加する
        if status == .Restart {
            let timeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) // 今取得したデータの時間
            let spanTime = CMTimeSubtract(timeStamp, lastTime) // 最後に取得したデータとの差で一時停止中の時間を計算する
            offsetTime = CMTimeAdd(offsetTime, spanTime) // 一時停止中の時間をoffsetTimeに追加する
            status = .Write
        }
        
        if CMSampleBufferDataIsReady(sampleBuffer) {

            // 開始直後は音声データのみしか来ないので、最初の動画が来てから書き込みを開始する
            if isVideo && writer.status == .unknown {
                offsetTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) // 開始時間を0とするために、開始時間をoffSetに保存する
                writer?.startWriting()
                writer?.startSession(atSourceTime: CMTime.zero) // 開始時間を0で初期化する
            }
            
            if writer.status == .writing {
                
                // PTSの調整（offSetTimeだけマイナスする）
                var copyBuffer : CMSampleBuffer?
                var count: CMItemCount = 1
                var info = CMSampleTimingInfo()
                CMSampleBufferGetSampleTimingInfoArray(sampleBuffer, entryCount: count, arrayToFill: &info, entriesNeededOut: &count)
                info.presentationTimeStamp = CMTimeSubtract(info.presentationTimeStamp, offsetTime)
                CMSampleBufferCreateCopyWithNewTiming(allocator: kCFAllocatorDefault,sampleBuffer: sampleBuffer,sampleTimingEntryCount: 1,sampleTimingArray: &info,sampleBufferOut: &copyBuffer)
                
                lastTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer) // 最後のデータの時間を記録する
                if shouldStop || RecodingTime() > CMTimeMake(value: Int64(recordingTime), timescale: 1) {
                    self.writer.finishWriting(completionHandler: {
                        DispatchQueue.main.async {
                            self.delegate?.finishRecording(fileUrl: self.writer.outputURL) // 録画終了
                        }
                    })
                    status = .End
                    return
                }

                if isVideo {
                    if (videoInput?.isReadyForMoreMediaData)! {
                        videoInput?.append(copyBuffer!)
                    }
                }else{
                    if (audioInput?.isReadyForMoreMediaData)! {
                        audioInput?.append(copyBuffer!)
                    }
                }
                delegate?.changeRecordingTime(s: RecodingTime().value) // 録画時間の更新
            }
        }
    }
    
    func pause(){
        if status == .Write {
            status = .Pause
        }
    }
    
    func stop() {
        if status == .Write {
            shouldStop = true
        }
    }
    
    func start(){
        if status == .Start {
            status = .Write
        } else if status == .Pause {
            status = .Restart // 一時停止中の時間をPauseTimeに追加するためのステータス
        }
    }
}
