//
//  OnlineNowCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 04/02/2021.
//

import UIKit

class OnlineNowCollectionViewCell: UICollectionViewCell {
    static let identifier = "OnlineNowCollectionViewCell"
    
    private let profileImageContainer = UIView()
    
    private let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        label.layer.shadowRadius = 2.0
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 1.0
        
        return label
    }()
    
    var viewModel: NewProfileViewModel?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        
        addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImage)
        addSubview(nameLabel)
        
        nameLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor).isActive = true
        nameLabel.topAnchor.constraint(equalTo: profileImageContainer.bottomAnchor, constant: 10).isActive = true
        nameLabel.sizeThatFits(CGSize(width: width, height: nameLabel.height))
        
        let tapProfileGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapProfileGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        let profileImageSize:CGFloat = 60
        
        profileImageContainer.frame = CGRect(
            x: 0,
            y: 0,
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
    }
    
    public func configure(with viewModel: NewProfileViewModel) {
        profileImage.image = viewModel.profileImage
        nameLabel.text = viewModel.nickname
        
        // Register XP Updates
//        FirebaseSubscriptionManager.shared.registerXPUpdates(for: viewModel.userId, ofType: .user) { [weak self] (xpModel) in
//            viewModel.updateXP(xpModel)
//        }
        
        self.viewModel = viewModel
    }
    
    override func prepareForReuse() {
        profileImage.image = nil
        nameLabel.text = nil
        
        // Deregister XP Updates
        if let userId = viewModel?.userId {
            FirebaseSubscriptionManager.shared.deactivateXPUpdates(for: userId)
        }
    }
    
    // MARK: - Obj-C functions
    
    @objc private func imageTapped() {
        guard let profileId = viewModel?.profileId else {
            return
        }
        _ProfileManager.shared.openProfileForId(profileId)
    }
}

extension OnlineNowCollectionViewCell : ProfileViewModelDelegate {
    func onXYNameFetched(_ xyname: String) {
        
    }
    
    func onProfileDataFetched(_ viewModel: _ProfileViewModel) {
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
        
    }
    
    func onXpUpdate(_ model: XPModel) {
        
    }
    
    func setCoverPictureOpacity(_ opacity: CGFloat) {
        
    }
}
