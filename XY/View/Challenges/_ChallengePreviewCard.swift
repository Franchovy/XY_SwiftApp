//
//  ChallengePreviewCard.swift
//  XY
//
//  Created by Maxime Franchot on 22/03/2021.
//

import UIKit

class _ChallengePreviewCard: UIView {

    private var titleLabel: GradientLabel?

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-ExtraBold", size: 15)
        label.textColor = UIColor(named: "XYWhite")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let playButton = GradientBorderButtonWithShadow()
    
    private let backgroundLayer:CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(0x141516).cgColor
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5
        return layer
    }()
    
    var viewModel: ChallengeViewModel?
    
    var onPressedPlay: (() -> Void)?
    
    init() {
        super.init(frame: .zero)
        
        addSubview(descriptionLabel)
        addSubview(playButton)
        
        playButton.setGradient(Global.xyGradient)
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 14)
        
        playButton.addTarget(self, action: #selector(playButtonPressed), for: .touchUpInside)
                
        layer.insertSublayer(backgroundLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 10).cgPath
        backgroundLayer.shadowPath = backgroundLayer.path
        
        if let titleLabel = titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: (width - titleLabel.width)/2,
                y: 12.21,
                width: titleLabel.width,
                height: titleLabel.height
            )
        }
        
        let constraintRect = CGSize(width: 140, height: 160)
            
        let boundingRect = descriptionLabel.text!.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionLabel.font],
            context: nil)
        
        descriptionLabel.frame = CGRect(
            x: 0,
            y: (height - boundingRect.height)/2,
            width: constraintRect.width,
            height: boundingRect.height
        )
        
        let playButtonSize = CGSize(width: 75, height: 25)
        playButton.frame = CGRect(
            x: (width - playButtonSize.width)/2,
            y: height - playButtonSize.height - 8,
            width: playButtonSize.width,
            height: playButtonSize.height
        )
    }
    
    func configure(with viewModel: ChallengeViewModel) {
        self.viewModel = viewModel
        
        titleLabel = GradientLabel(
            text: viewModel.title,
            fontSize: 16,
            gradientColours: viewModel.category.getGradientAdaptedToLightMode()
        )
        addSubview(titleLabel!)
        
        descriptionLabel.text = viewModel.description
    }
    
    @objc private func playButtonPressed() {
        if onPressedPlay != nil {
            onPressedPlay!()
            return
        }
        
        guard let viewModel = viewModel else {
            return
        }
        
        TabBarViewController.instance.startChallenge(challenge: viewModel)
    }
}
