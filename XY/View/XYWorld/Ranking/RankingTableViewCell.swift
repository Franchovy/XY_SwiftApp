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
        return label
    }()

    private let xpCircle = CircleView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(named: "XYCard")
        
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
            x: rankLabel.right + 40.29,
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
        
        let nameLabelSize = nameLabel.sizeThatFits(
            CGSize(
                width: xpCircle.left - profileImageView.right - 15,
                height: height - 5
            )
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
    
    enum Size {
        case large
        case small
    }
    
    public func configure(with viewModel: RankingCellViewModel, for size: Size) {
        switch size {
        case .large:
            rankLabel.font = UIFont(name: "Raleway-Heavy", size: 30)
            profileImageView.frame.size = CGSize(width: 30, height: 30)
            nameLabel.font = UIFont(name: "Raleway-Heavy", size: 30)
        case .small:
            rankLabel.font = UIFont(name: "Raleway-Heavy", size: 19)
            profileImageView.frame.size = CGSize(width: 40, height: 40)
            nameLabel.font = UIFont(name: "Raleway-Heavy", size: 20)
        }
        
        rankLabel.text = String(describing: viewModel.rank)
        nameLabel.text = viewModel.name
        profileImageView.image = viewModel.image
        
        let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user)
        xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXP))
        xpCircle.setupFinished()
        
    }
}
