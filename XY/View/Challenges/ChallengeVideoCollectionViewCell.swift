//
//  ChallengeVideoCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 13/03/2021.
//

import UIKit
import AVFoundation

class ChallengeVideoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ChallengeVideoCollectionViewCell"
    
    private let rankNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 24)
        label.numberOfLines = 1
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowRadius = 6
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 13)
        label.numberOfLines = 2
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowRadius = 6
        return label
    }()
    
    private var videoView: VideoPlayerView?
    private var challengeViewModel: ChallengeViewModel?
    private var challengeVideoViewModel: ChallengeVideoViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(rankNumberLabel)
        contentView.addSubview(creatorNameLabel)
        
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 1.0
        layer.shadowColor = UIColor.black.cgColor
        
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rankNumberLabel.sizeToFit()
        rankNumberLabel.frame = CGRect(
            x: (width - rankNumberLabel.width)/2,
            y: height/2 - 15,
            width: rankNumberLabel.width,
            height: rankNumberLabel.height
        )
        
        creatorNameLabel.sizeToFit()
        creatorNameLabel.frame = CGRect(
            x: (width - creatorNameLabel.width)/2,
            y: rankNumberLabel.bottom + 10,
            width: creatorNameLabel.width,
            height: creatorNameLabel.height
        )
    }
    
    public func configureEmpty(rankNumber: Int) {
        rankNumberLabel.text = String(describing: rankNumber)
    }
    
    public func configure(viewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel, rankNumber: Int) {
        self.challengeViewModel = viewModel
        self.challengeVideoViewModel = videoViewModel
        
        creatorNameLabel.text = "Player:\n@\(viewModel.creator.nickname)"
        rankNumberLabel.text = String(describing: rankNumber)
        
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
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(didTapPlay))
        videoView.addGestureRecognizer(gr)
        creatorNameLabel.addGestureRecognizer(gr)
    }
    
    @objc private func didTapPlay() {
        
        guard let challengeViewModel = challengeViewModel else {
            return
        }
        TabBarViewController.instance.startChallenge(challenge: challengeViewModel)
    }
}

