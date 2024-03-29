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
        
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didLoadProfileData), name: .didLoadProfileData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeProfilePicture), name: .didChangeOwnProfilePicture, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewSize: CGFloat = width
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
    
    @objc private func didLoadProfileData() {
        imageLabel.text = "Profile"
        imageLabel.alpha = 1.0
        contentView.addSubview(imageLabel)
        imageView.alpha = 0.5
        
        if let profileImage = ProfileDataManager.shared.profileImage {
            imageView.image = profileImage
        } else {
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor(named: "XYTint")!.cgColor
        }
        
//        label.text = "Your Profile"
    }
    
    @objc private func didChangeProfilePicture() {
        imageView.image = ProfileDataManager.shared.profileImage
    }
}
