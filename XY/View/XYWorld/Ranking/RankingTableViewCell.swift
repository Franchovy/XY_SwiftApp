//
//  RankingTableViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 03/03/2021.
//

import UIKit

class RankingTableViewCell: UITableViewCell {
    
    static let identifier = "RankingTableViewCell"
    
    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 19)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 20)
        label.textColor = UIColor(named: "tintColor")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let xpCircle = CircleView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(named: "XYCard")
        
        xpCircle.setLevelLabelFontSize(size: 6)
                
        addSubview(rankLabel)
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(xpCircle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        rankLabel.sizeToFit()
        rankLabel.frame = CGRect(
            x: 18.08,
            y: 4.92,
            width: rankLabel.width,
            height: rankLabel.height
        )
        
        let imageSize:CGFloat = 30
        profileImageView.frame = CGRect(
            x: 70,
            y: (height - imageSize)/2,
            width: imageSize,
            height: imageSize
        )
        profileImageView.layer.cornerRadius = imageSize/2
        
        let xpCircleSize: CGFloat = 20
        xpCircle.frame = CGRect(
            x: width - xpCircleSize - 33.58,
            y: (height - xpCircleSize)/2,
            width: xpCircleSize,
            height: xpCircleSize
        )
        
        let nameLabelSize = CGSize(
                width: xpCircle.left - profileImageView.right - 25,
                height: height - 5
            )
        nameLabel.frame = CGRect(
            x: profileImageView.right + 9.92,
            y: 8,
            width: nameLabelSize.width,
            height: nameLabelSize.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        rankLabel.text = ""
        nameLabel.text = ""
        profileImageView.image = nil
        xpCircle.reset()
    }
    
    public func setColor(color: UIColor) {
        rankLabel.textColor = color
        nameLabel.textColor = color
        rankLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        rankLabel.layer.shadowRadius = 6
        rankLabel.layer.shadowColor = color.cgColor
        rankLabel.layer.shadowOpacity = 1.0
        
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        nameLabel.layer.shadowRadius = 6
        nameLabel.layer.shadowColor = color.cgColor
        nameLabel.layer.shadowOpacity = 1.0
    }
    
    public func configure(with viewModel: NewProfileViewModel, rank: Int, score: Int) {
    
        rankLabel.font = UIFont(name: "Raleway-Heavy", size: 30)
        profileImageView.frame.size = CGSize(width: 30, height: 30)
        nameLabel.font = UIFont(name: "Raleway-Heavy", size: 30)
        xpCircle.frame.size = CGSize(width: 30, height: 30)
        
        if rank == 1 {
            setColor(color: UIColor(0xCAF035))
        } else if rank <= 3 {
            setColor(color: UIColor(0xFF8740))
        } else if rank <= 5 {
            setColor(color: UIColor(0xFF3C4B))
        } else {
            setColor(color: UIColor(0x2375F8))
        }
        
        rankLabel.text = String(describing: rank)
        nameLabel.text = viewModel.nickname
        profileImageView.image = viewModel.profileImage
        
        let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user)
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXP))
        xpCircle.setupFinished()
        
    }
}
