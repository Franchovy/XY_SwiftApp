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
    
    let barXPCircle: CircleView = {
        let circleView = CircleView()
        circleView.setProgress(level: 0, progress: 0.0)
        circleView.setupFinished()
        circleView.setLevelLabelFontSize(size: 24)
        circleView.registerXPUpdates(for: .ownUser)
        return circleView
    }()
    
    private let seeMoreButton: UIButton = {
        let button = UIButton()
        button.setTitle("See All", for: .normal)
        button.titleLabel?.font = UIFont(name: "Raleway-Heavy", size: 22)
        button.setTitleColor(UIColor(named: "XYTint"), for: .normal)
        return button
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
        
        view.addSubview(onlineNowTitleLabel)
        view.addSubview(rankingTitleLabel)
        view.addSubview(onlineNowView)
        view.addSubview(rankingView)
        view.addSubview(seeMoreButton)
        
        rankingView.subscribeToRanking()
        
        seeMoreButton.addTarget(self, action: #selector(didTapSeeMoreRanking), for: .touchUpInside)
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
        
        rankingView.frame = CGRect(
            x: 0,
            y: rankingTitleLabel.bottom + 5,
            width: view.width,
            height: rankingHeight
        )
        
        seeMoreButton.sizeToFit()
        seeMoreButton.frame = CGRect(
            x: (view.width - seeMoreButton.width)/2,
            y: rankingView.bottom + 10,
            width: seeMoreButton.width,
            height: seeMoreButton.height
        )
    }
    
    @objc private func didTapSeeMoreRanking() {
        rankingView.subscribeToRanking()
        
        rankingHeight = 550
        
        UIView.animate(withDuration: 0.3) {
            self.seeMoreButton.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.seeMoreButton.alpha = 0.0
        } completion: { (done) in
            if done {
                UIView.animate(withDuration: 1.5, delay: 0.1, options: .curveEaseIn) {
                    self.rankingView.frame.size.height = self.rankingHeight
                }
            }
        }
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
