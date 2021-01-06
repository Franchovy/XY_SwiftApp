//
//  CircleView.swift
//  XY_APP
//
//  Created by Maxime Franchot on 01/01/2021.
//

import UIKit

class CircleView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var progressBarCircle: ProgressBarCircle!
    @IBOutlet weak var levelLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CircleView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        progressBarCircle.frame = self.bounds
        progressBarCircle.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        progressBarCircle.layer.shadowRadius = 5
        progressBarCircle.layer.shadowOffset = .zero
        progressBarCircle.layer.shadowOpacity = 0.3
        progressBarCircle.layer.shadowColor = UIColor.blue.cgColor
        progressBarCircle.layer.shadowPath = UIBezierPath(rect: progressBarCircle.bounds).cgPath
        progressBarCircle.layer.masksToBounds = false
        
        
        
        levelLabel.frame = self.bounds
        levelLabel.sizeToFit()
        levelLabel.textAlignment = .center
        levelLabel.center = contentView.center
        
    }
}
