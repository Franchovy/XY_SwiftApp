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
        button.setBackgroundColor(color: .black)
        button.setGradient(Global.xyGradient)
        return button
    }()
    
    private var videoView: VideoPlayerView?
    private var challengeViewModel: ChallengeViewModel?
    private var challengeVideoViewModel: ChallengeVideoViewModel?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    
        contentView.addSubview(creatorNameLabel)
        contentView.addSubview(playButton)
        
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1.0
        layer.shadowColor = UIColor.black.cgColor
                
        layer.masksToBounds = false
        clipsToBounds = false
        
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        
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
    
    public func stopVideo() {
        videoView?.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        challengeTitleGradientLabel?.removeFromSuperview()
        videoView?.removeFromSuperview()
    }
    
    public func configure(viewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel) {
        self.challengeViewModel = viewModel
        self.challengeVideoViewModel = videoViewModel
        
        let challengeTitleGradientLabel = GradientLabel(text: viewModel.title, fontSize: 12, gradientColours: Global.xyGradient)
        contentView.addSubview(challengeTitleGradientLabel)
        
        challengeTitleGradientLabel.setResizesToWidth(width: width - 10)
        self.challengeTitleGradientLabel = challengeTitleGradientLabel
        
        creatorNameLabel.text = "@\(viewModel.creator.nickname)"
        
        let videoView = VideoPlayerView()
        contentView.insertSubview(videoView, at: 0)
        videoView.frame = bounds
        
        if let videoUrl = videoViewModel.videoUrl {
            videoView.setUpVideo(videoURL: videoUrl)
        }
        self.videoView = videoView
        
        videoView.layer.cornerRadius = 15
        videoView.layer.masksToBounds = true
        
        layoutSubviews()
    }
    
    @objc private func didTapPlay() {
        
        guard let challengeViewModel = challengeViewModel else {
            return
        }
        TabBarViewController.instance.startChallenge(challenge: challengeViewModel)
    }
}
