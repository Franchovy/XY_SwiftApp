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
        let titles = ["Following", "For You"]
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 1
        control.backgroundColor = nil
        control.selectedSegmentTintColor = .white
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

    func setUpHeaderButtons() {
        control.addTarget(self, action: #selector(didChangeSegmentControl(_:)), for: .valueChanged)
        parentContainerViewController()?.navigationItem.titleView = control
    }
    
    private func setUpFeed() {
        horizontalScrollView.contentSize = CGSize(width: width * 2, height: height)
        setUpFollowingFeed()
        setUpForYouFeed()
    }

    func setUpFollowingFeed() {
//        guard let model = followingPosts.first else {
//            return
//        }
//        let vc = PostViewController(model: model)
//        vc.delegate = self
//        followingnPageViewController.setViewControllers(
//            [vc],
//            direction: .forward,
//            animated: false,
//            completion: nil
//        )
//        followingnPageViewController.dataSource = self

//        horizontalScrollView.addSubview(followingnPageViewController.view)
        
        
        horizontalScrollView.addSubview(view1)
//        addChild(followingnPageViewController)
//        followingnPageViewController.didMove(toParent: self)
    }

    func setUpForYouFeed() {
//        guard let model = forYouPosts.first else {
//            return
//        }
//        let vc = PostViewController(model: model)
//        vc.delegate = self
//        forYouPageViewController.setViewControllers(
//            [vc],
//            direction: .forward,
//            animated: false,
//            completion: nil
//        )
//        forYouPageViewController.dataSource = self
//
//        horizontalScrollView.addSubview(forYouPageViewController.view)
        
        
        horizontalScrollView.addSubview(view2)
//        forYouPageViewController.view.frame = CGRect(x: view.width,
//                                             y: 0,
//                                             width: horizontalScrollView.width,
//                                             height: horizontalScrollView.height)
//        addChild(forYouPageViewController)
//        forYouPageViewController.didMove(toParent: self)
    }
}

extension ProfileScrollerReusableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x <= (width/2) {
            control.selectedSegmentIndex = 0
        } else if scrollView.contentOffset.x > (width/2) {
            control.selectedSegmentIndex = 1
        }
    }
}
