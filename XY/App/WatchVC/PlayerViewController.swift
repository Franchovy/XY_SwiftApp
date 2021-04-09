//
//  PlayerViewController.swift
//  XY
//
//  Created by Maxime Franchot on 09/04/2021.
//

import UIKit

class PlayerViewController: UIViewController {
    
//    private var videoLayer: AVPlayerLayer?
    

    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = [.red, .blue, .green, .purple][Int.random(in: 0...3)]
        view.layer.cornerRadius = 15
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

}
