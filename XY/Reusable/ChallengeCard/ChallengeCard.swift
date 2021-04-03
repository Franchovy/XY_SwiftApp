//
//  ChallengeCard.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class ChallengeCard: UIView {
    
    let challengeTitleGradientLabel: GradientLabel
    let previewImage = UIImageView()
    let descriptionLabel = Label(style: .body, fontSize: 15)

    init(with viewModel: ChallengeCardViewModel) {
        challengeTitleGradientLabel = GradientLabel(text: viewModel.title, fontSize: 18, gradientColours: Global.xyGradient)
        
        super.init(frame: .zero)
        
        previewImage.image = viewModel.image
        descriptionLabel.text = viewModel.description
        
        previewImage.contentMode = .scaleAspectFill
        
        addSubview(previewImage)
        addSubview(challengeTitleGradientLabel)
        addSubview(descriptionLabel)
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewImage.frame = bounds
        
        challengeTitleGradientLabel.sizeToFit()
        challengeTitleGradientLabel.frame = CGRect(
            x: (width - challengeTitleGradientLabel.width)/2,
            y: 17.51,
            width: challengeTitleGradientLabel.width,
            height: challengeTitleGradientLabel.height
        )
        
        if let text = descriptionLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 24, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: descriptionLabel.font],
                context: nil
            )
            
            descriptionLabel.frame = CGRect(
                x: 12,
                y: (height - boundingRect.height)/2,
                width: width - 24,
                height: boundingRect.height
            )
        }
    }
}
