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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewControllers.append(PlayerViewController())
        playerViewControllers.append(PlayerViewController())
        playerViewControllers.append(PlayerViewController())
        playerViewControllers.append(PlayerViewController())
        playerViewControllers.append(PlayerViewController())
        
        setUpPlayerController(index: currentIndex)
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
    
    private func setUpPlayerController(index: Int) {
        let playerVC = playerViewControllers[index]
        
        if index > 0, index < playerViewControllers.count {
            let previousPlayerVC = playerViewControllers[index-1]
            
            view.insertSubview(playerVC.view, belowSubview: previousPlayerVC.view)
        } else {
            view.addSubview(playerVC.view)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:)))
        
        playerVC.view.addGestureRecognizer(panGesture)
    }
    
    @objc private func didPanPlayerViewController(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let playerVCView = gestureRecognizer.view else {
            return
        }
        
        let vc = playerVCView.viewContainingController() as! PlayerViewController
        
        guard let indexOfVC = playerViewControllers.firstIndex(of: vc) else {
            return
        }
        
        if indexOfVC >= playerViewControllers.count - 1 {
            playerViewControllers.append(PlayerViewController())
        }
        
        let dy = gestureRecognizer.translation(in: view).y
        let vy = gestureRecognizer.velocity(in: view).y
        let progressRatio = -dy / 600
        
        if gestureRecognizer.state == .began {
            isCurrentlySwiping = true
        } else if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            
            let limit:CGFloat = 300
            let passedLimit = limit < abs(dy + vy)
            print("Passed limit: \(passedLimit)")
            print("values: dy: \(dy), vy: \(vy)")
            
            if passedLimit {
                let nextVC = playerViewControllers[currentIndex+1]
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState) {
                    vc.view.transform = CGAffineTransform(translationX: 0, y: -self.view.height)
                    nextVC.view.transform = .identity
                    
                } completion: { (done) in
                    if done {
                        vc.view.removeFromSuperview()
                        self.isCurrentlySwiping = false
                        self.currentIndex += 1
                    }
                }
            } else {
                let nextVC = playerViewControllers[currentIndex+1]
                
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .beginFromCurrentState) {
                    vc.view.transform = .identity
                    nextVC.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    
                } completion: { (done) in
                    if done {
                        nextVC.view.removeFromSuperview()
                        self.isCurrentlySwiping = false
                    }
                }
            }
            
            return
        }
        
        playerVCView.transform = CGAffineTransform(
            translationX: 0,
            y: dy
        )
        
        let nextVC = playerViewControllers[indexOfVC+1]
        
        if !view.subviews.contains(nextVC.view) {
            setUpPlayerController(index: indexOfVC+1)
            view.insertSubview(nextVC.view, belowSubview: playerVCView)
            nextVC.view.frame = self.view.bounds
        }
        
        nextVC.view.transform = CGAffineTransform(
            scaleX: min(1.0, progressRatio),
            y: min(1.0, progressRatio)
        )
    }
    
}
