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
    var isSwipeActive = false
    
    var speedMultiplier: CGFloat = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            break
        case .ended, .cancelled:
            // Un-Cling
            uncling()
            
            returnToCenter()
            
            isSwipeActive = false
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func animateForDrag(_ x: CGFloat) {
        let translationX = x
        
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
    
    private func cling() {
        guard clinged == false, let activeDraggedViewController = activeDraggedViewController else {
            return
        }
        
        clinged = true

        activeDraggedViewController.view.scaleAnimate(0.9, duration: 0.1)
    }
    
    private func uncling() {
        guard clinged == true else {
            return
        }
        
        clinged = false
        self.activeDraggedViewController?.view.stopScaleAnimate(0.9, duration: 0.1)
    }
    
    private func returnToCenter() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
            self.activeDraggedViewController?.view.transform = CGAffineTransform.identity
        } completion: { (done) in
            if done {
                
            }
        }
    }
    
    private func getRotationForTranslationX(_ x: CGFloat) -> CGFloat {
        (x - view.width/2)
    }
}
