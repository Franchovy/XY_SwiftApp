//
//  ChallengeCard.swift
//  XY
//
//  Created by Maxime Franchot on 03/04/2021.
//

import UIKit

class ChallengeCard: UIView {
    
    var challengeTitleGradientLabel = Label(style: .title, fontSize: 20)
    var previewImage = UIImageView()
    var descriptionLabel = Label(style: .info, fontSize: 15, adaptToLightMode: false)
    var friendBubbleView = FriendBubblesView()
    var timeleftLabel = Label(style: .info, fontSize: 15, adaptToLightMode: false)
    var tagLabel: ColorLabel?
    
    var viewModel: ChallengeCardViewModel?

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .black
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        descriptionLabel.numberOfLines = 0
        challengeTitleGradientLabel.adjustsFontSizeToFitWidth = true
        challengeTitleGradientLabel.applyGradient(gradientColours: Global.whiteGradient)
        
        addSubview(previewImage)
        addSubview(challengeTitleGradientLabel)
        addSubview(descriptionLabel)
        addSubview(friendBubbleView)
        addSubview(timeleftLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previewImage.frame = bounds
        
        challengeTitleGradientLabel.sizeToFit()
        
        let challengeTitleWidth = min(challengeTitleGradientLabel.width, width - 10)
        
        challengeTitleGradientLabel.frame = CGRect(
            x: (width - challengeTitleWidth)/2,
            y: 17.51,
            width: challengeTitleWidth,
            height: challengeTitleGradientLabel.height
        )
        
        if let tagLabel = tagLabel {
            tagLabel.sizeToFit()
            tagLabel.frame = CGRect(
                x: (width - tagLabel.width)/2,
                y: challengeTitleGradientLabel.bottom + 5.32,
                width: tagLabel.width,
                height: tagLabel.height
            )
        }
        
        if friendBubbleView.isNotEmpty() {
            friendBubbleView.layoutSubviews()
            
            friendBubbleView.sizeToFit()
            friendBubbleView.frame = CGRect(
                x: (width - friendBubbleView.width)/2,
                y: (tagLabel?.bottom ?? challengeTitleGradientLabel.bottom) + 5.32,
                width: friendBubbleView.width,
                height: friendBubbleView.height
            )
        }
        
        timeleftLabel.sizeToFit()
        timeleftLabel.frame = CGRect(
            x: (width - timeleftLabel.width)/2,
            y: (tagLabel?.bottom ?? challengeTitleGradientLabel.bottom) + 5.32,
            width: timeleftLabel.width,
            height: timeleftLabel.height
        )
        
        if let text = descriptionLabel.text {
            let boundingRect = text.boundingRect(
                with: CGSize(width: width - 24, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: descriptionLabel.font],
                context: nil
            )
            
            let top = max(timeleftLabel.bottom + 5, (height - boundingRect.height)/2)
            
            descriptionLabel.frame = CGRect(
                x: 12,
                y: top,
                width: width - 24,
                height: boundingRect.height
            )
        }
    }
    
    public func reset() {
        clearTagLabel()
        friendBubbleView.reset()
    }
    
    public func configure(with viewModel: ChallengeCardViewModel, withoutTag: Bool = false) {
        self.viewModel = viewModel
        
        challengeTitleGradientLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        
        previewImage.image = viewModel.image
        previewImage.alpha = 0.8
        
        if !withoutTag, let tagLabel = viewModel.tag {
            addTagLabel(labelColor: tagLabel.colorLabelColor, labelText: tagLabel.colorLabelText)
        }
        
        descriptionLabel.textColor = UIColor(named: "XYWhite")
        descriptionLabel.textAlignment = .center
        descriptionLabel.enableShadow = true
        
        previewImage.contentMode = .scaleAspectFill
        
        if let timeLeftText = viewModel.timeLeftText {
            timeleftLabel.text = timeLeftText
        }
        
        if !viewModel.isReceived, let friendBubbles = viewModel.friendBubbles {
            friendBubbleView.configure(with: friendBubbles, displayReceived: viewModel.isReceived)
        }
    }
    
    public func extractTitle() -> Label {
        let labelCopy = Label(challengeTitleGradientLabel.text, style: .title, fontSize: challengeTitleGradientLabel.font.pointSize)
        labelCopy.applyGradient(gradientColours: Global.whiteGradient)
        labelCopy.sizeToFit()
        return labelCopy
    }
    
    func clearTagLabel() {
        tagLabel?.removeFromSuperview()
        tagLabel = nil
    }
    
    func addTagLabel(labelColor: UIColor, labelText: String, textColor: UIColor = UIColor.black) {
        tagLabel = ColorLabel()
        tagLabel!.setBackgroundColor(labelColor)
        tagLabel!.setText(labelText)
        tagLabel!.setTextColor(textColor)
        
        addSubview(tagLabel!)
    }
}
