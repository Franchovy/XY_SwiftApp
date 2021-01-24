//
//  BlurMenuViewController.swift
//  XY
//
//  Created by Maxime Franchot on 24/01/2021.
//

import UIKit

protocol BlurMenuViewControllerDelegate {
    func blurMenuViewControllerDelegate(blurMenu: BlurMenuViewController, onButtonSelected: ButtonType)
}

enum ButtonType {
    case post
    case moment
}

class BlurMenuViewController: UIViewController {
        
    var delegate: BlurMenuViewControllerDelegate?
    
    private var blurAnimator: UIViewPropertyAnimator?
    private var exitBlurAnimator: UIViewPropertyAnimator?
    
    private var blurChooseMenuView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        
        var blurChooseMenuView = UIVisualEffectView(effect: blurEffect)
        
        blurChooseMenuView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurChooseMenuView
    }()
    
    private var postButton: UIButton = {
        let button = UIButton()
        let titleLabel = UILabel()
        button.setTitle("Post", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 30)
        
        button.tintColor = .white
        return button
    }()
    
    private var momentButton: UIButton = {
        let button = UIButton()
        let titleLabel = UILabel()
        button.setTitle("Moment", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 30)
        
        button.tintColor = .white
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(blurChooseMenuView)
        view.addSubview(postButton)
        view.addSubview(momentButton)
        
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        postButton.addTarget(self, action: #selector(momentButtonTapped), for: .touchUpInside)
        
        // Setup blur animator
        blurAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [blurChooseMenuView] in
            blurChooseMenuView.effect = UIBlurEffect(style: .light)
        }
        blurAnimator!.fractionComplete = 0.15 // set the blur intensity.
        
        exitBlurAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) { [blurChooseMenuView] in
            blurChooseMenuView.effect = .none
        }
        
    }

    override func viewDidLayoutSubviews() {
        blurChooseMenuView.frame = view.bounds
        
        postButton.sizeToFit()
        postButton.center = view.center.applying(CGAffineTransform(scaleX: 0.5, y: 1))
        
        momentButton.sizeToFit()
        momentButton.center = view.center.applying(CGAffineTransform(scaleX: 1.5, y: 1))
    }
    
    @objc private func postButtonTapped() {
        delegate?.blurMenuViewControllerDelegate(blurMenu: self, onButtonSelected: .post)
        dismissAnimated()
    }
    
    @objc private func momentButtonTapped() {
        delegate?.blurMenuViewControllerDelegate(blurMenu: self, onButtonSelected: .moment)
        dismissAnimated()
    }
    
    func dismissAnimated() {
        exitBlurAnimator?.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.removeFromSuperview()
        }
    }
}
