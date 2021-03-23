//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

class XYworldVC: UIViewController, UISearchBarDelegate {
    
    let onlineNowTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Online Now"
        label.font = UIFont(name: "Raleway-Heavy", size: 25)
        label.textColor = UIColor(named: "XYTint")
        return label
    }()
    
    let rankingTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ranking"
        label.font = UIFont(name: "Raleway-Heavy", size: 25)
        label.textColor = UIColor(named: "XYTint")
        return label
    }()
    
    let onlineNowView = OnlineNowView()
    let rankingView = RankingView()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    let barXPCircle: CircleView = {
        let circleView = CircleView()
        circleView.setProgress(level: 0, progress: 0.0)
        circleView.setupFinished()
        circleView.setLevelLabelFontSize(size: 24)
        circleView.registerXPUpdates(for: .ownUser)
        return circleView
    }()
    
    private var rankingHeight: CGFloat = 270
    
    // MARK: - Properties
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        navigationItem.titleView = UIImageView(image: UIImage(named: "XYNavbarLogo"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barXPCircle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named: "Black")
        
        view.addSubview(scrollView)
        scrollView.addSubview(onlineNowTitleLabel)
        scrollView.addSubview(rankingTitleLabel)
        scrollView.addSubview(onlineNowView)
        scrollView.addSubview(rankingView)
        
        rankingView.subscribeToRanking()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        
        barXPCircle.registerXPUpdates(for: .ownUser)
        
        onlineNowView.subscribeToOnlineNow()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        barXPCircle.deregisterUpdates()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        barXPCircle.frame.size = CGSize(width: 25, height: 25)
        
        scrollView.frame = view.bounds
        
        onlineNowTitleLabel.sizeToFit()
        onlineNowTitleLabel.frame = CGRect(
            x: 15,
            y: 5,
            width: onlineNowTitleLabel.width,
            height: onlineNowTitleLabel.height
        )
        
        onlineNowView.frame = CGRect(
            x: 15,
            y: onlineNowTitleLabel.bottom + 5,
            width: view.width - 30,
            height: 100
        )
        
        rankingTitleLabel.sizeToFit()
        rankingTitleLabel.frame = CGRect(
            x: 15,
            y: onlineNowView.bottom + 5,
            width: rankingTitleLabel.width,
            height: rankingTitleLabel.height
        )
        
        rankingView.sizeToFit()
        print("Ranking height: \(rankingView.height)")
        rankingView.frame = CGRect(
            x: 0,
            y: rankingTitleLabel.bottom + 5,
            width: view.width,
            height: rankingView.height
        )
        
        scrollView.contentSize.height = rankingView.bottom
    }
    
    @objc private func didTapNotifications() {
        let vc = NotificationsVC()
        vc.isHeroEnabled = true
        vc.modalPresentationStyle = .fullScreen
        vc.heroModalAnimationType = .pageIn(direction: .left)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapCreatePost() {
        let vc = CreatePostViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
