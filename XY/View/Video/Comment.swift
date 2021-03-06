//
//  Comment.swift
//  XY
//
//  Created by Maxime Franchot on 07/03/2021.
//

import UIKit

class CommentView : UIView {
    
    let commentTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-SemiBold", size: 18)
        return label
    }()
    
    init(text: String, color: UIColor, textColor: UIColor = UIColor(named: "XYWhite")) {
        super.init(frame: .zero)
        
        commentTextLabel.color = textColor
        commentTextLabel.text = text
        
        backgroundColor = color
        layer.cornerRadius = 15
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
