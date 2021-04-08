//
//  LabelView.swift
//  XY
//
//  Created by Maxime Franchot on 08/04/2021.
//

import UIKit

class LabelView: UIView {

    var labels = [Label]()
    var onPressAction: (() -> Void)?
    
    var isAnimating = false
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        guard !isAnimating else {
            return
        }
        
        super.layoutSubviews()
        
        var y:CGFloat = 0
        
        for label in labels {
            label.sizeToFit()
            label.frame = CGRect(
                x: (width - label.width)/2,
                y: y,
                width: label.width,
                height: label.height
            )
            
            y += label.height + 5
        }
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        var width: CGFloat = 0
        var height:CGFloat = 0
        
        for label in labels {
            label.sizeToFit()
            
            width = max(label.width, width)
            height += label.height + 5
        }
        
        frame.size = CGSize(width: width, height: height)
    }
    
    func addLabel(_ text: String, font: UIFont) {
        let label = Label(text, style: .body)
        label.font = font
        label.textAlignment = .center
        
        labels.append(label)
        addSubview(label)
    }
    
    func addOnPress(onPress action: @escaping(() -> Void)) {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onPress)))
        onPressAction = action
    }
    
    @objc private func onPress() {
        self.onPressAction?()
    }
}
