//
//  NewProfileViewController.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

class NewProfileViewController: UIViewController {

    private let pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .vertical,
        options: [:]
    )
    
    private var topScrollIndicator: UIView?
    private var bottomScrollIndicator: UIView?
    
    private var viewControllers = [UIViewController]()
    
    private var viewModel: NewProfileViewModel?
    
    init(userId: String) {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .clear
        
        view.addSubview(pageViewController.view)
        addChild(pageViewController)
        //pageViewController.didMove(to: self)
        
        ProfileManager.shared.fetchProfile(userId: userId) { result in
            switch result {
            case .success(let profileModel):
                ProfileViewModelBuilder.build(with: profileModel) { (profileViewModel) in
                    if let profileViewModel = profileViewModel {
                        self.configure(with: profileViewModel)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageViewController.view.frame = view.bounds
    }

    private func setUpPageViewController() {
        
        guard let profileViewModel = viewModel else {
            return
        }
        
        let profileHeaderVC = ProfileHeaderViewController()
        let profileLivePostsVC = ProfileLivePostsViewController()
        let profileCollectionPostsVC = ProfileCollectionViewController()
        
        profileHeaderVC.configure(with: profileViewModel)
        
        viewControllers.append(profileHeaderVC)
        viewControllers.append(profileLivePostsVC)
        viewControllers.append(profileCollectionPostsVC)
        
        pageViewController.setViewControllers(
            [profileHeaderVC],
            direction: .forward,
            animated: false,
            completion: nil
        )
        
        pageViewController.dataSource = self
    }
    
    func configure(with viewModel: NewProfileViewModel) {
        self.viewModel = viewModel
        
        setUpPageViewController()
    }
}

extension NewProfileViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index != 0 else {
            return nil
        }
        return viewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.firstIndex(of: viewController), index < viewControllers.count - 1 else {
            return nil
        }
        return viewControllers[index + 1]
    }
}
