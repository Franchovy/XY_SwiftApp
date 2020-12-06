//
//  PostViewCell.swift
//  XY_APP
//
//  Created by Maxime Franchot on 06/12/2020.
//

import Foundation
import UIKit

class MyCustomCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func setPost(post: PostModel) {
        nameLabel.text = post.username
        contentLabel.text = post.content
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        contentView.backgroundColor = #colorLiteral(red: 0.05398157984, green: 0.05899176747, blue: 0.06317862123, alpha: 1)
        
        
        // set the text from the data model
        contentLabel.numberOfLines = 0
        contentLabel.textColor = UIColor.white
        nameLabel.textColor = UIColor.white
        
        // add border and color
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 15
        clipsToBounds = true
    }
}
