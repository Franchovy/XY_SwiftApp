//
//  ProfileFlowCollectionViewCell.swift
//  XY_APP
//
//  Created by Simone on 09/01/2021.
//

import UIKit

class ProfileFlowCollectionViewCell: UICollectionViewCell {

    static let identifier = "ProfileFlowCollectionViewCell"
    
    private var image: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .purple
        return imageView
    }()
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(image)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        image.frame = bounds.insetBy(dx: 5, dy: 5)
    }
}
