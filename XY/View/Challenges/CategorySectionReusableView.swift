//
//  ChallengeSectionReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit

class CategorySectionReusableView : UICollectionReusableView {
    static let identifier = "CategorySectionReusableView"
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 30)
        label.textColor = UIColor(named: "XYTint")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.sizeToFit()
        titleLabel.frame = CGRect(
            x: 0,
            y: 15,
            width: titleLabel.width,
            height: titleLabel.height
        )
    }
    
    func configure(title: String) {
        titleLabel.text = "#\(title)"
    }
}
