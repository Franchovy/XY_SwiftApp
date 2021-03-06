//
//  PlayViewController.swift
//  XY
//
//  Created by Maxime Franchot on 06/03/2021.
//

import UIKit

class PlayViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var models = [VideoModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
//        try? AVAudioSession.sharedInstance().setActive(true)

        view.addSubview(pageViewController.view)
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        print("Init")
        
        VideoFirestoreManager.shared.fetchVideos() { videoModels in
            if let videoModels = videoModels {
                print("Fetched videos")
                self.models = videoModels
                self.setUpFirstVideo()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageViewController.view.frame = view.bounds.inset(by: UIEdgeInsets(top: view.safeAreaInsets.top, left: 0, bottom: view.safeAreaInsets.bottom, right: 0))
    }
    
    private func setUpFirstVideo() {
        guard let model = models.first else {
            return
        }
        
        let vc = VideoViewController(model: model)
        
        pageViewController.setViewControllers(
            [vc],
            direction: .forward,
            animated: false,
            completion: nil
        )
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? VideoViewController)?.model else {
            return nil
        }
        
        guard let index = models.firstIndex(where: {
            $0.id == fromPost.id
        }) else {
            return nil
        }
        
        if index == 0 {
            return nil
        }
        
        let priorIndex = index - 1
        let model = models[priorIndex]
        let vc = VideoViewController(model: model)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let fromPost = (viewController as? VideoViewController)?.model else {
            return nil
        }
        
        guard let index = models.firstIndex(where: {
            $0.id == fromPost.id
        }) else {
            return nil
        }
        
        guard index < (models.count - 1) else {
            return nil
        }
        
        let priorIndex = index + 1
        let model = models[priorIndex]
        let vc = VideoViewController(model: model)
        return vc
    }
    
}
