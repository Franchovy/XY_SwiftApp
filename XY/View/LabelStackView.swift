//
//  LabelStackView.swift
//  XY
//
//  Created by Maxime Franchot on 28/03/2021.
//

import UIKit

class LabelStackView: UIStackView {

    var labels = [UILabel]()
    
    init(labels: [String]) {
        super.init(frame: .zero)
        
        for labelText in labels {
            let label = UILabel()
            label.text = labelText
            
            self.labels.append(label)
            addArrangedSubview(label)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setColor(_ color: UIColor?) {
        for label in labels {
            label.textColor = color
        }
    }
    
    public func setFont(_ font: UIFont?) {
        for label in labels {
            label.font = font
        }
    }
}
