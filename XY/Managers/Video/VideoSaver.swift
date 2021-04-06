//
//  VideoSaver.swift
//  XY
//
//  Created by Maxime Franchot on 06/04/2021.
//

import Foundation
import Photos


final class VideoSaver {
    static func saveVideoWithUrl(url: URL, completion: @escaping(Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                 }) { saved, error in
            completion(saved, error)
         }
    }
}
