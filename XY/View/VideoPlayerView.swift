//
//  VideoPlayerView.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import Foundation
import AVFoundation
import UIKit

class VideoPlayerView: UIView {
    
    var playerLayer: AVPlayerLayer?
    weak var player: AVPlayer?
    
    var repeatObserverSet = false
    var timeControlObserverSet = false
    
    private var playerDidFinishObserver: NSObjectProtocol?
    
    init() {
        super.init(frame: .zero)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        teardown()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let playerLayer = playerLayer {
            playerLayer.frame = bounds
        }
    }
    
    public func teardown() {
        player?.pause()

        if repeatObserverSet {
            NotificationCenter.default.removeObserver(self,
                                                      name: .AVPlayerItemDidPlayToEndTime,
                                                      object: player?.currentItem)
        }
        
        player?.replaceCurrentItem(with: nil)
        player = nil
    }
    
    public func play() {
        player?.play()
    }
    
    public func setUpVideo(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        
        guard let player = player else {
            return
        }
        player.play()
        
        player.volume = 0.0
        player.rate = 0.5
        
        playerDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main) { [weak self] _ in
            player.seek(to: .zero)
            player.playImmediately(atRate: 0.5)
        }
        repeatObserverSet = true
    }
}
