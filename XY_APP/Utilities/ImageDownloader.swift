//
//  ImageDownloader.swift
//  XY_APP
//
//  Created by Maxime Franchot on 18/12/2020.
//

import UIKit


enum ImageDownloadState {
    case new
    case downloading
    case downloaded
    case failed
}

class Image {
    let url: URL
    var state = ImageDownloadState.new
    var image = UIImage(named: "Placeholder")
    
    init(url:URL) {
        self.url = url
    }
}

class DownloadOperations {
    // MARK: - Properties
    
    // Dictionary ID - to - Download Operation
    lazy var downloadsInProgress: [String: Operation] = [:]
    
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
}

class ImageDownloader: Operation {
    let image: Image
    
    init(_ image: Image) {
        self.image = image
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        // Get image data from backend
        guard let imageData = try? Data(contentsOf: image.url) else { return }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            image.image = UIImage(data:imageData)
            image.state = .downloaded
        } else {
            image.state = .failed
            image.image = UIImage(named: "Failed")
        }
    }
}
