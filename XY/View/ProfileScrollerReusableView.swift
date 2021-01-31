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

    let control: UISegmentedControl = {
        let titles = ["Profile", "For You"]
        let icons = [
            UIImage(named: "profile_profile_icon")?.withTintColor(.white, renderingMode: .alwaysOriginal),
            UIImage(named: "profile_settings_icon")?.withTintColor(.white, renderingMode: .alwaysOriginal)
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

        let profileViewController = ProfileHeaderViewController()
        horizontalScrollView.addSubview(profileViewController.view)
        viewControllers.append(profileViewController)
        
        let settingsViewController = ProfileHeaderSettingsViewController()
        horizontalScrollView.addSubview(settingsViewController.view)
        viewControllers.append(settingsViewController)
        
        addSubview(horizontalScrollView)
        addSubview(control)
        
        horizontalScrollView.contentSize = CGSize(width: width * 2, height: height)
        
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

        control.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: 30
        )
        
        for i in 0...viewControllers.count-1 {
            let viewController = viewControllers[i]
            viewController.view.frame = CGRect(
                x: horizontalScrollView.width * CGFloat(i),
                y: 0,
                width: horizontalScrollView.width,
                height: horizontalScrollView.height
            )
        }
    }
    
    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(CGPoint(x: width * CGFloat(sender.selectedSegmentIndex),
                                                      y: 0),
                                              animated: true)
    }
    
    func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        
    }
    
    public func setIsOwnProfile(isOwn: Bool) {
        control.isHidden = !isOwn
        horizontalScrollView.isScrollEnabled = isOwn
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
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x <= (width/2) {
            control.selectedSegmentIndex = 0
            
        } else if scrollView.contentOffset.x > (width/2) {
            control.selectedSegmentIndex = 1
        }
        
        
        for index in 0...control.numberOfSegments-1 {
            let image = control.imageForSegment(at: index)
            control.setImage(image?.withTintColor(.gray, renderingMode: .alwaysOriginal), forSegmentAt: index)
        }
        let selectedImage = control.imageForSegment(at: control.selectedSegmentIndex)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        control.setImage(selectedImage, forSegmentAt: control.selectedSegmentIndex)
    }
}
