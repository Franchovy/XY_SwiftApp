//
//  PopupMessageView.swift
//  XY
//
//  Created by Maxime Franchot on 17/03/2021.
//

import UIKit

class PopupMessageView: UIView {

    private let titleGradientLabel: GradientLabel
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Medium", size: 18)
        label.textColor = UIColor(named: "XYTint")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let confirmButton: GradientBorderButtonWithShadow = {
        let button = GradientBorderButtonWithShadow()
        button.setGradient(Global.xyGradient)
        button.setBackgroundColor(color: UIColor(named: "Black")!)
        button.setTitleColor(UIColor(named: "tintColor"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 26)
        return button
    }()
    
    private let confirmButtonSize = CGSize(width: 237, height: 50)
    private let backgroundLayer = CALayer()
    
    private let completion: (() -> Void)
    
    init(title: String, message: String, confirmText: String, completion: @escaping(() -> Void)) {
        titleGradientLabel = GradientLabel(text: title, fontSize: 22, gradientColours: Global.xyGradient)
        self.completion = completion
        
        super.init(frame: .zero)
        
        confirmButton.setTitle(confirmText, for: .normal)
        confirmButton.addTarget(self, action: #selector(didTapConfirm), for: .touchUpInside)
        
        descriptionLabel.text = message
        
        backgroundLayer.backgroundColor = UIColor(named: "Black")!.cgColor
        backgroundLayer.cornerRadius = 15
        backgroundLayer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.9
        layer.masksToBounds = false
        layer.addSublayer(backgroundLayer)
        
        addSubview(titleGradientLabel)
        addSubview(descriptionLabel)
        addSubview(confirmButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer.frame = bounds
        
        titleGradientLabel.sizeToFit()
        titleGradientLabel.frame = CGRect(
            x: (width - titleGradientLabel.width)/2,
            y: 22.75,
            width: titleGradientLabel.width,
            height: titleGradientLabel.height
        )
        
        layoutDescription()
        
        confirmButton.frame = CGRect(
            x: (width - confirmButtonSize.width)/2,
            y: descriptionLabel.bottom + 34,
            width: confirmButtonSize.width,
            height: confirmButtonSize.height
        )
    }
    
    private func layoutDescription() {
        let boundingRect = CGSize(width: width - 34, height: .greatestFiniteMagnitude)
        let descriptionLabelBounds = descriptionLabel.text!.boundingRect(
            with: boundingRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionLabel.font],
            context: nil
        )
        descriptionLabel.frame = CGRect(
            x: (width - boundingRect.width)/2,
            y: titleGradientLabel.bottom + 46.72,
            width: boundingRect.width,
            height: descriptionLabelBounds.height
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        frame.size.width = superview?.width ?? 375 - 96
        
        titleGradientLabel.sizeToFit()
        layoutDescription()
        
        confirmButton.titleLabel?.adjustsFontSizeToFitWidth = true
        confirmButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        confirmButton.frame.size = confirmButtonSize
        
        frame.size.height =
            titleGradientLabel.height + 22.75 +
            descriptionLabel.height + 46.72 +
            confirmButton.height + 34
            + 31
        
        backgroundLayer.frame.size = frame.size
    }
    
    @objc private func didTapConfirm() {
        completion()
        
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 0.0
        } completion: { (done) in
            if done {
                self.removeFromSuperview()
            }
        }
    }
}
