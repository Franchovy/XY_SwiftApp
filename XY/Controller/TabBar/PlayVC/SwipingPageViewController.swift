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
        
        videoViewController.view.transform =
            CGAffineTransform(translationX: translationX, y: -abs(translationX*1/3)).rotated(by: (translationX/view.width)/13*CGFloat.pi)
        
        switch gestureRecognizer.state {
        case .began:
            break
        case .changed:
            break
        case .ended, .cancelled:
            // Un-Cling
            
            
            returnToCenter()
            
            isSwipeActive = false
        default:
            break
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func animateForDrag() {
        
    }
    
    private func cling() {
        clinged = true
    }
    
    private func uncling() {
        clinged = false
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
