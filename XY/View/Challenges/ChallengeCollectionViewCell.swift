//
//  ChallengeCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit
import AVFoundation

class ChallengeCollectionViewCell: UICollectionViewCell {
    static let identifier = "ChallengeCollectionViewCell"
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway", size: 10)
        return label
    }()
    
    private var challengeTitleGradientLabel: GradientLabel?
    private let playButton: GradientBorderButtonWithShadow = {
       let button = GradientBorderButtonWithShadow()
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: UIColor(named: "Black")!)
        button.setGradient(Global.xyGradient)
        return button
    }()
    
    private var videoView: VideoPlayerView?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    
        addSubview(creatorNameLabel)
        addSubview(playButton)
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let challengeTitleGradientLabel = challengeTitleGradientLabel {
            challengeTitleGradientLabel.sizeToFit()
            challengeTitleGradientLabel.frame = CGRect(
                x: (width - challengeTitleGradientLabel.width)/2,
                y: height/2 - challengeTitleGradientLabel.height - 2,
                width: challengeTitleGradientLabel.width,
                height: challengeTitleGradientLabel.height
            )
            
            creatorNameLabel.sizeToFit()
            creatorNameLabel.frame = CGRect(
                x: (width - creatorNameLabel.width)/2,
                y: challengeTitleGradientLabel.bottom + 3,
                width: creatorNameLabel.width,
                height: creatorNameLabel.height
            )
        }
                
        let playButtonSize = CGSize(width: 49, height: 18)
        playButton.frame = CGRect(
            x: (width - playButtonSize.width)/2,
            y: height - 6.1 - playButtonSize.height,
            width: playButtonSize.width,
            height: playButtonSize.height
        )
    }
    
    public func configure(viewModel: ChallengeViewModel) {
        let challengeTitleGradientLabel = GradientLabel(text: "#\(viewModel.title)", fontSize: 12, gradientColours: Global.xyGradient)
        addSubview(challengeTitleGradientLabel)
        
        challengeTitleGradientLabel.setResizesToWidth(width: width - 10)
        self.challengeTitleGradientLabel = challengeTitleGradientLabel
        
        creatorNameLabel.text = "@\(viewModel.creator.nickname)"
        
        let videoView = VideoPlayerView()
        insertSubview(videoView, at: 0)
        videoView.frame = bounds
        
        videoView.setUpVideo(videoURL: viewModel.videoUrl)
        self.videoView = videoView
        
        layoutSubviews()
    }
}
