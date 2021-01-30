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
    
    private let view1: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private let view2: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(horizontalScrollView)
        addSubview(control)
        
        setUpFeed()
        horizontalScrollView.contentInsetAdjustmentBehavior = .never
        horizontalScrollView.delegate = self
        horizontalScrollView.contentOffset = CGPoint(x: width, y: 0)
        
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
        
        view1.frame = CGRect(x: 0,
             y: 0,
             width: horizontalScrollView.width,
             height: horizontalScrollView.height)
        
        view2.frame = CGRect(x: horizontalScrollView.width,
             y: 0,
             width: horizontalScrollView.width,
             height: horizontalScrollView.height)
        
    }
    
    @objc private func didChangeSegmentControl(_ sender: UISegmentedControl) {
        horizontalScrollView.setContentOffset(CGPoint(x: width * CGFloat(sender.selectedSegmentIndex),
                                                      y: 0),
                                              animated: true)
    }
    
    public func setUpNavigationBarForViewController(_ vc: UIViewController) {
        
        vc.navigationItem.titleView = control
    }

    func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        
    }
    
    private func setUpFeed() {
        horizontalScrollView.contentSize = CGSize(width: width * 2, height: height)
        setUpFollowingFeed()
        setUpForYouFeed()
    }

    func setUpFollowingFeed() {
        horizontalScrollView.addSubview(view1)
    }

    func setUpForYouFeed() {
        horizontalScrollView.addSubview(view2)
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
