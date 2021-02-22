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
        imageView.backgroundColor = UIColor(named: "Black")
        return imageView
    }()
    
    private let loadingIcon = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image.backgroundColor = UIColor(named: "Dark")
        
        addSubview(image)
        addSubview(loadingIcon)
//        loadingIcon.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        image.frame = bounds.insetBy(dx: 5, dy: 5)
        
        let size: CGFloat = 25
        loadingIcon.frame = CGRect(
            x: (width - size)/2,
            y: (height - size)/2,
            width: size,
            height: size
        )
    }
    
    public func configure(viewModel: PostViewModel) {
        if viewModel.images.first != nil {
            image.image = viewModel.images.first
            loadingIcon.stopAnimating()
        } else {
            loadingIcon.startAnimating()
        }
        viewModel.delegate = self
    }
    
    public func configure(viewModel: NewPostViewModel) {
        if viewModel.image != nil {
            image.image = viewModel.image
            loadingIcon.stopAnimating()
        } else if viewModel.loading {
            loadingIcon.startAnimating()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }
}

extension ProfileFlowCollectionViewCell : PostViewModelDelegate {
    func didFetchProfileImage(viewModel: PostViewModel) {
        
    }
    
    func didFetchPostImages(viewModel: PostViewModel) {
//        image.image = viewModel.images.first
    }
    
    func didFetchProfileData(viewModel: PostViewModel) {
        
    }
    
}
