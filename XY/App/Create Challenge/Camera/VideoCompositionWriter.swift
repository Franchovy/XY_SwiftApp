//
//  VideoCompositionWriter.swift
//  XY
//
//  Created by Maxime Franchot on 25/04/2021.
//

import AVFoundation
import UIKit

class VideoCompositionWriter: NSObject {
    func merge(arrayVideos: [AVAsset]) -> AVMutableComposition {
        // Create a new mutable compositon
        let mainComposition = AVMutableComposition()
        // Add a video track to the composition
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        // Starting at time = 0, loop over each video asset and add them to the track
        var insertTime = CMTime.zero
        for videoAsset in arrayVideos {
            try! compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: .video)[0], at: insertTime)
            // Update the next insert time by the video asset's duration
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        return mainComposition
    }

    // This function takes the path to a directory containing the video clips, an output filenname and an array of filenames identifying the clips to be merged
    func mergeAudioVideo(_ documentsDirectory: URL, filename: String, clips: [String], completion: @escaping (Bool, URL?) -> Void) {
        
        var assets: [AVAsset] = []
        var totalDuration = CMTime.zero

        for clip in clips {
            let videoFile = documentsDirectory.appendingPathComponent(clip)
            let asset = AVURLAsset(url: videoFile)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }

        // Use our merge function to get a new composition containing all the video clips
        let mixComposition = merge(arrayVideos: assets)

        // We hardcoded one local audio file for this example, but you can pass a URL to any audio file
        // Load the audio track
//        guard let audioUrl = Bundle.main.url(forResource: "Some_Audio_File", withExtension: "mp3") else { return }
//        let loadedAudioAsset = AVURLAsset(url: audioUrl)
//        let audioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: 0)
//        do {
            // Insert the audio track into the composition
//            try audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero,
//                                                            duration: totalDuration),
//                                            of: loadedAudioAsset.tracks(withMediaType: AVMediaType.audio)[0],
//                                            at: CMTime.zero)
//        } catch {
//            print("Failed to insert audio track")
//        }

        // Get path to the output file
        let url = documentsDirectory.appendingPathComponent("out_\(filename)")

        // Create an AVAssetExportSession, passing in our composition
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else {
            return
        }
        // Set the export session's output URL
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true

        // Carry out the export
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    completion(true, exporter.outputURL)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
}
