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
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway", size: 16)
        label.textColor = UIColor(named: "XYWhite")
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
    
    var backgroundLayer = CAShapeLayer()
    var shadowLayer = CAShapeLayer()
    
    var viewModel: ChallengeViewModel?
    var challengeStartDelegate: StartChallengeDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(creatorNameLabel)
        addSubview(descriptionLabel)
        addSubview(playButton)
        
        layer.insertSublayer(backgroundLayer, at: 0)
        layer.insertSublayer(shadowLayer, at: 0)
        
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let roundedRectPath = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        backgroundLayer.path = roundedRectPath
        shadowLayer.path = roundedRectPath
        shadowLayer.shadowPath = roundedRectPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0, height: 3)
        shadowLayer.shadowRadius = 6
        shadowLayer.shadowColor = UIColor(0xFFFFFF).withAlphaComponent(101/255).cgColor
        shadowLayer.shadowOpacity = 1.0
        backgroundLayer.fillColor = UIColor(named: "XYBlack")!.cgColor
        backgroundLayer.frame = bounds
        shadowLayer.frame = bounds
        
        if let challengeTitleGradientLabel = challengeTitleGradientLabel {
            challengeTitleGradientLabel.sizeToFit()
            challengeTitleGradientLabel.frame = CGRect(
                x: (width - challengeTitleGradientLabel.width)/2,
                y: 10.46,
                width: challengeTitleGradientLabel.width,
                height: challengeTitleGradientLabel.height
            )
        }
        
        let bottomY:CGFloat = (challengeTitleGradientLabel?.bottom ?? (130)/2) + 15
        let boundingRect = CGRect(
            x: 12,
            y: bottomY,
            width: width - 24,
            height: 130
        )
        let descriptionBounds = descriptionLabel.textRect(forBounds: boundingRect, limitedToNumberOfLines: 4)
        descriptionLabel.frame = CGRect(
            x: boundingRect.origin.x,
            y: bottomY,
            width: boundingRect.width,
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        challengeTitleGradientLabel?.removeFromSuperview()
        challengeTitleGradientLabel = nil
    }
    
    public func configure(viewModel: ChallengeViewModel) {
        let challengeTitleGradientLabel = GradientLabel(text: viewModel.title, fontSize: 16, gradientColours: viewModel.category.getGradient())
        addSubview(challengeTitleGradientLabel)
        
        challengeTitleGradientLabel.setResizesToWidth(width: width - 10)
        self.challengeTitleGradientLabel = challengeTitleGradientLabel
        
        creatorNameLabel.text = "By: \n@\(viewModel.creator.nickname)"
        descriptionLabel.text = viewModel.description
        
        self.viewModel = viewModel
        
        layoutSubviews()
    }
    
    @objc private func playButtonPressed() {
        guard let viewModel = viewModel else {
            return
        }
        challengeStartDelegate?.pressedPlay(challenge: viewModel)
    }
}
