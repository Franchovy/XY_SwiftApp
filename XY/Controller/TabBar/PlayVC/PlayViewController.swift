//
//  PlayViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit
import AVFoundation

class PlayViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private let pageViewController = SwipingPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var models = [(ChallengeModel, ChallengeVideoModel)]()
    private var loadedViewModels = [String: (ChallengeViewModel, ChallengeVideoViewModel)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

        view.addSubview(pageViewController.view)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        ChallengesFirestoreManager.shared.getMostRecentVideos { (pairs) in
            if let pairs = pairs {
                self.models.append(contentsOf: pairs)
            }
            self.setUpFirstVideo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        for vc in viewControllers {
            if let vc = vc as? VideoViewController {
                vc.unloadFromMemory()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageViewController.view.frame = view.bounds.inset(by: UIEdgeInsets.init(top: 0, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
    }
    
    public func configure(for challengeViewModel: ChallengeViewModel, withHeroID heroID: String? = nil) {
        
        ChallengesFirestoreManager.shared.getVideosForChallenge(challenge: challengeViewModel, limitTo: 15) { (challengeVideoModels) in
            if let challengeVideoModels = challengeVideoModels {
                self.models = challengeVideoModels.compactMap({ (challengeViewModel.toModel(), $0) })
            }
        }
    }
    
    private func setUpFirstVideo() {
        guard let model = models.first else {
            return
        }
        
        let vc = VideoViewController()
        vc.delegate = self
        buildVideoViewControllerWithPair(vc, model)

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
        vc.delegate = self
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
        vc.delegate = self
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
}

extension PlayViewController : VideoViewControllerDelegate {
    func didTapTitle(for viewModel: ChallengeViewModel) {
        let exploreChallengeVC = ExploreChallengeViewController(challengeViewModel: viewModel)
    
        navigationController?.pushViewController(exploreChallengeVC, animated: true)
    }
}
