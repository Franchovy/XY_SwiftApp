//
//  ChallengeCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit
import AVFoundation


protocol ChallengeCollectionViewCellDelegate: class {
    func didPressPlay(for challengeViewModel: ChallengeViewModel, videoViewModel: ChallengeVideoViewModel)
}

class ChallengeCollectionViewCell: UICollectionViewCell {
    static let identifier = "ChallengeCollectionViewCell"
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway", size: 10)
        label.textColor = UIColor(0xFFFFFF)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.8
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowColor = UIColor.black.cgColor
        return label
    }()
    
    private var challengeTitleGradientLabel: GradientLabel?
    private let viewButton: GradientBorderButtonWithShadow = {
       let button = GradientBorderButtonWithShadow()
        button.setTitle("View", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 15)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundColor(color: .clear)
        button.setGradient(Global.xyGradient)
        button.hasShadow = false
        return button
    }()
    
    private var videoView: VideoPlayerView?
    private var thumbnailView = UIImageView()
    
    private var challengeViewModel: ChallengeViewModel?
    private var challengeVideoViewModel: ChallengeVideoViewModel?
    
    weak var delegate: ChallengeCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
    
        contentView.addSubview(creatorNameLabel)
        contentView.addSubview(viewButton)
        
//        layer.shadowRadius = 1
//        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
//        layer.shadowOpacity = 1.0
//        layer.shadowColor = UIColor.black.cgColor

        layer.masksToBounds = false
        clipsToBounds = false
        
        viewButton.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
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
        
        let playButtonSize = CGSize(width: 66.7, height: 22)
        viewButton.frame = CGRect(
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
        
        let challengeTitleGradientLabel = GradientLabel(text: viewModel.title, fontSize: 12, gradientColours: viewModel.category.getGradient())
        contentView.addSubview(challengeTitleGradientLabel)
        
        challengeTitleGradientLabel.setResizesToWidth(width: width - 10)
        self.challengeTitleGradientLabel = challengeTitleGradientLabel
        
        challengeTitleGradientLabel.layer.shadowRadius = 2
        challengeTitleGradientLabel.layer.shadowOpacity = 0.8
        challengeTitleGradientLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        challengeTitleGradientLabel.layer.shadowColor = UIColor.black.cgColor
        
        creatorNameLabel.text = "@\(viewModel.creator.nickname)"
        
        contentView.addSubview(thumbnailView)
        thumbnailView.frame = bounds
        thumbnailView.image = videoViewModel.thumbnailImage
        thumbnailView.layer.cornerRadius = 2
        thumbnailView.layer.masksToBounds = true
        
        let videoView = VideoPlayerView()
        contentView.insertSubview(videoView, at: 0)
        videoView.frame = bounds
        
        if let videoUrl = videoViewModel.videoUrl {
            videoView.setUpVideo(videoURL: videoUrl)
        }
        self.videoView = videoView
        
        videoView.layer.cornerRadius = 2
        videoView.layer.masksToBounds = true
        
        layoutSubviews()
    }
    
    @objc private func didTapView() {
        
        guard let challengeViewModel = challengeViewModel, let challengeVideoViewModel = challengeVideoViewModel else {
            return
        }

        delegate?.didPressPlay(for: challengeViewModel, videoViewModel: challengeVideoViewModel)
    }
}
