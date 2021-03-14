//
//  TimerIcon.swift
//  XY
//
//  Created by Maxime Franchot on 14/03/2021.
//

import UIKit

class TimerIcon: UIView {

    let icon: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "timer_icon")!)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let numberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 14)
        label.textColor = UIColor(named: "XYWhite")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(labelText: String) {
        super.init(frame: .zero)
        
        numberLabel.text = labelText
        
        addSubview(icon)
        addSubview(numberLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        icon.frame = bounds
        
        let textRect = numberLabel.text!.boundingRect(
            with: CGSize(width: width * 0.64, height: height * 0.28),
            options: .usesDeviceMetrics,
            attributes: [.font : numberLabel.font],
            context: nil
        )
        
        numberLabel.frame = CGRect(
            x: width/2 + width * 0.06,
            y: (height - textRect.height)/2 + height * 0.06,
            width: textRect.width,
            height: textRect.height
        )
    }
}
