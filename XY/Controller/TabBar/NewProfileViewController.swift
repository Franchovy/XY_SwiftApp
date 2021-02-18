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
    private var topScrollIndicatorIcon: UIImageView?
    private var bottomScrollIndicator: UIView?
    private var bottomScrollIndicatorLabel: UILabel?
    private var bottomScrollIndicatorIcon: UIImageView?
    
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

        setupBottomScrollIndicator()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let topScrollIndicator = topScrollIndicator {
            topScrollIndicator.frame = CGRect(
                x: 0,
                y: 0,
                width: view.width,
                height: 67
            )
            let iconSize: CGFloat = 20
            topScrollIndicatorIcon?.frame = CGRect(
                x: (topScrollIndicator.width - iconSize)/2,
                y: 40,
                width: iconSize,
                height: iconSize
            )
        }
        
        pageViewController.view.frame = CGRect(
            x: 0,
            y: topScrollIndicator?.bottom ?? 88,
            width: view.width,
            height: 575
        )
        
        if let bottomScrollIndicator = bottomScrollIndicator,
           let bottomScrollIndicatorLabel = bottomScrollIndicatorLabel,
           let bottomScrollIndicatorIcon = bottomScrollIndicatorIcon {
            bottomScrollIndicator.frame = CGRect(
                x: 0,
                y: pageViewController.view.bottom,
                width: view.width,
                height: 67
            )
            
            bottomScrollIndicatorLabel.sizeToFit()
            bottomScrollIndicatorLabel.frame = CGRect(
                x: (bottomScrollIndicator.width - bottomScrollIndicatorLabel.width)/2,
                y: 0,
                width: bottomScrollIndicatorLabel.width,
                height: bottomScrollIndicatorLabel.height
            )
            
            let iconSize: CGFloat = 20
            bottomScrollIndicatorIcon.frame = CGRect(
                x: (bottomScrollIndicator.width - iconSize)/2,
                y: bottomScrollIndicatorLabel.bottom + 3,
                width: iconSize,
                height: iconSize
            )
        }
    }
    
    private func setUpNavBar() {
        guard let viewModel = viewModel else {
            return
        }
        
        if let navBar = navigationController?.navigationBar {
            
            let titleView = UIView()
            let titleLabel = UILabel()
            titleLabel.font = UIFont(name: "Raleway-ExtraBold", size: 30)
            titleLabel.text = viewModel.nickname
            titleLabel.textColor = .white
            titleView.addSubview(titleLabel)
            
            
            let xpCircle = CircleView()
            let xpToNextLevel = Float(XPModelManager.shared.getXpForNextLevelOfType(viewModel.level, .user))
            xpCircle.setProgress(level: viewModel.level, progress: Float(viewModel.xp) / xpToNextLevel)
            xpCircle.setupFinished()
            titleView.addSubview(xpCircle)
            
            titleView.frame = CGRect(
                x: 0,
                y: 0,
                width: 400,
                height: 45
            )
            let xpCircleSize:CGFloat = 25
            
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(
                x: (titleView.width - titleLabel.width)/2 - 8 - xpCircleSize,
                y: (titleView.height - titleLabel.height)/2,
                width: titleLabel.width,
                height: titleLabel.height
            )
            
            xpCircle.frame = CGRect(
                x: titleLabel.right + 8,
                y: titleLabel.top + (titleView.height - xpCircleSize)/2 - 5,
                width: xpCircleSize,
                height: xpCircleSize
            )
            
            navigationItem.titleView = titleView
            
        }
    }
    
    private func setupTopScrollIndicator() {
        let topScrollIndicator = UIView()
        
        let icon = UIImageView(image: UIImage(systemName: "arrowtriangle.up.fill"))
        icon.contentMode = .scaleAspectFit
        topScrollIndicator.addSubview(icon)
        topScrollIndicatorIcon = icon
        
        self.topScrollIndicator = topScrollIndicator
    }
    
    private func setupBottomScrollIndicator() {
        let bottomScrollIndicator = UIView()
        
        let label = UILabel()
        label.text = "Live Posts"
        label.textColor = .white
        label.font = UIFont(name: "Raleway-ExtraBold", size: 20)
        bottomScrollIndicator.addSubview(label)
        bottomScrollIndicatorLabel = label
        
        let icon = UIImageView(image: UIImage(systemName: "arrowtriangle.down.fill"))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        bottomScrollIndicator.addSubview(icon)
        bottomScrollIndicatorIcon = icon
        
        view.addSubview(bottomScrollIndicator)
        self.bottomScrollIndicator = bottomScrollIndicator
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
        setUpNavBar()
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
