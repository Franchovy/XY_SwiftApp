//
//  MenuViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/12/2020.
//

import UIKit

class MenuViewController : UIViewController {
    override func viewDidLoad() {
        // Testing blur
        
        view.backgroundColor = .clear
        
        // 2
        let blurEffect = UIBlurEffect(style: .light)

        // 3
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        // 4
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)

        NSLayoutConstraint.activate([
          blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
          blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
          ])
        
        let layer = CALayer()
             
        if let filter = CIFilter(name:"CIGaussianBlur") {
            filter.name = "myFilter"
            layer.backgroundFilters = [filter]
            layer.setValue(2,
                           forKeyPath: "backgroundFilters.myFilter.inputRadius")
            
            view.layer.backgroundFilters?.append(filter)
        }
        
//        view.layer = CALayer()
//        view.layerUsesCoreImageFilters = true
//
//        let background = CATextLayer()
//        background.string = "background"
//        background.backgroundColor = NSColor.red.cgColor
//        background.alignmentMode = CATextLayerAlignmentMode.center
//        background.fontSize = 96
//        background.frame = CGRect(x: 10, y: 10, width: 640, height: 160)
//
//        let foreground = CATextLayer()
//        foreground.string = "foreground"
//        foreground.backgroundColor = NSColor.blue.cgColor
//        foreground.alignmentMode = CATextLayerAlignmentMode.center
//        foreground.fontSize = 48
//        foreground.opacity = 0.5
//        foreground.frame = CGRect(x: 20, y: 20, width: 600, height: 60)
//        foreground.masksToBounds = true
//
//        if let blurFilter = CIFilter(name: "CIGaussianBlur",
//                                     parameters: [kCIInputRadiusKey: 2]) {
//            foreground.backgroundFilters = [blurFilter]
//        }
//
//        view.layer?.addSublayer(background)
//        background.addSublayer(foreground)
        
    }
}
