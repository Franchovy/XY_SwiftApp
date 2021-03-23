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

    private var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Bold", size: 18)
        label.textColor = UIColor(named: "tintColor")
        return label
    }()
    
    private let followButton = FollowButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        addSubview(rankLabel)
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(scoreLabel)
        addSubview(followButton)
        followButton.isHidden = true
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
        
        nameLabel.frame = CGRect(
            x: profileImageView.right + 9.92,
            y: 8,
            width: 100,
            height: 26
        )
        
        scoreLabel.sizeToFit()
        scoreLabel.frame = CGRect(
            x: 235,
            y: 9,
            width: scoreLabel.width,
            height: scoreLabel.height
        )
        
        followButton.frame = CGRect(
            x: width - 82,
            y: 10,
            width: 72,
            height: 23
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        rankLabel.text = ""
        nameLabel.text = ""
        profileImageView.image = nil
        scoreLabel.text = ""
        followButton.prepareForReuse()
    }
    
    public func setColor(color: UIColor) {
        rankLabel.textColor = color
        rankLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        rankLabel.layer.shadowRadius = 6
        rankLabel.layer.shadowColor = color.cgColor
        rankLabel.layer.shadowOpacity = 1.0
        
        nameLabel.textColor = color
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        nameLabel.layer.shadowRadius = 6
        nameLabel.layer.shadowColor = color.cgColor
        nameLabel.layer.shadowOpacity = 1.0
        
        scoreLabel.textColor = color
        scoreLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        scoreLabel.layer.shadowRadius = 6
        scoreLabel.layer.shadowColor = color.cgColor
        scoreLabel.layer.shadowOpacity = 1.0
    }
    
    public func configureEmpty(rank: Int) {
        
        if rank == 1 {
            setColor(color: UIColor(0xCAF035))
        } else if rank <= 3 {
            setColor(color: UIColor(0xFF8740))
        } else if rank <= 5 {
            setColor(color: UIColor(0xFF3C4B))
        } else if rank <= 10 {
            setColor(color: UIColor(0x2375F8))
        } else {
            setColor(color: UIColor(0x43A5FF))
        }
        
        rankLabel.text = String(describing: rank)
        nameLabel.text = "--------"
        profileImageView.alpha = 0.0
        scoreLabel.text = "------"
    }
    
    public func configure(with viewModel: NewProfileViewModel, rank: Int, score: Int) {
        
        if rank == 1 {
            setColor(color: UIColor(0xCAF035))
        } else if rank <= 3 {
            setColor(color: UIColor(0xFF8740))
        } else if rank <= 5 {
            setColor(color: UIColor(0xFF3C4B))
        } else if rank <= 10 {
            setColor(color: UIColor(0x2375F8))
        } else {
            setColor(color: UIColor(0x43A5FF))
        }
        
        rankLabel.text = String(describing: rank)
        nameLabel.text = viewModel.nickname
        if viewModel.profileImage != nil {
            profileImageView.image = viewModel.profileImage
            profileImageView.alpha = 1.0
        }
        
        scoreLabel.text = String(format: "%06d", score)
        
        if viewModel.relationshipType != .none {
            followButton.configure(for: viewModel.relationshipType, otherUserID: viewModel.userId)
            followButton.isHidden = false
        }
    }
    
    public func updateScore(_ score: Int) {
        let newScoreLabel = UILabel()
        newScoreLabel.font = scoreLabel.font
        newScoreLabel.textColor = scoreLabel.textColor
        newScoreLabel.shadowColor = scoreLabel.shadowColor
        newScoreLabel.shadowOffset = scoreLabel.shadowOffset
        newScoreLabel.layer.shadowRadius = scoreLabel.layer.shadowRadius
        newScoreLabel.text = String(format: "%06d", score)
        
        newScoreLabel.sizeToFit()
        newScoreLabel.frame.origin.x = scoreLabel.frame.origin.x
        newScoreLabel.frame.origin.y = scoreLabel.frame.origin.y + 30
        newScoreLabel.alpha = 0.0
        addSubview(newScoreLabel)
        
        let topY = scoreLabel.frame.origin.y - 30
        let labelY = scoreLabel.frame.origin.y
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut) {
            self.scoreLabel.alpha = 0.0
            newScoreLabel.frame.origin.y = labelY
            newScoreLabel.alpha = 1.0
        } completion: { (done) in
            if done {
                self.scoreLabel.removeFromSuperview()
                self.scoreLabel = newScoreLabel
            }
        }
    }
}
