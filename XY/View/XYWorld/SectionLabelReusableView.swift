//
//  SectionLabelReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 07/02/2021.
//

import UIKit

class SectionLabelReusableView: UICollectionReusableView {
    static let identifier = "SectionLabelReusableView"
    
    var label: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "tintColor")
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
