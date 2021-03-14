//
//  ChallengeSectionReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit

class CategorySectionReusableView : UICollectionReusableView {
    static let identifier = "CategorySectionReusableView"
    
    var titleLabel: GradientLabel?
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 16)
        label.textColor = UIColor(named: "XYTint")
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(descriptionLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let titleLabel = titleLabel {
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: 0,
                y: 15,
                width: titleLabel.width,
                height: titleLabel.height
            )
            
            let textFrame = CGSize(
                width: width,
                height: .greatestFiniteMagnitude
            )
            let boundingRect = descriptionLabel.text!.boundingRect(with: textFrame,
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: descriptionLabel.font!],
                                                context: nil)
            
            descriptionLabel.frame = CGRect(
                origin: CGPoint(x: 0,
                y: titleLabel.bottom + 5),
                size: boundingRect.size
            )
            
//            frame.size.height = descriptionLabel.bottom
        }
    }
    
    func configure(title: String, gradient: [UIColor], description: String) {
        titleLabel?.removeFromSuperview()
        titleLabel = GradientLabel(text: "#\(title)", fontSize: 30, gradientColours: gradient)
        addSubview(titleLabel!)
        descriptionLabel.text = description
        
        layoutSubviews()
    }
}
