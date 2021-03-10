//
//  ChallengePreviewCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 10/03/2021.
//

import UIKit

class ChallengePreviewCollectionViewCell: UICollectionViewCell {
    static let identifier = "ChallengePreviewCollectionViewCell"
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway", size: 14)
        label.textColor = UIColor(named: "XYTint")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway", size: 16)
        label.textColor = UIColor(named: "XYTint")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var challengeTitleGradientLabel: GradientLabel?
    
    private let playButton: GradientButton = {
       let button = GradientButton()
        button.setTitle("Play", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 19)
        button.setTitleColor(.white, for: .normal)
        button.setGradient(Global.xyGradient)
        return button
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(named: "Black")
    
        addSubview(creatorNameLabel)
        addSubview(descriptionLabel)
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
                y: 10.46,
                width: challengeTitleGradientLabel.width,
                height: challengeTitleGradientLabel.height
            )
        }
        
        let boundingRect = CGRect(
            x: 5,
            y: (challengeTitleGradientLabel?.bottom ?? 0) + 5,
            width: width - 10,
            height: 130
        )
        let descriptionBounds = descriptionLabel.textRect(forBounds: boundingRect, limitedToNumberOfLines: 4)
        print("Bounds: \(descriptionBounds)")
        descriptionLabel.frame = CGRect(
            x: descriptionBounds.origin.x,
            y: (130 - descriptionBounds.height)/2,
            width: descriptionBounds.width,
            height: descriptionBounds.height
        )
                
        let playButtonSize = CGSize(width: 64, height: 25)
        playButton.frame = CGRect(
            x: (width - playButtonSize.width)/2,
            y: height - 15 - playButtonSize.height,
            width: playButtonSize.width,
            height: playButtonSize.height
        )
        playButton.layer.cornerRadius = playButtonSize.height/2
        
        creatorNameLabel.sizeToFit()
        creatorNameLabel.frame = CGRect(
            x: (width - creatorNameLabel.width)/2,
            y: playButton.top - creatorNameLabel.height - 10,
            width: creatorNameLabel.width,
            height: creatorNameLabel.height
        )
    }
    
    public func configure(viewModel: ChallengeViewModel) {
        let challengeTitleGradientLabel = GradientLabel(text: "#\(viewModel.title)", fontSize: 18, gradientColours: Global.xyGradient)
        addSubview(challengeTitleGradientLabel)
        
        challengeTitleGradientLabel.setResizesToWidth(width: width - 10)
        self.challengeTitleGradientLabel = challengeTitleGradientLabel
        
        creatorNameLabel.text = "By: \n@\(viewModel.creator.nickname)"
        descriptionLabel.text = viewModel.description
        
        layoutSubviews()
    }
}
