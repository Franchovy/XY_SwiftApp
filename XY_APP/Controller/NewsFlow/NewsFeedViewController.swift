//
//  HomeViewController.swift
//  XY_APP
//
//  Created by Maxime Franchot on 27/11/2020.
//

import UIKit


class NewsFeedViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var ringBar: CircleView!
    
    @IBOutlet weak var tableView: FlowTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ringBar.layer.shadowRadius = 10
        ringBar.layer.shadowOffset = .zero
        ringBar.layer.shadowOpacity = 0.5
        ringBar.layer.shadowColor = UIColor.blue.cgColor
        ringBar.layer.shadowPath = UIBezierPath(rect: ringBar.bounds).cgPath
        ringBar.layer.masksToBounds = false
        ringBar.levelLabel.text = "4"
        ringBar.levelLabel.textColor = .white
        ringBar.backgroundColor = .clear
        ringBar.tintColor = .blue
        
        let logo = UIImage(named: "XYnavbarlogo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        tableView.parentViewController = self
        
        // Get posts from backend
        // Set posts inside tableview
    
        // Remove the extra empty cell divider lines
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func xpButtonPressed(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
        //self.navigationController?.pushViewController(vc, animated: true)
        self.show(vc, sender: self)
    }
}

