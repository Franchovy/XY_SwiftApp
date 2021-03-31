//
//  ProfileCardCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 03/02/2021.
//

import UIKit

class ProfileCardCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProfileCardCollectionViewCell"
    
    private let coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let gradientViewLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 15
        return gradientLayer
    }()
    
    private let gradientView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        return view
    }()
    
    private let profileImageContainer = UIView()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let xpCircle: CircleView = {
        let xpCircle = CircleView()
        return xpCircle
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label.layer.shadowRadius = 2.0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        return label
    }()
    
    var viewModel: _ProfileViewModel?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(coverImage)
        gradientView.layer.addSublayer(gradientViewLayer)
        addSubview(gradientView)
        addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImage)
        addSubview(xpCircle)
        addSubview(nameLabel)
        
        nameLabel.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor, constant: 10).isActive = true
        
        xpCircle.setProgress(level: 0, progress: 0)
        xpCircle.setupFinished()
        
        let tappedImageGesture = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        coverImage.isUserInteractionEnabled = true
        profileImage.isUserInteractionEnabled = true
        coverImage.addGestureRecognizer(tappedImageGesture)
        profileImage.addGestureRecognizer(tappedImageGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        let profileImageSize:CGFloat = 50
        
        coverImage.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        let gradientViewHeight:CGFloat = 50
        gradientView.frame = CGRect(
            x: 0,
            y: coverImage.bottom - gradientViewHeight,
            width: width,
            height: gradientViewHeight
        )
        gradientViewLayer.frame = gradientView.bounds
        
        profileImageContainer.frame = CGRect(
            x: (width - profileImageSize)/2,
            y: gradientView.top - profileImageSize/2,
            width: profileImageSize,
            height: profileImageSize
        )
        profileImage.frame = profileImageContainer.bounds
        
        profileImage.applyshadowWithCorner(
            containerView: profileImageContainer,
            cornerRadious: profileImageSize/2,
            shadowOffset: CGSize(width: 0, height: 2),
            shadowRadius: 3
        )
        
        nameLabel.sizeToFit()
        
        let xpCircleSize:CGFloat = 25
        xpCircle.frame = CGRect(
            x: width - 10 - xpCircleSize,
            y: 10,
            width: xpCircleSize,
            height: xpCircleSize
        )
    }
    
    public func configure(with viewModel: _ProfileViewModel) {
        viewModel.delegate = self
        coverImage.image = viewModel.coverImage
        profileImage.image = viewModel.profileImage
        nameLabel.text = viewModel.nickname
        
        // Register XP Updates
        if let userId = viewModel.userId {
            FirebaseSubscriptionManager.shared.registerXPUpdates(for: userId, ofType: .user) { [weak self] (xpModel) in
                viewModel.updateXP(xpModel)
            }
        }
        
        self.viewModel = viewModel
    }
    
    override func prepareForReuse() {
        coverImage.image = nil
        profileImage.image = nil
        nameLabel.text = nil
        
        // Deregister XP Updates
        if let userId = viewModel?.userId {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: userId)
        }
        
        viewModel = nil
    }
    
    @objc private func openProfile() {
        guard let profileId = viewModel?.profileId else {
            return
        }
        ProfileManager.shared.openProfileForId(profileId)
    }
}

extension ProfileCardCollectionViewCell : ProfileViewModelDelegate {
    func onXYNameFetched(_ xyname: String) {
        
    }
    
    func onProfileDataFetched(_ viewModel: _ProfileViewModel) {
        guard viewModel.profileId == self.viewModel?.profileId else {
            return
        }
        
        nameLabel.text = viewModel.nickname
        
        // Register XP Updates
        if let userId = viewModel.userId {
            FirebaseSubscriptionManager.shared.registerXPUpdates(for: userId, ofType: .user) { [weak self] (xpModel) in
                viewModel.updateXP(xpModel)
            }
        }
    }
    
    func onProfileImageFetched(_ image: UIImage) {
        profileImage.image = image
    }
    
    func onCoverImageFetched(_ image: UIImage) {
        coverImage.image = image
    }
    
    func onXpUpdate(_ model: XPModel) {
        let xpToNextLevel = Float(XPModelManager.shared.getXpForNextLevelOfType(model.level, .user))
        
        xpCircle.onProgress(level: model.level, progress: Float(model.xp) / xpToNextLevel)
    }
    
    func setCoverPictureOpacity(_ opacity: CGFloat) {
        
    }
}
