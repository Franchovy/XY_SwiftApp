//
//  ChallengeDescriptionViewController.swift
//  XY
//
//  Created by Maxime Franchot on 02/04/2021.
//

import UIKit

class ChallengeDescriptionViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Description"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}
