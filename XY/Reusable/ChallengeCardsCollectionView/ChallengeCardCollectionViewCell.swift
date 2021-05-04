//
//  ChallengeCollectionViewCell.swift
//  XY
//
//  Created by Maxime Franchot on 30/03/2021.
//

import UIKit

class ChallengeCardCollectionViewCell: UICollectionViewCell, ChallengeUploadListener {
    
    static let identifier = "ChallengeCardCollectionViewCell"
    
    private let challengeCard = ChallengeCard()
    
    private var uploadingView: ChallengeUploadingCircle?
    
    private var viewModel: ChallengeCardViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(challengeCard)
        
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        layer.shadowOpacity = 0.6
        layer.shadowColor = UIColor.black.cgColor
        layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        challengeCard.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        if let uploadingView = uploadingView {
            uploadingView.sizeToFit()
            
            uploadingView.frame = CGRect(
                x: (width - uploadingView.width)/2,
                y: height - uploadingView.height - 8.36,
                width: uploadingView.width,
                height: uploadingView.height
            )
        }
    }

    public func configure(with viewModel: ChallengeCardViewModel) {
        challengeCard.configure(with: viewModel)
        self.viewModel = viewModel
        
        guard let coreDataID = viewModel.coreDataID else {
            return
        }
        
        if ChallengeDataManager.shared.isChallengeUploading(id: coreDataID) {
            ChallengeDataManager.shared.registerListener(for: coreDataID, listener: self)
            
            uploadingView = ChallengeUploadingCircle()
            addSubview(uploadingView!)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        challengeCard.prepareForReuse()
        uploadingView?.removeFromSuperview()
    }
    
    func uploadProgress(id: ObjectIdentifier, progressUpload: Double) {
        guard viewModel?.coreDataID == id else {
            return
        }
        uploadingView?.onProgress(progress: progressUpload)
    }
    
    func finishedUpload(id: ObjectIdentifier) {
        guard viewModel?.coreDataID == id else {
            return
        }
        uploadingView?.finishUploading()
    }
    
    func errorUpload(id: ObjectIdentifier, error: Error) {
        guard viewModel?.coreDataID == id else {
            return
        }
        uploadingView?.finishError()
    }
    
}
