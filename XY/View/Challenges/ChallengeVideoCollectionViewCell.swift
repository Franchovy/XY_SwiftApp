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
    
    private var videoView: UIView?
    private var challengeViewModel: ChallengeViewModel?
    private var challengeVideoViewModel: ChallengeVideoViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
        
        videoView?.frame = bounds
        videoView?.backgroundColor = .darkGray
        videoView?.layer.cornerRadius = 15
        videoView?.layer.masksToBounds = true
        
        creatorNameLabel.sizeToFit()
        creatorNameLabel.frame = CGRect(
            x: (width - creatorNameLabel.width)/2,
            y: (height - creatorNameLabel.height)/2,
            width: creatorNameLabel.width,
            height: creatorNameLabel.height
        )
    }
    
    public func configureEmpty() {
        let emptyView = UIView()
        contentView.insertSubview(emptyView, at: 0)
        self.videoView = emptyView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
                
        videoView?.removeFromSuperview()
        creatorNameLabel.text = ""
    }
    
    public func configure(viewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel) {
        self.challengeViewModel = viewModel
        self.challengeVideoViewModel = videoViewModel
        
        creatorNameLabel.text = "Player:\n@\(viewModel.creator.nickname)"
        
        let videoView = VideoPlayerView()
        contentView.insertSubview(videoView, at: 0)
        
        if let videoUrl = videoViewModel.videoUrl {
            videoView.setUpVideo(videoURL: videoUrl)
        }
        self.videoView = videoView
        
        videoView.layer.cornerRadius = 15
        videoView.layer.masksToBounds = true
        
        layoutSubviews()
    }
}

