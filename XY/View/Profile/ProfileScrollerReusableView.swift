//
//  ProfileScrollerReusableView.swift
//  XY
//
//  Created by Maxime Franchot on 30/01/2021.
//

import UIKit

class ProfileScrollerReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileScrollerReusableView"
    
    let horizontalScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    let topBar: UIView = {
        let view = UIView()
        return view
    }()
    
    let control: UISegmentedControl = {
        let titles = ["Profile", "For You"]
        let icons = [
            UIImage(named: "profile_profile_icon")?.withTintColor(UIColor(0xF6F6F6), renderingMode: .alwaysOriginal),
            UIImage(named: "profile_conversations_icon")?.withTintColor(UIColor(0xB6B6B6), renderingMode: .alwaysOriginal),
            UIImage(named: "profile_settings_icon")?.withTintColor(UIColor(0xB6B6B6), renderingMode: .alwaysOriginal)
        ]
        let control = UISegmentedControl(items: icons)
        
        control.selectedSegmentIndex = 0
        control.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        control.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        control.backgroundColor = .clear
        control.selectedSegmentTintColor = .clear
        
        return control
    }()
    
    private var viewControllers = [UIViewController]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layer.cornerRadius = 15

        let profileViewController = ProfileHeaderViewController()
        profileViewController.delegate = self
        horizontalScrollView.addSubview(profileViewController.view)
        viewControllers.append(profileViewController)
        
        let chatViewController = ProfileHeaderChatViewController()
        horizontalScrollView.addSubview(chatViewController.view)
        viewControllers.append(chatViewController)
        
        let settingsViewController = ProfileHeaderSettingsViewController()
        settingsViewController.delegate = self
        horizontalScrollView.addSubview(settingsViewController.view)
        viewControllers.append(settingsViewController)
        
        addSubview(horizontalScrollView)
        addSubview(topBar)
        topBar.addSubview(control)

        horizontalScrollView.contentSize = CGSize(
            width: width * CGFloat(viewControllers.count),
            height: height
        )
        
        horizontalScrollView.contentInsetAdjustmentBehavior = .never
        horizontalScrollView.delegate = self
    
        setUpHeaderButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        horizontalScrollView.frame = bounds

        var topBarHeight: CGFloat = 30
        topBar.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: topBarHeight
        )
        
        control.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: topBarHeight
        )
        
        for i in 0...viewControllers.count-1 {
            let viewController = viewControllers[i]
            viewController.view.frame = CGRect(
                x: horizontalScrollView.width * CGFloat(i),
                y: topBarHeight,
                width: horizontalScrollView.width,
                height: horizontalScrollView.height - topBarHeight
            )
        }
    }
    
    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(CGPoint(x: width * CGFloat(sender.selectedSegmentIndex),
                                                      y: 0),
                                              animated: true)
    }
    
    @objc private func didTapAnywhere() {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            return
        }
        profileViewController.didTapAnywhere()
    }
    
    func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        
    }
    
    public func setIsOwnProfile(isOwn: Bool) {
//        control.isHidden = !isOwn
//        horizontalScrollView.isScrollEnabled = isOwn
    }
    
    public func configure(with viewModel: ProfileViewModel) {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            return
        }
        profileViewController.configure(with: viewModel)
    }
    
    public func getProfileDelegate() -> ProfileViewModelDelegate {
        guard let profileViewController = viewControllers[0] as? ProfileHeaderViewController else {
            fatalError()
        }
        return profileViewController
    }
}

extension ProfileScrollerReusableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x <= (width/2) {
            control.selectedSegmentIndex = 0
        } else if scrollView.contentOffset.x > (width/2) && scrollView.contentOffset.x < (3 * width/2){
            control.selectedSegmentIndex = 1
        } else if scrollView.contentOffset.x > (3 * width/2) {
            control.selectedSegmentIndex = 2
        }
        
        var selectedIndexColor = UIColor()
        var unselectedIndexColor = UIColor()
        
        selectedIndexColor = UIColor(0xF6F6F6)
        unselectedIndexColor = UIColor(0xB6B6B6)
        
        for index in 0...control.numberOfSegments-1 {
            let image = control.imageForSegment(at: index)
            control.setImage(image?.withTintColor(unselectedIndexColor, renderingMode: .alwaysOriginal), forSegmentAt: index)
        }
        let selectedImage = control.imageForSegment(at: control.selectedSegmentIndex)?.withTintColor(selectedIndexColor, renderingMode: .alwaysOriginal)
        control.setImage(selectedImage, forSegmentAt: control.selectedSegmentIndex)
    }
}

extension ProfileScrollerReusableView : ProfileHeaderViewControllerDelegate {
    func didEnterEditMode() {
        horizontalScrollView.isScrollEnabled = false
    }
    
    func didExitEditMode() {
        horizontalScrollView.isScrollEnabled = true
    }
}

extension ProfileScrollerReusableView : ProfileHeaderSettingsViewControllerDelegate {
    func didLogOut() {
        guard let superview = superview else {
            return
        }
        print(superview)
        guard let superviewController = superview.parentContainerViewController() as? TabBarViewController else {
            return
        }
        print(superviewController)
        
        superviewController.backToLaunch()
    }
}
