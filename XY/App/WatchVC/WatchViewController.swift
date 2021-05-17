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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch let error {
            print(error.localizedDescription)
        }
        
        for challengeVideoModel in ChallengeDataManager.shared.activeChallenges {
            let playerViewController = PlayerViewController()
            
            if let downloadUrl = challengeVideoModel.getVideoUrl() {
                print(downloadUrl)
                playerViewController.configureVideo(from: downloadUrl)
            } else {
                ChallengeDataManager.shared.loadVideosForChallengeModel(for: challengeVideoModel) { (error) in
                    if let error = error {
                        print("Error fetching video for challenge: \(error.localizedDescription)")
                    } else {
                        guard let url = challengeVideoModel.getVideoUrl() else {
                            fatalError("Video Url is not loaded even after loading videos is called!")
                        }
                        
                        playerViewController.configureVideo(from: url)
                    }
                }
            }
            
            playerViewController.configureChallengeCard(with: challengeVideoModel.toCard(), profileViewModel: challengeVideoModel.fromUser!.toViewModel())
            playerViewController.view.frame = view.bounds
            playerViewController.headerViewDelegate = self
            
            playerViewControllers.append(playerViewController)
        }
        
        setUpInitialPlayerController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.configureBackgroundStyle(.invisible)
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let playerViewController = playerViewControllers[currentIndex]
        playerViewController.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let playerViewController = playerViewControllers[currentIndex]
        playerViewController.pause()
        
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
    
    public func setIndex(_ index: Int) {
        currentIndex = index
    }
    
    private func setUpInitialPlayerController() {
        
        let playerVC = playerViewControllers[currentIndex]
        view.addSubview(playerVC.view)
        playerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
        
        playerVC.displayButtons()
    }
    
    private func setUpNextPlayerController() {
        guard currentIndex < playerViewControllers.count else {
            return
        }
        
        let nextPlayerVC = playerViewControllers[currentIndex + 1]
        let currentPlayerVC = playerViewControllers[currentIndex]
        
        currentPlayerVC.pause()
        
        view.insertSubview(nextPlayerVC.view, belowSubview: currentPlayerVC.view)
        
        nextPlayerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
    }
    
    private func setUpPrevPlayerController() {
        guard currentIndex > 0 else { return }
        
        let prevPlayerVC = playerViewControllers[currentIndex - 1]
        let currentPlayerVC = playerViewControllers[currentIndex]
        
        currentPlayerVC.pause()
        
        let previousPlayerVC = playerViewControllers[currentIndex-1]
        view.insertSubview(prevPlayerVC.view, belowSubview: previousPlayerVC.view)

        prevPlayerVC.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPanPlayerViewController(_:))))
    }
    
    private func draggedIntoNewPlayerController(displayButtons: Bool = true) {
        let currentPlayerVC = playerViewControllers[currentIndex]
        
        currentPlayerVC.play()
        
        if displayButtons {
            currentPlayerVC.displayButtons()
        }
        currentPlayerVC.viewed = true
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
        nextVC.prepareForDisplay()
        
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
                
                self.draggedIntoNewPlayerController()
            }
        }
    }
    
    private func animateReset() {
        let currentVC = playerViewControllers[currentIndex]
        let prevVC = currentIndex > 0 ? playerViewControllers[currentIndex-1] : nil
        let nextVC = playerViewControllers.count > currentIndex + 1 ? playerViewControllers[currentIndex+1] : nil
        
        let distanceLeft = animationActivationOffset - currentSwipeOffset!
        let animationDuration = min(distanceLeft / currentSwipeSpeed!, maxAnimationDuration)
        
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: 0.0, options: .beginFromCurrentState) {
            currentVC.view.transform = .identity
            nextVC?.view.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            prevVC?.view.transform = CGAffineTransform(translationX: 0, y: -self.view.height)
            
        } completion: { (done) in
            if done {
                nextVC?.view.removeFromSuperview()
                prevVC?.view.removeFromSuperview()
                self.isCurrentlySwiping = false
                
                currentVC.view.transform = .identity
                nextVC?.view.transform = .identity
                prevVC?.view.transform = .identity
                
                self.draggedIntoNewPlayerController(displayButtons: false)
            }
        }
    }
    
    private func animateScrollDown() {
        guard currentIndex != 0 else {
            return
        }
        let currentVC = playerViewControllers[currentIndex]
        let nextVC = playerViewControllers[currentIndex-1]
        nextVC.prepareForDisplay()
        
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
                
                self.draggedIntoNewPlayerController()
            }
        }
    }
}

extension WatchViewController : VideoHeaderViewDelegate {
    func pressedAccept(viewModel: ChallengeCardViewModel) {
        guard let challengeID = viewModel.coreDataID else {
            return
        }
        ChallengeDataManager.shared.updateChallengeState(challengeID: challengeID, newState: .accepted)
        NavigationControlManager.startChallenge(with: viewModel)
    }
    
    func pressedReject(viewModel: ChallengeCardViewModel) {
        let prompt = Prompt()
        prompt.setTitle(text: "Reject Challenge")
        prompt.addText(text: "If you reject this challenge, you won't be able to perform it.")
        prompt.addCompletionButton(
            buttonText: "Reject",
            textColor: UIColor(0xEF3A30),
            style: .embedded,
            closeOnTap: true,
            onTap: {
                guard let challengeID = viewModel.coreDataID else {
                    return
                }
                ChallengeDataManager.shared.updateChallengeState(challengeID: challengeID, newState: .rejected)
                NavigationControlManager.mainViewController.navigationController?.pushViewController(RejectedChallengeViewController(viewModel: viewModel), animated: true)
            }
        )
        prompt.addCompletionButton(
            buttonText: "Cancel",
            style: .embedded,
            closeOnTap: true
        )
        prompt.backgroundStyle = .fade
    
        NavigationControlManager.displayPrompt(prompt)
    }
    
    func pressedPlay(viewModel: ChallengeCardViewModel) {
        NavigationControlManager.startChallenge(with: viewModel)
    }
}
