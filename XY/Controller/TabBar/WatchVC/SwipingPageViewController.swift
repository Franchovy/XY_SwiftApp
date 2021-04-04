//
//  SwipingPageViewController.swift
//  XY
//
//  Created by Maxime Franchot on 12/03/2021.
//

import UIKit

class SwipingPageViewController: UIPageViewController, UIGestureRecognizerDelegate {

    var activeDraggedViewController: UIViewController?
    var clinged = false
    var isSwipeActive = false {
        didSet {
            enableScrolling(isEnabled: !isSwipeActive)
        }
    }
    var isTowardsRight = false
    var speedMultiplier: CGFloat = 1
    
    var confirmAnimation = false
    var currentXTranslation: CGFloat = 0
    
    var swipeLabel: UILabel?
    var swipeLabelScale:CGFloat = 1
    
    var random: Int!
    
    var hapticsManager: HapticsManager?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        
//        hapticsManager = HapticsManager()
        print("Haptics manager is \(hapticsManager == nil ? "nil" : "not nil")")
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        for gr in self.view.gestureRecognizers! {
            gr.delegate = self
        }
    }

    @objc private func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        // Perform swipe
        let translationX = gestureRecognizer.translation(in: view).x
        
        guard isSwipeActive || abs(translationX) > abs(gestureRecognizer.translation(in: view).y) else {
            returnToCenter()
            return
        }
        
        isSwipeActive = true
        
        guard let videoViewController = viewControllers?[0] as? VideoViewController else {
            return
        }
        activeDraggedViewController = videoViewController
        
        animateForDrag(translationX)
        
        if let swipeLabel = swipeLabel {
            let percentage:CGFloat = abs(translationX) / (view.width/2)
            swipeLabel.frame.origin = CGPoint(
                x: isTowardsRight ? videoViewController.view.left - 150 : videoViewController.view.right - 50,
                y: videoViewController.view.top + 350
            )
            
            let scale = percentage * 2.0
            swipeLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
            swipeLabel.alpha = percentage
            
            if gestureRecognizer.state != .ended {
                swipeLabelScale = scale
            }
        }
        
        switch gestureRecognizer.state {
        case .began:
            startSwipeLabel()
            
        case .changed:
            if swipeLabel == nil {
                startSwipeLabel()
            }
        case .ended, .cancelled:
            // Un-Cling
            var fadeStyle: UIView.AnimationOptions!
            
            if clinged {
                kaching()
                
                fadeStyle = .curveEaseIn
            } else {
                returnToCenter()
                
                fadeStyle = .curveLinear
            }
            
            if let swipeLabel = swipeLabel {
                self.swipeLabel = nil
                UIView.animate(withDuration: 0.4, delay: 0, options: fadeStyle) {
                    swipeLabel.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    swipeLabel.alpha = 0.0
                    swipeLabel.frame.origin.x = self.isTowardsRight ? 0 : self.view.width
                } completion: { (done) in
                    if done {
                        swipeLabel.removeFromSuperview()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    private func startSwipeLabel() {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 20)
        label.adjustsFontSizeToFitWidth = true
        label.frame.size = CGSize(width: 150, height: 50)
        label.textColor = UIColor(named: "XYTint")
        
        random = Int.random(in: 0...4)
        
        label.text = isTowardsRight ?
            ["Wow", "Amazing", "Super", "Love it", "Incredible", "lol", "Dope"][Int.random(in: 0...6)] :
            ["Ughhh", "Boooring", "This sucks", "Really?", "Loser"][random]
        
        label.alpha = 0.0
        label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        view.addSubview(label)
        
        swipeLabel = label
    }
    
    private func enableScrolling(isEnabled: Bool) {
        for subview in view.subviews {
            if let scrollview = subview as? UIScrollView {
                scrollview.isScrollEnabled = isEnabled
                break
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func animateForDrag(_ x: CGFloat) {
        let translationX = confirmAnimation ? currentXTranslation : x
        
        if !confirmAnimation {
            currentXTranslation = x
        }
        
        isTowardsRight = translationX == abs(translationX)
        
        activeDraggedViewController?.view.transform =
            CGAffineTransform(
                translationX: translationX,
                y: -abs(translationX*1/3)
            ).rotated(
                by: (translationX/view.width)/13*CGFloat.pi
            )
        
        if abs(x) > view.width/2 {
            cling()
        } else if clinged {
            uncling()
        }
    }
    
    private func kaching() {
        guard let activeDraggedViewController = activeDraggedViewController as? VideoViewController else {
            return
        }
        
        confirmAnimation = true
        activeDraggedViewController.view.layer.removeAllAnimations()
        activeDraggedViewController.view.springScaleAnimate(from: 0.9, to: 1.0)
        hapticsManager?.vibrate(for: .success)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            activeDraggedViewController.shadowLayer.shadowOffset = CGSize(width: 10, height: 10)
            
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn) {
                    activeDraggedViewController.shadowLayer.shadowOffset = CGSize(width: 0, height: 8)
                    activeDraggedViewController.view.transform = activeDraggedViewController.view.transform.translatedBy(
                        x: self.isTowardsRight ? -70 : 70,
                        y: 30
                    )
                } completion: { (done) in
                    if done {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.28) {
                            self.confirmAnimation = false
                            activeDraggedViewController.view.stopSpringScaleAnimate()
                            self.uncling()
                            self.returnToCenter()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+0.35) {
                                if self.isTowardsRight {
                                    activeDraggedViewController.swipedRight()
                                } else {
                                    activeDraggedViewController.swipedLeft()
                                }
                            }
                        }
                    }
                }
            }
        }
        
        guard let swipeLabel = swipeLabel else {
            return
        }
        
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Heavy", size: 45)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(named: "XYTint")
        label.text = isTowardsRight ?
            ["😍","😱","🤯","😮","😎"][Int.random(in: 0...4)] :
            ["🤮","🥱","😡","😒","😫"][random]
        label.sizeToFit()
        let startPoint = swipeLabel.frame.origin.applying(
            CGAffineTransform(
                translationX: isTowardsRight ? 25 : 25,
                y: 100
            )
        )
        let topScale = swipeLabelScale
        label.frame.origin = startPoint
        label.alpha = 0.0
        label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        
        view.addSubview(label)
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) {
            label.alpha = 1.0
            label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                    label.transform = CGAffineTransform(scaleX: max(topScale, 1.2), y: max(topScale, 1.2))
                } completion: { (done) in
                    if done {
                        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) {
                            label.alpha = 0.0
                            label.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        } completion: { (done) in
                            if done {
                                label.removeFromSuperview()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func cling() {
        guard clinged == false, let activeDraggedViewController = activeDraggedViewController else {
            return
        }
        
        clinged = true
        
//        hapticsManager?.playSlowVibrate()

        if let activeDraggedViewController = activeDraggedViewController as? VideoViewController {
            activeDraggedViewController.shadowLayer.shadowColor = isTowardsRight ? UIColor.green.cgColor : UIColor.red.cgColor
        }
        
        activeDraggedViewController.view.scaleAnimate(0.9, duration: 0.1)
    }
    
    private func uncling() {
        guard clinged == true else {
            return
        }
        
//        hapticsManager?.stopSlowVibrate()
        
        if let activeDraggedViewController = activeDraggedViewController as? VideoViewController {
            activeDraggedViewController.shadowLayer.shadowColor = UIColor.black.cgColor
        }
        
        clinged = false
        self.activeDraggedViewController?.view.stopScaleAnimate(0.9, duration: 0.1)
    }
    
    private func returnToCenter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.activeDraggedViewController?.view.transform = CGAffineTransform.identity
        } completion: { (done) in
            if done {
                self.isSwipeActive = false
            }
        }
    }
    
    private func getRotationForTranslationX(_ x: CGFloat) -> CGFloat {
        (x - view.width/2)
    }
}
