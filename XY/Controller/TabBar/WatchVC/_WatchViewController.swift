//
//  PlayViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit
import AVFoundation

class _WatchViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private let pageViewController = SwipingPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var models = [(ChallengeModel, ChallengeVideoModel)]()
    private var loadedViewModels = [String: (ChallengeViewModel, ChallengeVideoViewModel)]()
    
    private var challengeViewModel: ChallengeViewModel?
    private var isModalPresented = false
    private var isFirstVideoSetUp = false
    
    private var uploadProgressView = XPCircleView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(for challenge: ChallengeViewModel, withHeroID heroID: String? = nil) {
        // Set back button enabled
        isModalPresented = true
        
        self.challengeViewModel = challenge
        
        super.init(nibName: nil, bundle: nil)
        
        models = []
        if let viewControllers = pageViewController.viewControllers {
            for vc in viewControllers {
                if let vc = vc as? VideoViewController {
                    vc.teardown()
                }
            }
        }
        
        ChallengesFirestoreManager.shared.getVideosForChallenge(challenge: challenge) { (challengeVideoModels) in
            if let challengeVideoModels = challengeVideoModels {
                self.models = challengeVideoModels.compactMap({ (challenge.toModel(), $0) })
                
                self.setUpFirstVideo()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
//        try? AVAudioSession.sharedInstance().setActive(true)

        view.addSubview(pageViewController.view)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        if challengeViewModel == nil {
            ChallengesFirestoreManager.shared.getMostRecentVideos { (pairs) in
                if let pairs = pairs {
                    self.models.append(contentsOf: pairs)
                }
                self.setUpFirstVideo()
            }
        }
        
        view.addSubview(uploadProgressView)
        uploadProgressView.setThickness(.thin)
        uploadProgressView.label.font = UIFont(name: "Raleway-Medium", size: 14)
        
        uploadProgressView.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isModalPresented {
            navigationController?.isNavigationBarHidden = true
        } else {
            navigationController?.isNavigationBarHidden = false
            navigationController?.navigationBar.backgroundColor = .clear
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.tintColor = UIColor(named: "XYTint")
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .done, target: self, action: #selector(didPressBack))
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if StorageManager.shared.videoUploadTask != nil {
            displayUploadProgress()
        }
        
        if UserDefaults.standard.object(forKey: "introMessageSeen") == nil {
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                if let viewControllers = self.pageViewController.viewControllers {
                    for vc in viewControllers {
                        if let vc = vc as? VideoViewController {
                            vc.player?.pause()
                        }
                    }
                }
                
                TabBarViewController.instance.popupPrompt(title: "Welcome to XY!", message: "Hi from XY’s team. We created XY to allow you to express yourself and to be pro-active for the world we live in. XY is played through challenges and we really don’t want to be suited because you’ll do dumb things, so, be brave but wise, scale the ranking and have fun!", confirmText: "I'm wise", completion: {
                    UserDefaults.standard.setValue(true, forKey: "introMessageSeen")
                })
                
            }
        }
        
        guard let viewControllers = pageViewController.viewControllers else {
            return
        }
        
        for vc in viewControllers {
            if let vc = vc as? VideoViewController {
                vc.reconfigure()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        
        guard let viewControllers = pageViewController.viewControllers else {
            return
        }
        
        if isModalPresented {
            for vc in viewControllers {
                if let vc = vc as? VideoViewController {
                    vc.player?.pause()
                    vc.teardown()
                }
            }
        } else {
            for vc in viewControllers {
                if let vc = vc as? VideoViewController {
                    vc.player?.pause()
                    vc.unloadFromMemory()
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageViewController.view.frame = view.bounds.inset(by: UIEdgeInsets.init(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
        
        uploadProgressView.frame = CGRect(
            x: 15,
            y: view.safeAreaInsets.top + 15,
            width: 34,
            height: 34
        )
    }
    
    private func displayUploadProgress() {
        uploadProgressView.setColor(UIColor(0x26FF88))
        
        uploadProgressView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.5) {
            self.uploadProgressView.alpha = 1.0
            self.uploadProgressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        var completeAnimation = false
        
        StorageManager.shared.subscribeToUploadProgress { (progress) in
            self.uploadProgressView.animateSetProgress(CGFloat(progress))
            self.uploadProgressView.setLabel(String(format: "%0.f%", progress*100).appending("%"))
            
            if progress >= 1.0, completeAnimation {
                completeAnimation = true
                
                UIView.animate(withDuration: 1.4, delay: 1.3, options: .curveEaseIn) {
                    self.uploadProgressView.alpha = 0.0
                }
            }
        }
    }
    
    private func setUpFirstVideo() {
        guard let model = models.first, !isFirstVideoSetUp else {
            return
        }
        
        isFirstVideoSetUp = true
        
        let vc = VideoViewController()
        buildVideoViewControllerWithPair(vc, model)

        pageViewController.setViewControllers(
            [vc],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    public func setFirstVideo(_ videoViewModel: ChallengeVideoViewModel, heroID: String) {
        guard let model = models.first, let challengeViewModel = challengeViewModel else {
            return
        }
        
        isFirstVideoSetUp = true
        
        let vc = VideoViewController()
        vc.configure(challengeVideoViewModel: videoViewModel, challengeViewModel: challengeViewModel)
        
        vc.isHeroEnabled = true
        vc.view.heroID = heroID

        pageViewController.setViewControllers(
            [vc],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? VideoViewController)?.videoViewModel else {
            return nil
        }
        
        guard let index = self.models.firstIndex(where: {
            $0.1.ID == fromPost.id
        }) else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        
        let priorIndex = index - 1
        let model = models[priorIndex]
        let vc = VideoViewController()
        vc.play()
        buildVideoViewControllerWithPair(vc, model)
        
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? VideoViewController)?.videoViewModel else {
            return nil
        }
        
        guard let index = models.firstIndex(where: {
            $0.1.ID == fromPost.id
        }) else {
            return nil
        }
        
        guard index < (models.count - 1) else {
            return nil
        }
        
        let priorIndex = index + 1
        let model = models[priorIndex]
        let vc = VideoViewController()
        vc.play()
        if let viewModelPair = loadedViewModels[model.1.ID] {
            vc.configure(challengeVideoViewModel: viewModelPair.1, challengeViewModel: viewModelPair.0)
        } else {
            buildVideoViewControllerWithPair(vc, model)
        }
        
        return vc
    }
    
    private func buildVideoViewControllerWithPair(_ vc: VideoViewController, _ pair: (ChallengeModel, ChallengeVideoModel)) {
        ChallengesViewModelBuilder.buildChallengeAndVideo(from: pair.1, challengeModel: pair.0) { (pair) in
            if let pair = pair {
                vc.configure(challengeVideoViewModel: pair.1, challengeViewModel: pair.0)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        for vc in previousViewControllers {
            if let vc = vc as? VideoViewController {
                vc.player?.pause()
                vc.unloadFromMemory()
            }
        }
    }
    
    private func prefetchNextVideo(for index: Int) {
        guard index >= 0, index < models.count else {
            return
        }
        print("Prefetching index: \(index)")
        let pair = models[index]
        
        ChallengesViewModelBuilder.buildChallengeAndVideo(from: pair.1, challengeModel: pair.0) { (pair) in
            if let pair = pair {
                self.loadedViewModels[pair.1.id] = pair
            }
        }
    }
    
    @objc private func didPressBack() {
        navigationController?.popViewController(animated: true)
    }
}
