//
//  SkinnerBoxCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 04/05/2021.
//

import UIKit

class SkinnerBoxCollectionViewCell: UICollectionViewCell {
    static let identifier = "SkinnerBoxCollectionViewCell"
    
    let backgroundLayer = Card(backgroundColor: .XYCard)
    
    let titleLabel = Label(style: .title, fontSize: 18)
    let iconImageView = UIImageView()
    let descriptionLabel = Label(style: .body, fontSize: 11)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        iconImageView.contentMode = .scaleAspectFill
        
        backgroundLayer.layer.cornerRadius = 10
        
        contentView.addSubview(backgroundLayer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(descriptionLabel)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: (width - titleLabel.width)/2,
            y: 9.6,
            width: titleLabel.width,
            height: titleLabel.height
        )
        
        iconImageView.frame = CGRect(
            x: (width - 35.36)/2,
            y: 63.42,
            width: 35.36,
            height: 30
        )
        
        guard let text = descriptionLabel.text else {
            return
        }
        
        let descriptionWidth: CGFloat = 125
        let boundingRect = text.boundingRect(
            with: CGSize(width: descriptionWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionLabel.font!],
            context: nil
        )
        
        descriptionLabel.frame = CGRect(
            x: (width - descriptionWidth)/2,
            y: height - boundingRect.height - 11.93,
            width: descriptionWidth,
            height: boundingRect.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        iconImageView.image = nil
        descriptionLabel.text = nil
    }
    
    public func configure(title: String, image: UIImage, description: String) {
        titleLabel.text = title
        iconImageView.image = image
        descriptionLabel.text = description
    }
}
