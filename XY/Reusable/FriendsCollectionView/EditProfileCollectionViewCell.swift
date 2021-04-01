//
//  EditProfileCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class EditProfileCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "EditProfileCollectionViewCell"
    
    private let imageView = UIImageView()
    private let imageLabel = Label(style: .title, fontSize: 12)
    private let label = Label(style: .body)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor
        
        imageLabel.text = "Profile"
        imageLabel.alpha = 0.5
        label.text = "Nickname"
        
        contentView.addSubview(imageView)
        contentView.addSubview(imageLabel)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewSize: CGFloat = 50
        imageView.layer.cornerRadius = imageViewSize/2
        imageView.frame = CGRect(x: 0, y: 0, width: imageViewSize, height: imageViewSize)
        
        imageLabel.sizeToFit()
        imageLabel.frame = CGRect(
            x: (width - imageLabel.width)/2,
            y: imageView.height/2 - imageLabel.height/2,
            width: imageLabel.width,
            height: imageLabel.height
        )
        
        label.sizeToFit()
        label.frame = CGRect(
            x: (width - label.width)/2,
            y: imageView.bottom + 5,
            width: label.width,
            height: label.height
        )
    }
    
}
