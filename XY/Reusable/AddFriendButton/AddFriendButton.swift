//
//  AddFriendButton.swift
//  XY
//
//  Created by Maxime Franchot on 31/03/2021.
//

import UIKit

class AddFriendButton: UIButton {

    init() {
        super.init(frame: .zero)
        
        titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 12)
        
        titleEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = height/2
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        
        if titleLabel != nil {
            titleLabel!.sizeToFit()
            frame.size.width = titleLabel!.frame.size.width + 24
            frame.size.height = titleLabel!.frame.size.height + 10
        }
    }
    
    enum Mode {
        case add
        case addBack
        case friend
        case added
        case none
    }
    var mode: Mode = .none
    
    public func configure(for mode: Mode) {
        isHidden = false
        layer.borderWidth = 0
        
        self.mode = mode
        
        switch mode {
        case .add:
            setTitle("Add", for: .normal)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setTitleColor(.white, for: .normal)
        case .addBack:
            setTitle("Add back", for: .normal)
            setBackgroundColor(color: UIColor(0x007BF5), forState: .normal)
            setTitleColor(.white, for: .normal)
        case .friend:
            setTitle("Friend", for: .normal)
            setBackgroundColor(color: UIColor(0xFF0062), forState: .normal)
            setTitleColor(.white, for: .normal)
        case .added:
            setTitle("Added", for: .normal)
            setBackgroundColor(color: UIColor.clear, forState: .normal)
            setBackgroundColor(color: UIColor.lightGray, forState: .highlighted)
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "XYTint")!.cgColor
        case .none:
            isHidden = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        layer.borderColor = UIColor(named: "XYTint")!.cgColor
        
        if mode == .added {
            setTitleColor(UIColor(named: "XYTint"), for: .normal)
        }
    }
    
}
