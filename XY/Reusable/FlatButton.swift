//
//  FlatButton.swift
//  XY
//
//  Created by Maxime Franchot on 01/04/2021.
//

import UIKit

class FlatButton: UIButton {

    init(text: String, icon: UIImage, tintColor: UIColor? = nil) {
        super.init(frame: .zero)
                
        setTitle(text, for: .normal)
        setImage(icon, for: .normal)
        
        self.tintColor = tintColor ?? UIColor(named: "XYTint")
        self.setTitleColor(tintColor ?? UIColor(named: "XYTint"), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageRect = super.imageRect(forContentRect: contentRect)
        let offset = contentRect.minX - imageRect.minX + 23.19
        return imageRect.offsetBy(dx: offset, dy: 0.0)
    }
    
}
