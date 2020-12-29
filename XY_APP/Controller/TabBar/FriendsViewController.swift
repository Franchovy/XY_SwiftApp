//
//  FriendsViewController.swift
//  XY_APP
//
//  Created by Simone on 07/12/2020.
//

import Foundation
import UIKit

class FriendsViewController: UIViewController {
    
    
    @IBOutlet weak var friendshipContainer: UIView!
    @IBOutlet weak var chartsContainer: UIView!
    @IBOutlet weak var FL_Acquintance: UIButton!
    @IBOutlet weak var challengesView: UIView!
    
    override func viewDidLoad() {
        
        friendshipContainer.layer.cornerRadius = 15.0
        friendshipContainer.layer.shadowColor = UIColor.black.cgColor
        friendshipContainer.layer.shadowOffset = CGSize(width:1, height:1)
        friendshipContainer.layer.shadowRadius = 1
        friendshipContainer.layer.shadowOpacity = 1.0
        
        chartsContainer.layer.cornerRadius = 15.0
        
        challengesView.layer.shadowColor = UIColor.black.cgColor
        challengesView.layer.shadowOffset = CGSize(width:1, height:1)
        challengesView.layer.shadowRadius = 1
        challengesView.layer.shadowOpacity = 1.0
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        super.viewDidLoad()
        
    }
}
