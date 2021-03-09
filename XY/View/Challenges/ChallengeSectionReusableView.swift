//
//  ChallengeSectionReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 09/03/2021.
//

import UIKit

class CategorySectionReusableView : UICollectionReusableView {
    static let identifier = "ChallengeSectionReusableView"
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func configure()
}
