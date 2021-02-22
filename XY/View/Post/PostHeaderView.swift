//
//  PostHeaderView.swift
//  XY
//
//  Created by Maxime Franchot on 17/02/2021.
//

import UIKit

class PostHeaderView: UITableViewHeaderFooterView {

    static let identifier = "PostHeaderView"
        
    private var postCard: UIView = {
        let postCard = UIView()
        postCard.layer.cornerRadius = 15
        postCard.layer.masksToBounds = false
        // Normal shadow
        postCard.layer.shadowOpacity = 1.0
        postCard.layer.shadowColor = UIColor.black.cgColor
        postCard.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        postCard.layer.shadowRadius = 3.0
        return postCard
    }()
    
    private var postShadowLayer: CAShapeLayer = {
        let shadowLayer = CAShapeLayer()
        shadowLayer.shadowOpacity = 0.0
        shadowLayer.shadowOffset = CGSize(width: 0, height: 6)
        shadowLayer.shadowRadius = 8
        return shadowLayer
    }()
    
    private var xpCircle = CircleView()
    
    private var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    var viewModel: NewPostViewModel?
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(postCard)
        postCard.addSubview(xpCircle)
        postCard.addSubview(contentImageView)
        
        postCard.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        postCard.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let postCardSize = contentView.width - 34
        postCard.frame = CGRect(
            x: (contentView.width/2 - postCardSize/2),
            y: 10,
            width: postCardSize,
            height: postCardSize
        )
        
        xpCircle.frame = CGRect(
            x: postCard.width - 30 - 10.78,
            y: 10.78,
            width: 30,
            height: 30
        )
        
        contentImageView.frame = postCard.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        guard let viewModel = viewModel else {
            return
        }
        XPManager.shared.unsubscribeToID(docID: viewModel.id)
    }
    
    public func configure(with viewModel: NewPostViewModel) {
        self.viewModel = viewModel
        contentImageView.image = viewModel.image
        
        let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .post)
        self.xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / Float(nextLevelXP))
        
        XPManager.shared.subscribeToDocument(
            collectionName: FirebaseKeys.CollectionPath.posts,
            docID: viewModel.id) { (level, xp) in
            if let level = level, let xp = xp {
                let nextLevelXP = XPModelManager.shared.getXpForNextLevelOfType(level, .post)
                self.xpCircle.setProgress(level: level, progress: Float(xp) / Float(nextLevelXP))
            }
        }
    }

    public func setHeroID(id: String) {
        isHeroEnabled = true
        postCard.heroID = id
    }

}
