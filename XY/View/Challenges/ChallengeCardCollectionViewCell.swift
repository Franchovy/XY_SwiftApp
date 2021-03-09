//
//  ChallengeCardCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit

class ChallengeCardCollectionViewCell: UICollectionViewCell {
    static let identifier = "ChallengeCardCollectionViewCell"
    
    var challengeTitleGradientLabel: GradientLabel?
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size: 12)
        label.textColor = UIColor(named: "XYWhite")
        return label
    }()
    
    let playButton: GradientButton
    
    override init(frame: CGRect) {
        playButton = GradientButton()
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(UIColor(named:"XYWhite")!, for: .normal)
        playButton.setGradient(Global.xyGradient)
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let challengeTitleGradientLabel = challengeTitleGradientLabel {
            challengeTitleGradientLabel.frame = CGRect(
                x: (width - challengeTitleGradientLabel.width)/2,
                y: 10.64,
                width: challengeTitleGradientLabel.width,
                height: challengeTitleGradientLabel.height
            )
        }
        
        descriptionLabel.sizeToFit()
        
        let playButtonSize = CGSize(width: 25, height: 64)
        playButton.frame = CGRect(
            x: (width - playButtonSize.width)/2,
            y: (height - 15 - playButtonSize.height),
            width: playButtonSize.width,
            height: playButtonSize.height
        )
        
        
    }
    
    public func configure(viewModel: ChallengeViewModel) {
        challengeTitleGradientLabel = GradientLabel(
            text: viewModel.title,
            fontSize: 14,
            gradientColours: Global.xyGradient
        )
        challengeTitleGradientLabel?.setResizesToWidth(width: width - 10)
        
        descriptionLabel.text = viewModel.description
    }
}
