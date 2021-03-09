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
    
    private var challengeTitleGradientLabel: GradientLabel
    private let playButton: GradientBorderButtonWithShadow = {
       let button = GradientBorderButtonWithShadow()
        button.titleLabel?.text = "Play"
        button.setGradient(Global.xyGradient)
        return button
    }()
    
    private let videoView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.clipsToBounds = true
        return view
    }()
    
    var playerLayer:AVPlayerLayer?
    var player: AVPlayer!
    
    
    override init(frame: CGRect) {
        challengeTitleGradientLabel = GradientLabel(text: "", fontSize: 20, gradientColours: Global.xyGradient)
        
        super.init(frame: frame)
        
        addSubview(videoView)
        addSubview(challengeTitleGradientLabel)
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
        
        videoView.frame = bounds
        
        challengeTitleGradientLabel.sizeThatFits(CGSize(width: width - 25, height: 25))
        challengeTitleGradientLabel.frame = CGRect(
            x: (width - challengeTitleGradientLabel.height)/2,
            y: height/2 - challengeTitleGradientLabel.height - 2,
            width: challengeTitleGradientLabel.width,
            height: challengeTitleGradientLabel.height
        )
        
        creatorNameLabel.sizeThatFits(CGSize(width: width - 25, height: 15))
        creatorNameLabel.frame = CGRect(
            x: (width - creatorNameLabel.width)/2,
            y: challengeTitleGradientLabel.bottom + 3,
            width: creatorNameLabel.width,
            height: creatorNameLabel.height
        )
        
        let playButtonSize = CGSize(width: 49, height: 18)
        playButton.frame = CGRect(
            x: (width - playButtonSize.width)/2,
            y: height - 6.1 - playButtonSize.height,
            width: playButtonSize.width,
            height: playButtonSize.height
        )
    }
    
    public func configure(viewModel: ChallengeViewModel) {
        challengeTitleGradientLabel = GradientLabel(text: viewModel.title, fontSize: 20, gradientColours: Global.xyGradient)
        creatorNameLabel.text = "@\(viewModel.creator)"
    }
}
