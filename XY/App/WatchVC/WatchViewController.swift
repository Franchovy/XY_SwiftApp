//
//  WatchViewController.swift
//  XY
//
//  Created by Maxime Franchot on 09/04/2021.
//

import UIKit
import AVKit

class WatchViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var currentIndex = 0
    var playerViewControllers = [PlayerViewController]()
    
    var isCurrentlySwiping = false
    var currentSwipeSpeed: CGFloat?
    var currentSwipeOffset: CGFloat?
    
    let animationActivationOffset:CGFloat = 600
    let maxAnimationDuration:CGFloat = 0.4
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewControllers.append(PlayerViewController())
        
        setUpInitialPlayerController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.invisible)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !isCurrentlySwiping else {
            return
        }
        
        for playerViewControllerView in view.subviews.filter({$0.parentContainerViewController() is PlayerViewController}) {
            playerViewControllerView.frame = view.bounds
        }
    }
    
    // MARK: - Set up ViewControllers
    
    private func setUpInitialPlayerController() {
        guard currentIndex == 0 else {
            return
        }
        
        let playerVC = playerViewControllers[currentIndex]
        view.addSubview(playerVC.view)
        playerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
        
        playerVC.viewAppeared()
    }
    
    private func setUpNextPlayerController() {
        guard currentIndex < playerViewControllers.count else {
            return
        }
        
        let nextPlayerVC = playerViewControllers[currentIndex + 1]
        let currentPlayerVC = playerViewControllers[currentIndex]
        
        currentPlayerVC.pause()
        nextPlayerVC.play()
        
        view.insertSubview(nextPlayerVC.view, belowSubview: currentPlayerVC.view)
        
        nextPlayerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
    }
    
    private func setUpPrevPlayerController() {
        guard currentIndex > 0 else { return }
        
        let prevPlayerVC = playerViewControllers[currentIndex - 1]
        
        let currentPlayerVC = playerViewControllers[currentIndex]
        
        currentPlayerVC.pause()
        prevPlayerVC.play()
        
        let previousPlayerVC = playerViewControllers[currentIndex-1]
        view.insertSubview(prevPlayerVC.view, belowSubview: previousPlayerVC.view)

        prevPlayerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
    }
    
    // MARK: - Pan Gesture and Animation
    
    @objc private func didPanPlayerViewController(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let playerVCView = gestureRecognizer.view else {
            return
        }
        
        let vc = playerVCView.viewContainingController() as! PlayerViewController
        
        guard let indexOfVC = playerViewControllers.firstIndex(of: vc) else {
            return
        }
        
        if indexOfVC >= playerViewControllers.count - 1 {
//            playerViewControllers.append(PlayerViewController())
        }
        
        let dy = gestureRecognizer.translation(in: view).y
        let vy = gestureRecognizer.velocity(in: view).y
        
        currentSwipeOffset = dy
        currentSwipeSpeed = vy
        
        if gestureRecognizer.state == .began {
            isCurrentlySwiping = true
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            
            let passedLimit = animationActivationOffset < abs(dy + vy)
            
            if passedLimit {
                if dy < 0 {
                    animateScrollUp()
                } else {
                    animateScrollDown()
                }
                
            } else {
                animateReset()
            }
        } else if gestureRecognizer.state == .changed {
            setPositionForDrag(dragLength: dy)
        }
    }
    
    private func setPositionForDrag(dragLength: CGFloat) {
        let currentVC = playerViewControllers[currentIndex]
        let progressRatio = abs(dragLength) / animationActivationOffset

        if dragLength < 0 {
            
            guard playerViewControllers.count > currentIndex + 1 else {
                return
            }
            
            currentVC.view.transform = CGAffineTransform(
                translationX: 0,
                y: dragLength
            )
            
            let nextVC = playerViewControllers[currentIndex+1]
            
            if !view.subviews.contains(nextVC.view) {
                setUpNextPlayerController()
                nextVC.view.frame = self.view.bounds
            }
            
            nextVC.view.transform = CGAffineTransform(
                scaleX: min(1.0, progressRatio),
                y: min(1.0, progressRatio)
            )
            
        } else {
            guard currentIndex > 0 else {
                return
            }
            
            currentVC.view.transform = CGAffineTransform(
                scaleX: 1 - progressRatio,
                y: 1 - progressRatio
            )
            
            let prevVC = playerViewControllers[currentIndex-1]
            
            if !view.subviews.contains(prevVC.view) {
                setUpPrevPlayerController()
                prevVC.view.frame = self.view.bounds
            }
            
            prevVC.view.transform = CGAffineTransform(
                translationX: 0,
                y: -view.height + dragLength
            )
        }
    }
    
    private func animateScrollUp() {
        let currentVC = playerViewControllers[currentIndex]
        
        guard playerViewControllers.count > currentIndex + 1 else {
            return
        }
        let nextVC = playerViewControllers[currentIndex+1]
        
        self.currentIndex += 1
        
        let distanceLeft = animationActivationOffset - currentSwipeOffset!
        let animationDuration = min(distanceLeft / currentSwipeSpeed!, maxAnimationDuration)
        
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .beginFromCurrentState) {
            currentVC.view.transform = CGAffineTransform(translationX: 0, y: -self.view.height)
            nextVC.view.transform = .identity
            
        } completion: { (done) in
            if done {
                currentVC.view.removeFromSuperview()
                self.isCurrentlySwiping = false
                
                currentVC.view.transform = .identity
                nextVC.view.transform = .identity
            }
        }
    }
    
    private func animateReset() {
        let currentVC = playerViewControllers[currentIndex]
        
        let nextVC = playerViewControllers.count > currentIndex + 1 ? playerViewControllers[currentIndex+1] : nil
        
        
        let distanceLeft = animationActivationOffset - currentSwipeOffset!
        let animationDuration = min(distanceLeft / currentSwipeSpeed!, maxAnimationDuration)
        
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .beginFromCurrentState) {
            currentVC.view.transform = .identity
            nextVC?.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            
        } completion: { (done) in
            if done {
                nextVC?.view.removeFromSuperview()
                self.isCurrentlySwiping = false
                
                currentVC.view.transform = .identity
                nextVC?.view.transform = .identity
                currentVC.play()
                nextVC?.pause()
            }
        }
    }
    
    private func animateScrollDown() {
        guard currentIndex != 0 else {
            return
        }
        let currentVC = playerViewControllers[currentIndex]
        let nextVC = playerViewControllers[currentIndex-1]
        
        self.currentIndex -= 1
        
        let distanceLeft = animationActivationOffset - currentSwipeOffset!
        let animationDuration = min(distanceLeft / currentSwipeSpeed!, maxAnimationDuration)
        
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .beginFromCurrentState) {
            currentVC.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            nextVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        } completion: { (done) in
            if done {
                currentVC.view.removeFromSuperview()
                self.isCurrentlySwiping = false
                
                currentVC.view.transform = .identity
                nextVC.view.transform = .identity
            }
        }
    }
}
