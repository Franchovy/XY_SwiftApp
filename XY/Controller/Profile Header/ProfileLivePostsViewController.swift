//
//  ProfileLivePostsViewController.swift
//  XY
//
//  Created by Maxime Franchot on 18/02/2021.
//

import UIKit

class ProfileLivePostsViewController: UIViewController {

    let xpcircleTest = XPCircleView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(xpcircleTest)
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
    }
}
