//
//  ThumbnailManager.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation
import UIKit
import AVFoundation

class ThumbnailManager {
    static var shared = ThumbnailManager()
    private init() { }
    
    
    public func generateVideoThumbnailImages(url: URL, timestamps: [Int64], completion: @escaping ((_ images: [UIImage]?) -> Void)) {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        
        var images = [UIImage]()
        for timestamp in timestamps {
            let thumbnailTime = CMTimeMake(value: timestamp, timescale: 1)
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailTime, actualTime: nil)
                let thumbImage = UIImage(cgImage: cgThumbImage)
                images.append(thumbImage)
            } catch {
                print(error.localizedDescription)
            }
        }
        completion(images)
    }
    
    
    public func generateVideoThumbnail(url: URL, timestamp: Double = 1.0) -> UIImage? {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        
        let thumnailTime = CMTimeMake(value: Int64(timestamp * 10), timescale: 10)
        
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            return thumbImage
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    public func generateVideoThumbnail(url: URL, completion: @escaping ((_ image: UIImage?) -> Void)) {
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumnailTime = CMTimeMake(value: 2, timescale: 1)
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
            let thumbImage = UIImage(cgImage: cgThumbImage)
            completion(thumbImage)
        } catch {
            print(error.localizedDescription)
            completion(nil)
        }
    }
}
