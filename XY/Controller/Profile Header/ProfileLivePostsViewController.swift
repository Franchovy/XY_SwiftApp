//
//  ProfileLivePostsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

class ProfileLivePostsViewController: UIViewController {

    let xpcircleTest = XPCircleView()
    let profileBubble = ProfileBubble()
    let profileBubble2 = ProfileBubble()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(xpcircleTest)
        view.addSubview(profileBubble)
        profileBubble.setButtonMode(mode: .follow)
        view.addSubview(profileBubble2)
        profileBubble2.setButtonMode(mode: .add)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        xpcircleTest.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        xpcircleTest.center = view.center
        
        profileBubble.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        profileBubble.center = view.center.applying(CGAffineTransform(translationX: -100, y: -100))
        
        profileBubble2.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        profileBubble2.center = profileBubble.center.applying(CGAffineTransform(translationX: 100, y: -60))
    }
}
